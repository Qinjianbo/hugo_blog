---
title: OpenClaw CLI 初始化向导详解：用 openclaw onboard 完成首次配置
date: 2026-03-14T21:47:20+08:00
lastmod: 2026-03-14T21:47:20+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - Agent
  - CLI
tags:
  - OpenClaw
  - CLI
  - AI Agent
  - Onboarding
  - Wizard
draft: false
description: 把 OpenClaw 官方 CLI Onboarding Wizard 文档整理成中文教程，讲清楚 openclaw onboard 的默认配置、Advanced 选项、本地与远程模式差异，以及多 Agent 追加方式。
source_url: https://docs.openclaw.ai/start/wizard
---

如果你不是通过 macOS App，而是准备直接在命令行里完成 OpenClaw 的首次配置，那么官方推荐的入口就是 `openclaw onboard`。这篇文章把官方文档整理成中文，重点讲清楚它会帮你配什么、QuickStart 和 Advanced 怎么选，以及什么时候该用本地模式、什么时候只该连远端 Gateway。

<!--more-->

## 适用场景

- 想在 macOS、Linux 或 Windows + WSL2 上用 CLI 完成 OpenClaw 首次安装
- 不想手动一点点改配置文件，想走官方推荐的引导流程
- 准备配置 Gateway、频道、技能和工作区，但不确定默认值分别是什么

## 一条命令启动向导

官方推荐直接运行：

```bash
openclaw onboard
```

如果只是想尽快开始第一段对话，官方还额外给了一个更快的路径：

```bash
openclaw dashboard
```

这样可以直接打开 Control UI，在浏览器里开始聊天，不需要先配消息渠道。

## 后续重新配置用什么命令？

如果后面想修改配置，而不是重新完整跑一次 onboarding，可以用：

```bash
openclaw configure
openclaw agents add <name>
```

官方还有一个容易误解的小点：

- `--json` 不代表非交互模式
- 如果你在脚本里跑向导，应该显式使用 `--non-interactive`

## QuickStart 和 Advanced 怎么选？

CLI 向导一开始会让你在两种模式之间二选一：

- `QuickStart`：走官方默认值，尽快完成首次可用配置
- `Advanced`：把主要步骤都展开，适合想细调的人

如果你只是第一次上手，优先选 `QuickStart`。因为 OpenClaw 这套默认值，本身已经覆盖了大部分个人使用场景。

## QuickStart 默认会帮你配什么？

官方文档列出的默认项，整理后大致是这样：

- 使用本地 Gateway，并且只绑定在 loopback
- 使用默认工作区，或者沿用你已有的工作区
- Gateway 默认端口是 `18789`
- Gateway 认证方式默认是 `Token`
- 即使是 loopback，本地也会自动生成 token，而不是默认无认证
- 新的本地配置默认使用 `tools.profile: "coding"`
- 如果 `session.dmScope` 还没设置，本地 onboarding 会写成 `per-channel-peer`
- 默认不开启 Tailscale 暴露
- Telegram 和 WhatsApp 私聊默认使用 allowlist，并提示你填写手机号

这套默认值的核心思路很明确：先确保本地能安全跑起来，而不是为了省一步配置把权限和暴露范围直接放开。

## Wizard 还会带你配置哪些内容？

如果你选择本地模式，官方文档说明向导会依次覆盖下面这些部分。

## 1. Model / Auth

你可以在向导里选择模型提供方和认证方式，包括：

- API Key
- OAuth
- setup-token
- 自定义 Provider

官方还特别提醒了一点：如果这个 Agent 未来要运行工具，或者处理 webhook、hooks 之类的外部内容，尽量优先使用更强、更新一代的模型，并保持严格的工具权限策略。原因很直接，较弱或较老的模型更容易受到提示注入影响。

对于自动化脚本场景，文档还提到：

- `--secret-input-mode ref` 可以把认证信息存成环境变量引用，而不是明文 API Key
- 非交互模式下，如果要走 `ref`，需要先把对应环境变量准备好

## 2. Workspace

向导会让你设置 Agent 文件存放位置，默认目录是：

```bash
~/.openclaw/workspace
```

官方说明这里还会顺手种好 bootstrap 相关文件，也就是给后续首次启动准备基本环境。

## 3. Gateway

这一段会让你确定：

- 端口
- 绑定地址
- 认证模式
- 是否通过 Tailscale 暴露

如果你是在交互式 token 模式里配置，还可以决定 token 是直接明文存储，还是改成 SecretRef。  
如果是非交互模式，官方提供了这种方式传 token 引用：

```bash
--gateway-token-ref-env <ENV_VAR>
```

## 4. Channels

向导可以顺手帮你接入消息渠道。官方文档列出的支持项包括：

- WhatsApp
- Telegram
- Discord
- Google Chat
- Mattermost
- Signal
- BlueBubbles
- iMessage

这意味着你不需要把本地 Agent 跑起来后，再回头逐个补渠道配置。

## 5. Daemon

向导还能帮你把 OpenClaw 配成常驻后台服务：

- macOS 下使用 LaunchAgent
- Linux / WSL2 下使用 systemd user unit

官方在这里加了不少防呆逻辑，核心意思是：

- 如果 token 是通过 SecretRef 管理的，会先验证它能不能解析
- 如果 SecretRef 没法解析，daemon 安装会被阻止，并给出下一步提示
- 如果 token 和 password 都配置了，但 `gateway.auth.mode` 没有明确设置，也会阻止安装

这部分看起来啰嗦，但本质上是在避免“表面安装成功，实际服务起不来”。

## 6. Health Check

向导会尝试启动 Gateway，并确认它真的已经运行起来。

这一步很重要，因为很多命令行工具的问题并不是“配置没写进去”，而是“服务压根没起来”。官方把这个检查放进引导流程里，能省掉第一次排障的成本。

## 7. Skills

最后，向导还会安装推荐技能以及相关可选依赖。

如果你希望 OpenClaw 在首次可用状态下就具备较完整的能力，这一步很有价值；否则你还得后面再补装。

## Remote 模式到底做什么，不做什么？

官方在文档里写得很明确：

- `Remote mode` 只负责配置本地客户端，让它连接到别处已经存在的 Gateway
- 它不会在远端主机上安装任何东西
- 也不会替你修改远端 Gateway 的配置

这点非常重要。很多人看到“remote onboarding”会误以为 CLI 能顺带帮你把远端机器也部署好，但官方并没有这么设计。

## Web Search 也能在向导里一起配置

文档里还有一个比较实用的点：onboarding wizard 里包含 web search 配置步骤。

你可以直接在向导中选择搜索服务提供方，并填写 API Key。官方提到可选项包括：

- Perplexity
- Brave
- Gemini
- Grok
- Kimi

这样配置后，Agent 就可以使用 `web_search` 工具。  
如果你暂时跳过，也可以后面再单独执行：

```bash
openclaw configure --section web
```

## 重新跑向导会不会把现有环境清空？

不会默认清空。

官方文档说明，重新运行 wizard 不会擦除你的现有内容，除非你明确选择 `Reset`，或者命令里显式传入：

```bash
--reset
```

另外还有一个更彻底的版本：

```bash
--reset-scope full
```

它会把 workspace 也纳入重置范围。

如果当前配置已经损坏，或者还有旧版遗留字段，官方建议先跑：

```bash
openclaw doctor
```

## 想再加一个 Agent 怎么做？

如果你已经有一个 Agent，但还想再建一个彼此独立的新 Agent，可以用：

```bash
openclaw agents add <name>
```

官方说明它会为新 Agent 建立独立的：

- 名称
- workspace
- agentDir

默认工作区路径会遵循：

```bash
~/.openclaw/workspace-<agentId>
```

如果你不传 `--workspace`，这个命令本身也会进入向导流程。

文档还提到几项常见的非交互参数：

- `--model`
- `--agent-dir`
- `--bind`
- `--non-interactive`

## 注意事项

- 如果你只是想尽快开始第一次对话，`openclaw dashboard` 可能比先配渠道更快。
- `--json` 只是输出格式，不等于脚本友好的非交互模式；自动化场景要用 `--non-interactive`。
- QuickStart 默认已经启用 token 认证，即使是 loopback，也不是完全裸奔模式。
- Remote 模式不会帮你部署远端 Gateway，它只负责本地连接配置。
- 如果你的 Agent 要接触外部 webhook、hooks 或运行更高风险工具，模型选择和工具权限策略都应该比默认更严格。

## 一句话总结

`openclaw onboard` 本质上就是 OpenClaw 官方提供的“一次性把本地 Gateway、工作区、频道、后台服务和技能串起来”的初始化向导；第一次安装时优先走 QuickStart，只有在你明确知道自己要改哪些默认项时，再切到 Advanced。

## 原文链接

- OpenClaw Docs: [Onboarding Wizard (CLI)](https://docs.openclaw.ai/start/wizard)

<!--qr_code-->
