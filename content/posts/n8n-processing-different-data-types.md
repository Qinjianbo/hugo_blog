---
title: "n8n官方教程：处理不同数据类型实战"
date: 2025-05-06T17:20:27+08:00
lastmod: 2025-05-06T17:20:27+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/posts/12.jpg
categories:
  - 自动化工具
  - n8n教程
tags:
  - n8n
  - 数据类型
  - 数据处理
  - 教程
---

本文基于 n8n 官方 Level Two 教程，系统讲解 n8n 如何处理 HTML/XML、日期时间、二进制等多种数据类型，并通过实战演示常见节点的用法和数据转换技巧。

<!--more-->

## 1. 处理 HTML 和 XML 数据

n8n 支持直接解析 HTML 和 XML 格式的数据。常用场景包括网页抓取、接口返回内容解析等。

### HTML 解析实战
- 使用 HTTP Request 节点获取网页内容
- 用 HTML 节点提取特定元素（如标题、表格等）
- 可结合 Code 节点进一步处理提取结果

### XML 解析实战
- HTTP Request 节点获取 XML 数据
- 用 HTML 节点（支持 XML 解析）或 Code 节点解析 XML 字符串

## 2. 日期、时间与区间数据

n8n 的 Date & Time 节点可用于：
- 获取当前时间、日期
- 时间格式转换（如 ISO、Unix 时间戳等）
- 计算时间区间、日期加减

**示例：**
- 获取当前时间并格式化为"YYYY-MM-DD HH:mm:ss"
- 计算两个日期之间的天数

## 3. 二进制数据处理

n8n 支持处理文件、图片、PDF等二进制数据，常见节点有：
- HTTP Request 节点（下载文件）
- Extract From File 节点（提取PDF、图片、表格等内容）
- Convert to File 节点（将JSON等数据转为二进制文件）
- Read/Write Files from Disk 节点（本地读写文件）

### 二进制数据实战
- 下载PDF文件并提取文本内容
- 将API返回的JSON数据保存为本地文件

**示例流程：**
1. HTTP Request 节点下载 PDF
2. Extract From File 节点提取文本
3. Convert to File 节点将 JSON 转为二进制
4. Read/Write Files from Disk 节点保存/读取文件

## 小结

- n8n 支持多种数据类型的自动化处理
- HTML/XML、日期时间、二进制文件等都可通过专用节点灵活处理
- 结合 Code 节点可实现更复杂的数据转换与自动化

> 参考官方教程：[n8n官方Level Two教程-处理不同数据类型](https://docs.n8n.io/courses/level-two/chapter-2/)

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