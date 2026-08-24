---
title: "Stripe 支付链路深度拆解：从 HAR 到 Checkout、PaymentIntent 与 Webhook 对账"
date: 2026-08-18T10:56:13+08:00
lastmod: 2026-08-18T10:56:13+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - 支付
  - 技术
tags:
  - Stripe
  - Checkout
  - PaymentIntent
  - HAR
  - Webhook
  - 3DS
  - 支付安全
draft: false
description: "从 HAR 抓包复盘 Stripe Checkout 支付链路，拆解 Checkout Session、PaymentIntent、Invoice、Subscription、Webhook Event 的字段关系、状态机、幂等处理和对账方法。"
---

最近读到一篇拆 Stripe 协议支付的长文，技术密度很高。它真正有价值的地方，不是某个请求参数本身，而是把一次支付从浏览器、平台后端、Stripe Checkout、PaymentIntent、3DS、Webhook、账务对账串成了一条完整链路。

<!--more-->

Stripe 的难点从来不是“创建一个付款链接”。难点在于：用户看到的页面状态、Stripe 的支付状态、你的订单状态、订阅权益状态、账务状态，并不是同一个东西。只要把这些状态混在一起，早晚会遇到用户付款了但没开通、没付款却开通、重复开通、退款后权益没回收、续费失败还在服务这些问题。

这篇按工程视角重新拆一遍：先从 HAR 看链路，再看 Stripe 的对象边界，最后落到字段、状态机、Webhook 幂等和对账。

原参考文：<https://blog.caowo.de/posts/stripe-protocol-payment-automation-deep-dive-2026/>

## 先把结论放前面

做 Stripe 集成，最重要的不是会不会调 API，而是能不能回答五个问题：

1. 这笔本地订单，对应 Stripe 的哪个 `Checkout Session`、`PaymentIntent`、`Invoice`、`Subscription`？
2. 当前状态是页面状态、支付状态、账单状态，还是业务权益状态？
3. 如果 Webhook 重复、乱序、延迟到达，本地状态机会不会被写错？
4. 如果用户中途关闭页面、3DS 超时、银行拒付，本地订单会停在哪里，靠什么补偿？
5. 财务对账时，金额、币种、税费、折扣、退款、手续费能不能从 Stripe 对象一路追到本地订单？

Stripe Checkout 只是入口，PaymentIntent 才是一次支付尝试的状态机，Invoice / Subscription 才是订阅账务的核心，Webhook 才是后端最终一致性的来源。前端回跳只能作为提示，不能作为发货依据。

## HAR 应该怎么看

HAR 不是用来“复刻请求”的，它的价值是提供事实时间线。一次 Checkout 失败时，单看后端日志经常是不够的，因为问题可能发生在浏览器初始化、Checkout 页面、3DS 挑战、回跳、Webhook 任意一层。

一个有效的 HAR 复盘，应该先把请求按域名和职责分组：

| 分组 | 常见位置 | 主要问题 |
| --- | --- | --- |
| 业务前端 | 你的网页 | 是否拿到 Session、是否正确跳转、是否处理回跳 |
| 业务后端 | 你的 API | 是否创建本地订单、是否创建 Checkout Session、是否写入映射 |
| Stripe Checkout | `checkout.stripe.com` | 用户是否进入正确 Session、Session 是否过期 |
| Stripe API | `api.stripe.com` | PaymentIntent / SetupIntent / Customer / Invoice 状态 |
| Stripe JS | `js.stripe.com` | 前端组件是否加载、环境 key 是否匹配 |
| 认证链路 | 银行或 3DS 页面 | 用户是否完成挑战、是否超时、是否被拒绝 |

然后按时间线看四个断点：

| 断点 | 判断问题 |
| --- | --- |
| 创建 Session 前 | 前端参数、登录态、套餐映射、本地订单创建是否正常 |
| 创建 Session 后 | Session ID / URL 是否返回给前端，金额和币种是否正确 |
| 用户支付中 | 是否进入 3DS / 跳转认证 / 银行拒付 / 卡片错误 |
| 支付完成后 | 前端是否回跳，Webhook 是否到达，本地是否幂等处理 |

HAR 里要重点看的是请求顺序、状态码、对象 ID 和错误码，不要保存原始敏感内容。卡号、CVC、Cookie、Authorization、client secret、邮箱、地址、完整响应体，都不应该进入长期日志。

## Stripe 对象模型

把 Stripe 对象关系理清楚，后面的字段才有意义。

| 对象 | 作用 | 本地对应 |
| --- | --- | --- |
| `Customer` | Stripe 侧客户档案 | 本地用户 |
| `Price` | 价格和计费周期 | 本地套餐价格 |
| `Checkout Session` | 一次结账会话 | 本地订单或结账尝试 |
| `PaymentIntent` | 一次付款尝试 | 一次性订单支付状态 |
| `SetupIntent` | 保存支付方式授权 | 绑卡或订阅后续扣款准备 |
| `Subscription` | 订阅生命周期 | 本地订阅权益 |
| `Invoice` | 订阅账单或发票 | 本地账单和续费记录 |
| `Charge` | 实际扣款记录 | 财务交易明细 |
| `BalanceTransaction` | 余额流水 | 财务对账、手续费、净额 |
| `Event` | Webhook 事件 | 本地事件处理记录 |

对象之间不是平级关系。典型订阅链路是：

```text
User
  -> Customer
  -> Checkout Session
  -> Subscription
  -> Invoice
  -> PaymentIntent
  -> Charge
  -> BalanceTransaction
```

典型一次性支付链路是：

```text
Order
  -> Checkout Session
  -> PaymentIntent
  -> Charge
  -> BalanceTransaction
```

如果本地只保存 `checkout_session_id`，排查首单可能够用，但排查续费、退款、拒付、发票失败就不够了。订阅业务至少要保存 `customer_id`、`subscription_id`、`latest_invoice_id`，一次性支付至少要保存 `payment_intent_id` 和后续的 `charge_id`。

## Checkout Session 不是支付凭证

很多接入错误都来自把 Checkout Session 当成支付结果。Session 只是结账容器，它说明“用户被引导去做一次结账”，不等于钱已经到账。

关键字段可以按职责分组。

### 身份和关联字段

| 字段 | 作用 | 经验判断 |
| --- | --- | --- |
| `id` | Session ID | 本地必须保存，排查入口 |
| `client_reference_id` | 业务关联 ID | 最适合放本地 `order_id` 或 `checkout_attempt_id` |
| `metadata` | 业务元数据 | 放短 ID，不放隐私和 token |
| `customer` | Stripe Customer | 订阅和复购必须稳定映射 |
| `customer_email` | 预填邮箱 | 不能作为本地用户身份依据 |

`client_reference_id` 和 `metadata.order_id` 最好都写。原因很简单：不同 Webhook 事件里出现的对象层级不一样，有的事件主体是 Session，有的是 PaymentIntent，有的是 Invoice。多写一层关联 ID，排查时少查一跳。

### 金额和商品字段

| 字段 | 作用 | 风险点 |
| --- | --- | --- |
| `line_items` | 商品明细 | 默认不一定展开，对账时要单独查或 expand |
| `amount_subtotal` | 折扣税费前金额 | 不能直接当最终应付 |
| `amount_total` | 最终应付金额 | 开通前必须和本地预期核对 |
| `currency` | 支付币种 | 多币种业务一定要比对 |
| `total_details.amount_tax` | 税额 | 税务展示和财务对账使用 |
| `total_details.amount_discount` | 折扣 | 活动核销和收入分析使用 |

本地订单建议保存两个金额：`amount_expected` 和 `amount_confirmed`。前者是创建 Session 前你认为用户应该付的钱，后者是 Stripe 最终确认的金额。二者不一致时不要自动开通权益，先进入人工或补偿流程。

### 状态字段

| 字段 | 可能值 | 解释 |
| --- | --- | --- |
| `status` | `open` / `complete` / `expired` | Session 生命周期 |
| `payment_status` | `paid` / `unpaid` / `no_payment_required` | Session 视角下的支付状态 |
| `expires_at` | timestamp | Session 过期时间 |
| `payment_intent` | `pi_...` | 一次性支付时的支付对象 |
| `subscription` | `sub_...` | 订阅场景下的订阅对象 |
| `invoice` | `in_...` | 账单对象 |

两个常见误判：

1. `status=complete` 不等于业务可以发货。它只能说明 Checkout 流程完成了，仍要结合 `payment_status`、PaymentIntent / Invoice 和 Webhook。
2. 用户访问了 `success_url` 不等于支付成功。浏览器回跳不是可信资金信号，用户关闭页面或网络异常也不应该影响后端最终入账。

## 创建 Session 的输入边界

后端创建 Checkout Session 时，最危险的不是 Stripe，而是你信了前端传来的字段。

| 字段 | 是否应由前端决定 | 说明 |
| --- | --- | --- |
| `mode` | 否 | 由业务订单类型决定 |
| `line_items.price` | 否 | 前端传 `plan_id`，后端映射 Stripe Price |
| `line_items.quantity` | 可传但要校验 | 校验最小值、最大值、库存和套餐限制 |
| `customer` | 否 | 从登录用户映射 |
| `success_url` | 否 | 后端生成，防开放跳转 |
| `cancel_url` | 否 | 后端生成 |
| `return_url` | 否 | embedded / custom 场景尤其要固定 |
| `automatic_tax.enabled` | 否 | 税务策略不交给前端 |
| `allow_promotion_codes` | 否 | 活动策略由服务端控制 |
| `metadata` | 否 | 后端写入可审计 ID |
| `subscription_data.metadata` | 否 | 订阅事件里继续能找回业务 ID |
| `payment_intent_data.metadata` | 否 | 一次性支付事件里继续能找回业务 ID |

一个比较稳的写法是：前端只提交 `plan_id`、`quantity`、可选的优惠码；后端重新读取套餐、价格、库存、活动、用户资格，再创建 Stripe Session。这样即使前端被篡改，也不会出现 1 美元买高价套餐的问题。

## PaymentIntent 才是支付状态机

PaymentIntent 描述的是“Stripe 正在尝试收这笔钱”。Checkout 负责用户界面，PaymentIntent 负责支付状态。排查扣款失败、3DS、银行拒付时，最终都要落到 PaymentIntent。

核心字段：

| 字段 | 作用 | 排查价值 |
| --- | --- | --- |
| `id` | PaymentIntent ID | 一次支付尝试的主索引 |
| `amount` | 应收金额 | 和本地订单比对 |
| `amount_received` | 已收金额 | 判断资金结果 |
| `currency` | 币种 | 多币种对账 |
| `customer` | 客户 | 防止对象串错用户 |
| `payment_method` | 支付方式 | 可继续查品牌、尾号、国家等脱敏信息 |
| `payment_method_types` | 允许支付方式 | 排查为什么出现或不出现某类支付方式 |
| `status` | 支付状态 | 驱动本地状态机 |
| `next_action` | 下一步动作 | 3DS、跳转认证、凭证展示 |
| `last_payment_error` | 最近失败原因 | 拒付、卡错误、认证失败 |
| `latest_charge` | 最新 Charge | 退款、手续费、余额流水继续追 |
| `metadata` | 业务关联 | 反查本地订单 |

PaymentIntent 状态不能直接平铺到本地订单，要做映射：

| PaymentIntent 状态 | 本地动作 |
| --- | --- |
| `requires_payment_method` | 支付方式缺失或失败，允许用户换卡 |
| `requires_confirmation` | 等待确认，保持 pending |
| `requires_action` | 等待用户完成 3DS 或跳转认证 |
| `processing` | 异步处理中，不要提前发货 |
| `requires_capture` | 授权成功，等待后端 capture |
| `succeeded` | 支付成功，可以进入权益开通 |
| `canceled` | 支付尝试结束，订单可取消或重建 |

这里要特别注意 `processing`。某些支付方式不是同步完成的，如果你只按前端回跳开通，很容易把还没最终成功的订单当成成功。

## 3DS 的本质是状态暂停

3DS 不是错误，它是 PaymentIntent 从“可尝试扣款”进入“等待用户认证”的暂停状态。Stripe 会把这个暂停表达在 `requires_action` 和 `next_action` 里。

工程上要处理三件事：

1. 前端要能让用户完成认证。
2. 后端不能在认证完成前开通权益。
3. 认证超时或失败后，本地订单要能从 pending 里释放出来。

`next_action` 不要当成固定结构写死。不同支付方式、不同地区、不同认证类型，下一步动作不一定一样。后端更应该关心最终状态和 Webhook，而不是前端某个页面事件。

失败时重点看 `last_payment_error`：

| 字段 | 用途 |
| --- | --- |
| `code` | Stripe 归类错误 |
| `decline_code` | 发卡行拒付原因 |
| `message` | 错误描述 |
| `payment_method` | 关联支付方式 |
| `charge` | 关联扣款尝试 |

对用户展示时，不要把底层错误原样扔出去。比较好的做法是把错误分成几类：余额不足、卡片信息错误、需要认证、银行拒绝、支付方式不支持、系统异常。底层 `code` 和 `decline_code` 留给日志、客服和风控分析。

## 订阅链路要看 Invoice

订阅场景里，很多人只盯着 `Subscription`，这也会出错。Subscription 描述的是订阅关系，Invoice 描述的是每一期账单，PaymentIntent 描述的是某一张账单的付款尝试。

订阅首单常见链路：

```text
checkout.session.completed
  -> subscription created
  -> invoice finalized
  -> invoice paid
  -> payment_intent.succeeded
```

续费时用户不一定经过 Checkout，更多是：

```text
invoice.created
  -> invoice.finalized
  -> invoice.payment_succeeded / invoice.payment_failed
  -> customer.subscription.updated
```

所以订阅权益不能只靠 `checkout.session.completed`。它只能说明首单 Checkout 完成。后续续费、欠费、取消、试用结束，都要跟着 Invoice 和 Subscription 事件走。

关键字段：

| 对象 | 字段 | 用途 |
| --- | --- | --- |
| Subscription | `status` | 订阅整体状态 |
| Subscription | `current_period_start` / `current_period_end` | 权益周期 |
| Subscription | `cancel_at_period_end` | 是否期末取消 |
| Subscription | `trial_end` | 试用结束时间 |
| Invoice | `status` | 账单是否 paid / open / void / uncollectible |
| Invoice | `amount_due` | 应付金额 |
| Invoice | `amount_paid` | 已付金额 |
| Invoice | `payment_intent` | 本期支付尝试 |
| Invoice | `subscription` | 对应订阅 |
| Invoice | `billing_reason` | 首次订阅、续费、升级差价等原因 |

对订阅产品来说，真正应该驱动权益有效期的是 `invoice.paid` 和 Subscription 的周期字段，而不是用户浏览器是否回到了成功页。

## Webhook 的难点是重复和乱序

Stripe Webhook 至少要按“会重复、会乱序、会延迟”来设计。任何只靠内存状态、只处理一次、按接收顺序推进业务状态的实现，都不够稳。

事件表建议这样设计：

| 字段 | 说明 |
| --- | --- |
| `stripe_event_id` | 唯一索引，幂等主键 |
| `event_type` | 事件类型 |
| `object_id` | `data.object.id` |
| `object_type` | 对象类型 |
| `livemode` | 防止 test / live 混写 |
| `api_version` | 排查字段差异 |
| `payload_redacted` | 脱敏后的事件快照 |
| `process_status` | pending / processed / failed |
| `retry_count` | 本地重试次数 |
| `last_error` | 脱敏错误 |
| `received_at` | 收到时间 |
| `processed_at` | 处理完成时间 |

处理顺序建议：

1. 先校验签名。
2. 立刻用 `stripe_event_id` 落库。
3. 如果事件已存在，直接返回成功。
4. 在数据库事务里读取本地订单 / 订阅。
5. 校验金额、币种、对象归属。
6. 推进本地状态机。
7. 写权益变更记录和审计日志。
8. 标记事件处理完成。

不要在 Webhook handler 里做太多慢操作。发邮件、通知、统计、CRM 同步，可以丢异步队列。Webhook handler 的职责是把支付事实可靠落库。

## 事件类型怎么分工

常见事件不要一股脑都当“支付成功”。

| 事件 | 适合做什么 |
| --- | --- |
| `checkout.session.completed` | 标记用户完成 Checkout，补写 Session 关联对象 |
| `payment_intent.succeeded` | 一次性支付成功，开通一次性权益 |
| `payment_intent.payment_failed` | 标记支付失败，允许用户重试 |
| `invoice.paid` | 订阅账单支付成功，开通或延长订阅 |
| `invoice.payment_failed` | 续费失败，提醒换卡或进入宽限期 |
| `customer.subscription.created` | 创建本地订阅记录 |
| `customer.subscription.updated` | 更新周期、套餐、取消状态、试用状态 |
| `customer.subscription.deleted` | 终止订阅或回收权益 |
| `charge.refunded` | 退款后回收权益或标记财务冲销 |
| `charge.dispute.created` | 拒付争议，触发风控和客服流程 |

一个典型错误是收到 `checkout.session.completed` 就立即开通年度订阅。更稳的是：首单订阅以 `invoice.paid` 作为开通依据，再用 Subscription 的周期字段计算权益结束时间。

## 状态机要单调推进

本地订单状态最好设计成单调推进，不能让旧事件把新状态覆盖掉。

一次性订单可以这样：

| 本地状态 | 可进入条件 | 后续动作 |
| --- | --- | --- |
| `created` | 本地订单创建 | 等待创建 Session |
| `pending_payment` | Session 创建成功 | 等待支付 |
| `requires_action` | PaymentIntent 需要认证 | 等待用户动作 |
| `processing` | Stripe 异步处理中 | 等待 Webhook / 查询补偿 |
| `paid` | PaymentIntent succeeded | 开通权益 |
| `failed` | 支付失败 | 允许重试 |
| `expired` | Session 过期 | 重新下单 |
| `refunded` | Charge refunded | 回收权益 |
| `disputed` | Charge disputed | 冻结或人工处理 |

状态推进要校验当前状态。例如订单已经 `paid`，后来收到一个旧的 `payment_intent.payment_failed`，不能把订单写回 failed。正确做法是记录事件，但不回退业务状态。

## 对账要从 Charge 继续往下追

业务系统关心的是“用户有没有付”，财务系统关心的是“钱最终怎么结算”。Stripe 里这两个问题不是同一个对象回答的。

| 问题 | 看哪个对象 |
| --- | --- |
| 用户是否完成结账 | Checkout Session |
| 支付是否成功 | PaymentIntent / Invoice |
| 是否真正扣款 | Charge |
| 手续费和净额 | BalanceTransaction |
| 是否退款 | Refund / Charge |
| 是否拒付 | Dispute / Charge |
| 订阅是否有效 | Subscription + Invoice |

建议本地保留一张支付流水表：

| 字段 | 说明 |
| --- | --- |
| `order_id` | 本地订单 |
| `stripe_payment_intent_id` | 支付尝试 |
| `stripe_charge_id` | 扣款记录 |
| `stripe_balance_transaction_id` | 余额流水 |
| `gross_amount` | 毛收入 |
| `fee_amount` | Stripe 手续费 |
| `net_amount` | 净入账 |
| `currency` | 币种 |
| `exchange_rate` | 汇率，若有 |
| `refunded_amount` | 已退款金额 |
| `dispute_status` | 拒付状态 |

这样月底对账时，不需要从业务订单里硬猜收入。订单管权益，支付流水管资金，发票管账单，余额流水管净额。

## 常见故障怎么定位

### 用户说付了钱，但账号没开通

按顺序查：

1. 本地是否有 `order_id`。
2. 是否保存了 `checkout_session_id`。
3. Session 的 `payment_status` 是否为 `paid`。
4. 是否有 `payment_intent.succeeded` 或 `invoice.paid`。
5. Webhook 事件表里是否处理成功。
6. 权益表是否有开通记录。
7. 是否因为金额 / 币种不一致被拦截。

如果 Stripe 已成功、本地 Webhook 失败，补偿任务应该能重放事件或重新查询 Stripe 对象后修复。

### 用户回到成功页，但后台还是 pending

成功页只说明浏览器回来了。继续看：

- Webhook 是否未到。
- Endpoint 是否签名校验失败。
- 本地事件是否重复插入失败。
- PaymentIntent 是否仍在 `processing`。
- Invoice 是否还没 `paid`。

前端此时应显示“支付处理中”，而不是直接显示权益已开通。

### 订阅续费失败但用户还能用

查三类字段：

- Invoice 是否 `payment_failed`。
- Subscription 是否进入 `past_due`、`unpaid` 或仍在宽限期。
- 本地权益结束时间是否只在首单写入，后续没有跟随 Invoice 更新。

订阅权益不能只在购买时写一次，必须跟着续费、取消、退款、拒付事件调整。

### 重复开通权益

通常是幂等没做好：

- Webhook 事件重复投递。
- `invoice.paid` 和 `payment_intent.succeeded` 都触发开通。
- 前端成功页和 Webhook 各开通一次。
- 重试任务没有检查已有权益记录。

解决方式是给权益变更表加业务唯一键，比如 `source_type + source_id`。同一张 Invoice 只能延长一次订阅，同一个 PaymentIntent 只能发放一次一次性权益。

## 自动化应该自动哪一层

支付自动化本身没问题，但要自动化的是自己的后端业务流程，而不是模拟用户绕过支付页面和认证。

适合自动化的部分：

- 创建订单和 Checkout Session。
- 保存 Session / PaymentIntent / Invoice / Subscription 映射。
- Webhook 幂等落库。
- 支付成功后开通权益。
- 支付失败后提醒用户换卡。
- 续费失败后进入宽限期。
- 退款后回收权益。
- 定时补偿 pending 订单。
- 财务对账和差异告警。

不适合自动化的部分：

- 替用户输入卡号。
- 绕过 3DS 或验证码。
- 伪造浏览器或设备环境。
- 批量尝试支付方式。
- 用虚假地址规避税费。
- 保存完整卡号、CVC、原始 HAR。

支付系统的边界很简单：你可以自动化自己的订单、账单、Webhook、对账；不要自动化用户认证和支付安全机制。

## 最后给一套落地清单

如果从零接 Stripe，我会按这个顺序做：

1. 本地先建 `orders`、`subscriptions`、`payment_events`、`payment_ledger` 四类表。
2. 创建 Session 前先生成本地订单，前端只传 `plan_id`。
3. Session 里写 `client_reference_id` 和 `metadata.order_id`。
4. `payment_intent_data.metadata`、`subscription_data.metadata` 也写本地 ID。
5. 前端成功页只展示“支付处理中 / 已完成”，不直接发权益。
6. Webhook 先落事件表，再幂等推进业务状态。
7. 一次性支付以 `payment_intent.succeeded` 开通。
8. 订阅以 `invoice.paid` 开通或续期。
9. 退款、拒付、取消订阅都要反向更新权益。
10. 每天跑补偿任务，扫描 pending、processing、Webhook failed、账务不平的记录。

Stripe 集成真正的专业度，不在于请求写得多像浏览器，而在于每一笔钱都能解释：为什么收、收了多少、谁收的、对应哪个订单、哪个事件触发了权益、失败后停在哪里、退款后怎么回滚、月底怎么对账。

能回答这些问题，支付链路才算真正跑通。
