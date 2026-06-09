---
title: "Codex 国内零门槛接入 DeepSeek：用 CCX 把模型接通的实操教程"
date: 2026-06-09T10:00:00+08:00
lastmod: 2026-06-09T10:00:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - OpenAI
  - DeepSeek
tags:
  - Codex
  - DeepSeek
  - CCX
  - OpenAI
  - 教程
draft: false
description: "整理一套通过 CCX 让 Codex 接入 DeepSeek 的本地配置流程，包括 API Key 申请、客户端安装、网关接入和模型映射。"
aiSummary: "这篇文章把一套通过 CCX 接入 DeepSeek 并让 Codex 使用的本地配置流程整理成了可操作步骤，包括 DeepSeek API Key 申请、Codex 客户端安装、CCX 作为中间网关的配置、连通性验证和模型重定向。"
aiKeyPoints:
  - "DeepSeek API Key 如何申请并安全保存"
  - "Codex 客户端和 CCX 的安装与基础配置"
  - "如何通过 CCX 把 Codex 请求转发到 DeepSeek"
faq:
  - q: "这篇文章解决什么问题？"
    a: "它把视频里的操作流程整理成一篇可直接照着做的实操教程，帮助你在本地把 Codex 接到 DeepSeek。"
  - q: "适合什么人看？"
    a: "适合已经在使用 Codex，或者准备尝试 Codex，但希望用更低门槛方式接入 DeepSeek 的开发者。"
source_url: https://www.youtube.com/watch?v=O_KWRobwudw
---

如果你已经在用 Codex 做日常开发，接下来最常见的需求之一，就是给它接一个自己更顺手的模型后端。这里我把你提供的视频内容整理成一套更适合站内阅读的实操教程：通过本地中间件 CCX，让 Codex 走 DeepSeek。

<!--more-->

## 核心思路

这套方案的关键点很简单：

- Codex 负责客户端交互和工作流
- CCX 负责把 Codex 的请求转成 DeepSeek 能理解的格式
- DeepSeek 负责模型推理

你可以把 CCX 理解成一个本地“翻译层”或“网关层”。对 Codex 来说，它仍然是在和一个兼容的模型接口通信；对 DeepSeek 来说，它收到的是经过转换后的请求。

## 准备工作

开始之前，先准备好这几样东西：

- 一个可用的 DeepSeek 账号
- DeepSeek API Key
- Codex 客户端
- CCX

如果你已经安装过其中一部分，也可以直接跳到对应步骤。

## 第一步：申请 DeepSeek API Key

1. 打开 DeepSeek 官方平台并登录。
2. 进入充值或余额页面，先准备少量可用额度。
3. 打开 `API keys` 页面，创建一个新的 Key。
4. 给 Key 起一个容易识别的名字，比如 `codex-use`。
5. 生成后立刻复制保存。

这一点很重要，因为很多平台都会在关闭页面后隐藏完整密钥，后面就需要重新创建。

## 第二步：安装 Codex 客户端

1. 前往 Codex 官方下载页，获取对应平台的安装包。
2. 完成安装后，启动 Codex 客户端。
3. 按照你的实际使用习惯完成初始引导。

如果你后面准备让它走本地网关，这一步主要是先把客户端准备好，不需要急着把所有账号配置一次做完。

## 第三步：安装 CCX

1. 打开 CCX 的项目页面，下载最新版本。
2. 运行安装包并完成安装。
3. 启动 CCX，等待它完成初始化。

CCX 在这里承担的是本地代理和请求转发的角色。后面的重点，是把 Codex 和 DeepSeek 都接到它上面。

## 第四步：把 Codex 接到 CCX

1. 打开 CCX 的 `agent page`。
2. 在 Provider 下拉菜单里选择 CCX 本地网关。
3. 应用配置，让 Codex 通过这个网关发起请求。

这一步做完后，Codex 的请求路径就已经从“直接连模型服务”变成了“先经过 CCX 再出去”。

## 第五步：在 CCX 里接入 DeepSeek

1. 在 CCX 左侧找到 `渠道中心`。
2. 选择 `DeepSeek` 渠道。
3. 在目标或接入配置里，填写你的 DeepSeek API Key。
4. 保存并添加到 CCX。

配置成功后，CCX 就能把来自 Codex 的请求转发给 DeepSeek。

## 第六步：验证是否连通

完成配置后，重新打开 Codex 客户端，试着发一个简单请求，比如：

- 让它打个招呼
- 让它解释一小段代码
- 让它做一个简单的文件修改建议

如果一切正常，你应该能看到：

- Codex 有正常回复
- CCX 里出现请求日志
- DeepSeek 后台有对应调用记录

这说明整条链路已经打通。

## 进阶：模型重定向

如果 CCX 支持模型重定向，你还可以把 Codex 里不同的模型选择映射到不同的 DeepSeek 模型上。这样做的好处是，你可以按任务复杂度和成本自由分配：

- 大任务用更强的模型
- 日常轻任务用更便宜的模型

实际映射方式取决于你手头 CCX 的版本和界面，但思路基本一致：在 Codex 侧选择一个模型，在 CCX 侧把它重定向到你想用的 DeepSeek 模型。

## 适用场景

这套方案更适合以下场景：

- 你已经在使用 Codex
- 你想更灵活地选择底层模型
- 你希望本地调试请求链路
- 你愿意自己维护一层中间网关

如果你更在意稳定性和官方支持，或者不想额外维护本地网关，那也可以继续使用官方默认链路。

## 注意事项

有几件事最好提前放在心里：

- API Key 要妥善保存，不要随手发到群里或仓库里
- CCX 是额外的一层中间件，出问题时要同时排查客户端、网关和上游模型
- 如果你切换网络、代理或模型，最好再做一次最小请求验证
- 不同版本的 Codex 和 CCX 界面可能略有差异，以你当前版本为准

## 一句话总结

这套流程本质上就是：先准备 DeepSeek API Key，再让 Codex 经过 CCX 这个本地网关去调用 DeepSeek。思路不复杂，真正的价值在于它把“能不能接通”这件事，变成了一套可重复的本地配置流程。

## 参考

- 视频教程：`https://www.youtube.com/watch?v=O_KWRobwudw`

