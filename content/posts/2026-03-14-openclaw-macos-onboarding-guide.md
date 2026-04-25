---
title: OpenClaw macOS 初始引导全流程：首次安装后的 7 个步骤
date: 2026-03-14T21:33:38+08:00
lastmod: 2026-03-14T21:33:38+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - Agent
  - macOS
tags:
  - OpenClaw
  - macOS
  - AI Agent
  - Onboarding
  - 安装指南
draft: false
description: 把 OpenClaw 官方 macOS Onboarding 文档整理成中文教程，涵盖首次启动、Gateway 选择、权限授权、CLI 与引导聊天等完整流程。
source_url: https://docs.openclaw.ai/start/onboarding
---

如果你第一次打开 OpenClaw 的 macOS App，看到一连串系统弹窗、权限申请和 Gateway 选项，很容易一时不知道该怎么选。本文基于 OpenClaw 官方文档整理，把首次安装后的关键步骤翻译成中文，并补上更适合实际使用时理解的说明。

<!--more-->

## 适用场景

- 刚安装 OpenClaw，准备完成首次启动配置
- 想弄清楚 `This Mac`、`Remote`、`Configure later` 三种入口的差异
- 想提前知道 OpenClaw 会请求哪些 macOS 权限

## 流程总览

OpenClaw 当前的首次引导流程，可以理解成下面 7 步：

1. 通过 macOS 的安全提示
2. 允许应用发现本地网络
3. 阅读欢迎页里的安全说明
4. 选择 Gateway 运行位置
5. 授予所需系统权限
6. 可选安装全局 CLI
7. 进入专用的 onboarding chat

## 第一步：通过 macOS 安全警告

首次运行时，macOS 可能会先弹出系统级安全警告。按官方流程，先确认并允许 OpenClaw 继续运行。

![OpenClaw macOS 安全警告](/img/openclaw-macos-onboarding/01-macos-warning.jpeg)

这一步本质上是 macOS 对新应用的常规拦截。只要你确认安装包来源可信，就按系统提示继续即可。

## 第二步：允许发现本地网络

接下来，系统会询问是否允许 OpenClaw 发现本地网络设备。官方文档建议在引导阶段放行。

![允许 OpenClaw 发现本地网络](/img/openclaw-macos-onboarding/02-local-networks.jpeg)

原因也不复杂：OpenClaw 在本地运行或连接局域网内服务时，可能需要完成网络发现与通信。如果这里拒绝，后续某些连接流程可能会受影响。

## 第三步：阅读欢迎页里的安全说明

欢迎页不只是一个“下一步”按钮，它其实先给出了 OpenClaw 的默认安全模型。

![OpenClaw 欢迎页与安全说明](/img/openclaw-macos-onboarding/03-security-notice.png)

官方文档里这部分的核心意思，可以整理成 4 点：

- 默认情况下，OpenClaw 假设你是在“单一可信操作者”的边界内使用它，也就是偏个人 Agent 的模型。
- 如果你准备做共享或多用户部署，就不能沿用这种默认信任方式，需要主动收紧权限边界。
- 本地 onboarding 生成的新配置，默认会使用 `tools.profile: "coding"`，这样可以保留常见文件系统和运行时工具，而不是一上来就使用更宽松的 `full` 配置。
- 如果你打算接入 hooks、webhooks 或其他不完全可信的外部内容源，应该使用更强的模型能力，同时保持严格的工具策略和沙箱隔离。

这一页的重点不是吓人，而是先把信任边界说清楚：你是在给“自己的本机助手”授权，还是在搭一个能被更多人或更多来源间接影响的 Agent 环境。

## 第四步：选择 Gateway 运行位置

这一页是整个 onboarding 里最关键的选择之一：Gateway 到底跑在本机，还是远端机器上。

![选择 Gateway 运行位置](/img/openclaw-macos-onboarding/04-choose-gateway.png)

官方文档把三种模式定义得很清楚：

- `This Mac (Local only)`：引导流程会在本机完成认证配置，并把凭据写到本地环境。
- `Remote (over SSH/Tailnet)`：引导流程不会帮你配置本地认证，相关凭据必须已经存在于远端 Gateway 主机上。
- `Configure later`：先跳过配置，让应用保持未完成设置的状态。

这里还有一个很容易忽略的细节。官方特别提醒：

- 向导现在即使是本地 loopback 场景，也会生成一个 `token`
- 这意味着本地 WebSocket 客户端也需要认证，不再是“本机就默认放开”
- 如果你手动关闭认证，那任何本地进程都可能连上来，所以只适合完全可信的机器
- 如果要跨机器访问，或者不是绑定在 loopback 地址上，建议明确使用 `token`

如果你只是个人日常使用，通常选 `This Mac` 最省事；如果你已经在服务器、NAS 或另一台主机上部署 Gateway，再考虑 `Remote`。

## 第五步：授予 OpenClaw 所需权限

接下来是权限授权页。OpenClaw 会集中请求它在 macOS 上完成自动化和交互所需的 TCC 权限。

![OpenClaw 权限申请页面](/img/openclaw-macos-onboarding/05-permissions.png)

官方文档列出的权限包括：

- Automation（AppleScript 自动化）
- Notifications（通知）
- Accessibility（辅助功能）
- Screen Recording（屏幕录制）
- Microphone（麦克风）
- Speech Recognition（语音识别）
- Camera（摄像头）
- Location（定位）

这些权限不是每个用户都会全部用到，但如果你的使用方式涉及系统控制、屏幕理解、语音输入或设备协同，这些授权就会直接影响 OpenClaw 的实际能力。

## 第六步：可选安装 CLI

权限之后，OpenClaw 还会给你一个可选步骤：是否安装全局 `openclaw` CLI。

官方说明很直接，这一步是可选的，但装上以后有两个明显好处：

- 终端工作流可以直接调用 `openclaw`
- 一些基于 `launchd` 的任务或自动化流程可以开箱即用

如果你基本只在图形界面里使用，可以先跳过；如果你本来就习惯终端和脚本自动化，建议顺手安装。

## 第七步：进入专用 Onboarding Chat

当上述配置完成后，应用会自动打开一个专门的 onboarding chat 会话。

这个设计的目的，是把“第一次启动时的自我介绍和引导”与平时的正常聊天分开。这样你后面真正开始使用 OpenClaw 时，主会话上下文不会被首次配置说明打乱。

官方文档还提到，这个专用会话之后会衔接到 Bootstrapping 阶段，也就是 Agent 在 Gateway 主机上首次自举时发生的那些事情。

## 注意事项

- 如果你选择的是 `Remote`，不要以为本地向导会顺手把认证配好。官方说明很明确：远端模式下，凭据必须已经存在于 Gateway 主机。
- 本地模式也不再等于“默认免认证”。新的流程会为 loopback 场景生成 `token`。
- 关闭认证只适合完全可信的个人机器；一旦本机里有其他不受信任的进程，这个决定就会放大风险。
- 如果你准备接入 webhook、hooks 或其他外部输入源，权限和沙箱策略应该比“个人单机使用”更严格。

## 一句话总结

OpenClaw 的 macOS 首次引导并不复杂，真正重要的是在第四步想清楚 Gateway 跑在哪里，以及在权限与认证这两件事上不要为了图省事直接全放开。

## 原文链接

- OpenClaw Docs: [Onboarding (macOS App)](https://docs.openclaw.ai/start/onboarding)

<!--qr_code-->
