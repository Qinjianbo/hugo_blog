---
title: "n8n官方教程：构建一个迷你工作流实战"
date: 2025-05-06T13:21:23+08:00
lastmod: 2025-05-06T13:21:23+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/%E5%93%94%E5%93%A9%E5%93%94%E5%93%A9%E4%B8%8A%E6%90%9C%E9%9B%86%E7%9A%84%E7%BE%8E%E5%9B%BE%E8%89%B2%E5%9B%BE_1-1000/10.jpg
categories:
  - 自动化工具
  - n8n教程
tags:
  - n8n
  - 工作流
  - 自动化
  - 教程
---

本文将带你通过 n8n 官方教程，快速上手构建一个迷你自动化工作流。你将学会如何用 n8n 获取 Hacker News 上关于"automation"的10条最新资讯，并掌握节点配置、执行与保存的完整流程。

<!--more-->

## 教程目标

- 熟悉 n8n 编辑器 UI
- 学会添加和配置节点
- 实践获取外部数据并展示
- 掌握工作流的保存与执行

## 步骤详解

### 1. 添加手动触发节点（Manual Trigger）
在 n8n 编辑器右上角点击"+"或按 Tab，搜索并添加"Manual Trigger"节点。该节点允许你随时手动运行整个工作流。

### 2. 添加 Hacker News 节点
点击 Manual Trigger 右侧的"+"，搜索并添加"Hacker News"节点。在"Actions"中选择"Get many items"。

### 3. 配置 Hacker News 节点
- **Resource**: All
- **Operation**: Get Many
- **Limit**: 10
- **Additional Fields > Keyword**: automation

这样配置后，节点会抓取包含"automation"关键词的10条最新资讯。

#### 设置说明
- **Parameters**: 每个节点独有的功能参数
- **Settings**: 所有节点通用的设计与执行参数

你可以在 Settings 里为节点添加备注（如"Get the 10 latest articles"），并选择"Display note in flow?"让备注在画布上可见。

### 4. 执行节点
点击节点详情窗口的"Test step"按钮，查看输出结果。你可以在 Table、JSON、Schema 三种视图间切换，直观查看数据。

- Table 视图：以表格形式展示数据
- JSON 视图：以原始 JSON 展示
- Schema 视图：展示数据结构

执行成功后，节点上会出现绿色对勾。

### 5. 保存工作流
点击编辑器顶部的工作流名称进行重命名（如"Hacker News workflow"），然后点击右上角"Save"按钮或使用 Ctrl+S 快捷键保存。

## 小结

通过本教程，你已经学会了：
- 如何在 n8n 中添加和配置节点
- 如何抓取外部数据
- 如何执行和保存工作流

恭喜你完成了第一个 n8n 自动化工作流的搭建！

> 参考官方教程：[n8n官方Level One教程-构建迷你工作流](https://docs.n8n.io/courses/level-one/chapter-2/)

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