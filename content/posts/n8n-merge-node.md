---
title: "N8n Merge 节点详解"
date: 2025-05-02T22:18:01+08:00
lastmod: 2025-05-02T22:18:01+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/posts/2.jpg
categories:
  - 自动化工具
tags:
  - n8n
  - 数据处理
  - 工作流
---

在 n8n 工作流中，Merge 节点是实现数据流合并与处理的核心工具。它可以将来自不同节点的数据流进行多种方式的合并，极大提升了数据处理的灵活性。本文将详细介绍 Merge 节点的功能、常用模式及实际应用场景。

<!--more-->

## 节点概述

Merge 节点支持多种合并模式，包括追加（Append）、按字段匹配合并（Combine by Matching Fields）、按位置合并（Combine by Position）、所有组合（All Possible Combinations）、SQL 查询合并（SQL Query）以及分支选择（Choose Branch）。

## 主要合并模式

### 1. 追加（Append）
将输入1和输入2的数据简单拼接在一起，适合需要将多组数据汇总的场景。

### 2. 按字段匹配合并（Combine by Matching Fields）
根据指定字段（如 language）将两组数据进行一一匹配合并。例如：
- 输入1：[{name: 'Stefan', language: 'de'}, ...]
- 输入2：[{greeting: 'Hallo', language: 'de'}, ...]
合并后每个人都能获得对应语言的问候语。

### 3. 按位置合并（Combine by Position）
将输入1和输入2中相同位置的数据合并，适合数据结构一一对应的场景。

### 4. 所有组合（All Possible Combinations）
将输入1和输入2的所有数据进行笛卡尔积组合，适合需要穷举所有可能配对的场景。

### 5. SQL 查询合并（SQL Query）
可自定义 SQL 语句对输入数据进行复杂合并，支持多表连接、筛选等高级操作。

### 6. 分支选择（Choose Branch）
可选择保留输入1或输入2的数据，或输出空项，适合流程分支控制。

## 高级选项

- **字段冲突处理**：可设置优先保留哪个输入的数据，或为冲突字段自动添加输入编号后缀。
- **深度合并/浅合并**：支持嵌套对象的深度合并，适合复杂数据结构。
- **模糊比较**：允许类型不同但值相同的字段进行匹配（如 "3" 和 3）。
- **保留未配对项**：合并时可选择是否保留未匹配的数据项。

## 实用示例

假设有两组数据：

- 输入1：
```json
[
  { "name": "Stefan", "language": "de" },
  { "name": "Jim", "language": "en" }
]
```
- 输入2：
```json
[
  { "greeting": "Hallo", "language": "de" },
  { "greeting": "Hello", "language": "en" }
]
```

选择"按字段匹配合并"，字段为 language，合并结果：
```json
[
  { "name": "Stefan", "language": "de", "greeting": "Hallo" },
  { "name": "Jim", "language": "en", "greeting": "Hello" }
]
```

更多详细用法和参数说明请参考官方文档：[n8n Merge 节点官方文档](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.merge/)

## 总结

Merge 节点是 n8n 工作流中不可或缺的数据处理工具。通过灵活选择合并模式和高级选项，可以满足绝大多数数据整合需求。

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