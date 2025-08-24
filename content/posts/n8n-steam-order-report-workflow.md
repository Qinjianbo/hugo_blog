---
title: "n8n实战：自动获取Steam支付订单并推送飞书日报"
date: 2025-05-22T13:31:02+08:00
lastmod: 2025-05-22T13:31:02+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/posts/20.jpg
categories:
  - 自动化工具
  - n8n实战
tags:
  - n8n
  - Steam
  - 飞书
  - 自动报表
  - 教程
# nolastmod: true
draft: true
---

本文介绍一个基于 n8n 的自动化工作流：定时获取 Steam 支付成功订单，统计每日总单数与金额，并通过飞书机器人推送日报。适用于游戏、电商等需要自动汇总订单数据并团队共享的场景。

<!--more-->

## 工作流功能概述

- **定时触发**：每小时自动运行一次
- **获取系统时间**：动态获取当前日期
- **请求 Steam 订单数据**：通过 Steam API 拉取指定日期的订单
- **解析订单信息**：提取订单列表
- **遍历与筛选**：批量处理订单，仅保留支付成功的订单
- **数据统计**：计算总订单数与总金额
- **推送飞书**：自动生成日报并推送到飞书群

## 节点与流程详解

1. **定时触发**
   - 使用 Schedule Trigger 节点，每小时自动启动一次流程。
2. **获取系统时间**
   - DateTime 节点获取当前时间，Set 节点格式化为 yyyy-MM-dd。
3. **请求 Steam 订单数据**
   - HTTP Request 节点调用 Steam MicroTxn API，传入日期参数，获取订单报表。
4. **解析订单信息**
   - SplitOut 节点提取 response.params.orders 字段，获得订单数组。
5. **遍历所有订单**
   - SplitInBatches 节点分批处理订单，提升效率。
6. **订单状态判断**
   - If 节点筛选 status 字段为 Succeeded 的订单。
7. **合并成功订单**
   - Merge 节点将所有成功订单合并。
8. **计算总金额和总单数**
   - Code 节点遍历订单，累加金额与数量，输出统计结果。
9. **发送飞书通知**
   - HTTP Request 节点调用飞书机器人 Webhook，推送格式化日报。

## 关键代码片段

**统计总金额与单数（Code节点）：**
```javascript
var totalOrder = $input.all().length
var totalMoney = 0
for (const item of $input.all()) {
  for (const item1 of item.json.items) {
    totalMoney += item1.amount
  }
}
return {
  json: {
    money: totalMoney/100,
    count: totalOrder,
    currentDate: $('格式化时间').first().json.currentDate
  }
}
```

## 使用场景
- 游戏/电商平台自动汇总每日订单
- 财务、运营团队自动接收日报
- 需要对接 Steam 订单 API 并自动推送消息的业务

## 注意事项
- 需替换 Steam API Key、AppID、飞书 Webhook 地址为你自己的信息
- 建议为飞书机器人设置安全限制，防止滥用
- 订单金额单位为分，需除以 100 转为元
- 可根据实际需求调整定时频率、推送内容等

## 小结

本工作流实现了 Steam 订单自动统计与飞书日报推送，极大提升了数据汇总与团队协作效率。n8n 的可视化流程让自动化变得简单易用，适合各类业务场景扩展。

> 参考文档：[n8n官方文档](https://docs.n8n.io/) | [Steam MicroTxn API](https://partner.steamgames.com/doc/webapi/ISteamMicroTxn)

<!--qr_code-->

## 捐赠

感谢老板请我喝杯咖啡！Thank you for buying me a coffee!

| WeChat | AliPay | PayPal |
| --- | --- | --- |
| ![wechatpay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/wechat_%E6%94%B6%E6%AC%BE%E7%A0%81.jpg) | ![alipay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/alipay.jpg) | [PayPal](https://paypal.me/JianboQin?country.x=C2&locale.x=zh_XC) |

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】 