---
title: "Cursor 0.49.x 更新指南：规则生成、终端控制与 MCP 图像支持"
date: 2025-04-24T09:53:46+08:00
lastmod: 2025-04-24T09:53:46+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto/article (36).jpg
categories:
  - 技术教程
  - 开发工具
tags:
  - Cursor
  - IDE
  - 代码编辑助手
  - 效率工具
draft: false
---

Cursor 0.49.x 版本带来了一系列令人兴奋的新功能和改进，包括规则生成、终端控制优化、MCP 图像支持等。本文将详细介绍这些更新内容，帮助您更好地利用这些新特性提升开发效率。

<!--more-->

## 规则生成与自动化

### 自动规则生成

现在您可以直接从对话中生成规则，使用 `/Generate Cursor Rules` 命令。这对于捕获现有对话上下文以便后续重用非常有用。

- 对于定义了路径模式的 `Auto Attached` 规则，Agent 现在会在读取或写入文件时自动应用正确的规则
- 修复了 `Always` 附加规则在较长对话中持久化的问题
- Agent 现在可以可靠地编辑规则

### 全局忽略文件

您现在可以通过用户级设置定义全局忽略模式，这些模式将应用于所有项目。这可以防止构建输出或敏感文件等嘈杂文件进入提示，而无需每个项目单独配置。

## 历史记录与代码审查

### 更易访问的历史记录

聊天历史记录已移至命令面板。您可以通过聊天中的"显示历史记录"按钮或 `Show Chat History` 命令访问它。

### 更轻松的代码审查

现在通过在每个对话结束时内置的差异视图，审查 AI 生成的代码变得更加容易。您可以在聊天中 Agent 消息后找到 `Review changes` 按钮。

## MCP 图像支持

您现在可以在 MCP 服务器中传递图像作为上下文的一部分。当截图、UI 原型或图表为问题或提示添加重要上下文时，这非常有用。

## 终端控制改进

我们对 Agent 启动的终端增加了更多控制：

- 命令现在可以在运行前编辑
- 可以完全跳过命令
- "Pop-out" 已重命名为 "Move to background"，以更好地反映其功能

## 新模型支持

最近添加了更多模型供您使用：

- Gemini 2.5 Pro
- Gemini 2.5 Flash
- Grok 3
- Grok 3 Mini
- GPT-4.1
- o3 和 o4-mini

## 项目结构上下文（Beta）

我们引入了在上下文中包含项目结构的选项，这会将您的目录结构添加到提示中。Agent 现在可以更清楚地了解项目的组织方式，从而改进对大型或嵌套 monorepo 的建议和导航。

## 其他改进

### 快捷键

- 一些 `CMD+K` 快捷键现在可以重新映射
- Emacs 键绑定扩展现在可以可靠工作

### 界面优化

- 简化了 Auto-select 的模型选择器 UI
- 新的命令面板界面
- 刷新了 Tab 跳转建议的 UI
- 聊天中的模式提示
- MCP 稳定性提升

### 集成功能

- 现在可以使用访问密钥和密钥连接到 AWS Bedrock
- Git > @PR 已重命名为 @Branch

## 企业/团队功能

### 全局忽略遍历

- Cursor 现在可以遍历目录树以查找忽略文件
- 此行为默认关闭，可以从管理设置启用

### AWS Bedrock IAM 角色

- 企业现在可以使用 IAM 角色连接到 AWS Bedrock

### 用户级使用洞察

- 管理员现在可以直接从仪表板查看每个用户的支出和快速请求使用情况

### 团队自动运行控制

- 管理员可以从仪表板配置全局 MCP 设置

## 总结

Cursor 0.49.x 版本带来了许多令人兴奋的更新，从规则生成到终端控制，再到 MCP 图像支持，这些新功能都旨在提升开发者的工作效率。无论您是个人开发者还是团队成员，这些更新都能帮助您更好地利用 Cursor 的强大功能。

<!--qr_code-->

## 捐赠

感谢老板请我喝杯咖啡！Thank you for buying me a coffee!

| WeChat | AliPay | PayPal |
| --- | --- | --- |
| ![wechatpay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/wechat_%E6%94%B6%E6%AC%BE%E7%A0%81.jpg) | ![alipay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/alipay.jpg) | [PayPal](https://paypal.me/JianboQin?country.x=C2&locale.x=zh_XC) |

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2024 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】 