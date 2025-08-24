---
title: "n8n官方教程：合并、循环与批量处理数据实战"
date: 2025-05-07T13:32:21+08:00
lastmod: 2025-05-07T13:32:21+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/posts/14.jpg
categories:
  - 自动化工具
  - n8n教程
tags:
  - n8n
  - 数据合并
  - 循环
  - 批量处理
  - 教程
---

本文基于 n8n 官方 Level Two 教程，系统讲解 n8n 中数据合并、循环与批量处理的核心节点和实战技巧，帮助你高效应对多数据流、循环处理和大批量数据自动化场景。

<!--more-->

## 1. 数据合并（Merge）

n8n 的 Merge 节点支持多种合并模式：
- 追加（Append）：将两组数据简单拼接
- 按字段匹配合并（Combine by Matching Fields）：根据指定字段一一合并
- 按位置合并（Combine by Position）：同位置数据合并
- 所有组合（All Possible Combinations）：笛卡尔积
- SQL 查询合并（SQL Query）：自定义SQL合并
- 分支选择（Choose Branch）：流程分支控制

**实战示例：**
- 合并两组用户与问候语数据，实现自动配对

## 2. 循环（Looping）

n8n 节点默认对每个 item 自动循环处理，无需手动构建循环。但在某些特殊场景（如需多次回流、条件终止）可用 If 节点+回流实现自定义循环。

**循环实现要点：**
- 节点间连接形成回路
- If 节点判断是否继续循环

## 3. 批量处理（Loop Over Items）

当需要分批处理大量数据、避免API限流或多次执行Code节点时，可用 Loop Over Items 节点（Split In Batches）：
- 设置 Batch Size，自动将数据分批传递
- 每批处理后自动进入下一批，直至全部处理完毕

**典型应用：**
- 批量抓取多个RSS源
- 分批调用API，防止超限

### 批量处理实战：抓取多个RSS源
1. Code节点生成RSS源URL列表：
```javascript
let urls = [
  { json: { url: 'https://medium.com/feed/n8n-io' } },
  { json: { url: 'https://dev.to/feed/n8n' } }
];
return urls;
```
2. Loop Over Items节点，Batch Size设为1
3. RSS Read节点，URL参数用表达式`{{ $json.url }}`

## 小结

- Merge节点支持多种数据合并模式，适合复杂数据整合
- n8n天然支持循环处理，特殊场景可自定义循环
- Loop Over Items节点让批量处理更高效，适合大数据量和API限流场景

> 参考官方教程：[n8n官方Level Two教程-合并、循环与批量处理数据](https://docs.n8n.io/courses/level-two/chapter-3/)

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