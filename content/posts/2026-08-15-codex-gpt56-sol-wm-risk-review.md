---
title: "Codex 里的 GPT-5.6-Sol-WM 是什么？从隐藏模型教程复盘到合规使用 GPT-5.6 Sol"
date: 2026-08-15T16:44:33+08:00
lastmod: 2026-08-15T16:44:33+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - 工具
tags:
  - Codex
  - OpenAI
  - GPT-5.6
  - 配置
  - 风险提醒
draft: false
description: "复盘一篇 GPT-5.6-Sol-WM 隐藏模型教程的发现思路，说明本地模型缓存、visibility、服务器授权之间的关系，并整理一套合规使用 GPT-5.6 Sol 的实用配置方法。"
---

今天看到一篇关于 Codex 隐藏模型 `gpt-5.6-sol-wm` 的文章，标题很吸引人：任意付费账号、不消耗额度、无限调用。原文的核心发现来自本地 Codex 模型缓存：缓存里存在一个默认隐藏的 WM 模型条目，于是作者尝试把它显示出来并指定为默认模型。

<!--more-->

先说结论：这类文章真正有价值的地方，不是“无限调用”，而是它展示了一个排查思路：Codex 客户端本地确实会缓存模型目录，目录里可能包含不展示给普通用户的内部条目。但本地看得到，不代表官方授权你稳定使用；本地改成可见，也不等于绕过服务器权限和额度规则。

所以这篇不复刻原文的隐藏路由启用步骤，而是整理成一个更稳的实用教程：如何理解它是怎么被发现的，如何只读检查自己的 Codex 模型目录，如何判断这类教程的风险，最后如何改用官方公开的 GPT-5.6 Sol。

## 原文是怎么发现的

原文的发现路径大概是这样：

1. Codex 客户端会在本地保存模型目录缓存。
2. 作者在缓存文件里搜索模型 slug，发现了 `gpt-5.6-sol-wm`。
3. 这个条目的 `visibility` 字段是隐藏状态，所以默认不出现在模型选择器里。
4. 它不是公开 API 模型，更多像是 Codex 内部或实验用途的路由标识。
5. 作者进一步尝试让这个隐藏条目变成可选模型，并用命令行指定它启动 Codex。

这里最关键的是第三点和第四点：这是一个客户端模型目录条目，不是公开产品页里的推荐模型。把一个本地隐藏条目显示出来，只能说明客户端愿意读取这个配置；真正能不能用、怎么计费、能不能长期稳定，仍然由服务器端决定。

## 本地可见和服务器授权是两件事

很多人看到这种教程容易误判，以为“缓存里有 = 官方给我用”。这个理解不严谨。

至少要拆成三层看：

- **本地目录层**：客户端缓存了哪些模型条目。
- **界面展示层**：哪些模型会出现在下拉选择器里。
- **服务器授权层**：账号实际有没有权限调用，以及调用后如何计入额度。

本地修改最多影响前两层。第三层不在你电脑上，不能靠改 JSON 或 TOML 解决。

这也是为什么原文里 Free 账号会被服务器拒绝：缓存里有条目，不等于账号有权限。反过来，即使某个付费账号短期能调通，也不能证明这是稳定、公开、长期可用的入口。

## 为什么不建议照着改隐藏 WM

我不建议把隐藏 WM 路由当成日常主力模型，原因有几个。

第一，它不是官方公开文档里的推荐模型。OpenAI 当前公开的 Codex 模型页里，推荐的是 GPT-5.6 系列，比如 `gpt-5.6-sol`、`gpt-5.6-terra`、`gpt-5.6-luna`。

第二，原文的核心卖点是“不消耗额度”。这种说法本身就是风险信号。官方文档明确说 ChatGPT Work 和 Codex 共用 usage/credits；Fast mode 还会以更高倍率消耗 credits。一个隐藏路由如果短期没有出现在消费明细里，更合理的判断是：它可能是计量展示延迟、内部路由差异、实验配置，或者很快会被修正，而不是可以放心长期薅。

第三，修改模型目录绕过 UI 选择器，会让你的本地配置变得难排查。以后 Codex 升级、模型目录字段变化、配置层优先级变化，都可能导致莫名其妙的问题。

## 实用教程：只读检查自己的 Codex 模型目录

下面这部分是安全的，只做检查，不修改缓存。

### 1. 确认 Codex 配置目录

macOS / Linux：

```bash
printf '%s\n' "${CODEX_HOME:-$HOME/.codex}"
```

Windows PowerShell：

```powershell
if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
```

如果你从没启动过 Codex，目录或缓存文件可能不存在。先正常登录并使用一次 Codex，再回来检查。

### 2. 只读查看模型缓存是否存在

macOS / Linux：

```bash
ls -lh "${CODEX_HOME:-$HOME/.codex}/models_cache.json"
```

Windows PowerShell：

```powershell
$CodexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
Get-Item -LiteralPath (Join-Path $CodexRoot "models_cache.json")
```

### 3. 搜索可疑隐藏模型条目

macOS / Linux：

```bash
grep -nE '"slug"|"visibility"|"supported_in_api"' "${CODEX_HOME:-$HOME/.codex}/models_cache.json" | grep -E 'gpt-5.6|wm|visibility|supported_in_api'
```

Windows PowerShell：

```powershell
$CachePath = Join-Path $CodexRoot "models_cache.json"
Select-String -LiteralPath $CachePath -Pattern '"slug"','"visibility"','"supported_in_api"' |
  Select-String -Pattern 'gpt-5.6|wm|visibility|supported_in_api'
```

这一步只用于理解本机缓存里有什么，不要直接编辑 `models_cache.json`。Codex 会刷新这个文件，手改也容易把正常模型目录弄乱。

## 实用教程：改用官方公开的 GPT-5.6 Sol

如果你真正想用的是 Sol 级别能力，建议直接走官方公开模型。

临时启动一次：

```bash
codex -m gpt-5.6-sol
```

如果你想设成默认模型，打开用户级配置：

```bash
open "${CODEX_HOME:-$HOME/.codex}/config.toml"
```

Linux 没有 `open` 的话，可以用你习惯的编辑器：

```bash
nano "${CODEX_HOME:-$HOME/.codex}/config.toml"
```

加入或修改：

```toml
model = "gpt-5.6-sol"
model_reasoning_effort = "medium"
```

如果任务很复杂，可以临时提高 reasoning effort；如果是日常小改，`medium` 更适合做默认值。官方文档也建议按任务需要选择最低够用的 reasoning effort。

## Fast mode 要不要开

如果你追求更快速度，可以使用官方 Fast mode，而不是碰隐藏 WM 路由。

命令行临时开启：

```bash
codex -m gpt-5.6-sol -c 'service_tier="fast"' -c 'features.fast_mode=true'
```

或者在 `config.toml` 里持久化：

```toml
service_tier = "fast"

[features]
fast_mode = true
```

注意：Fast mode 不是免费加速。官方文档写得很清楚，它会以更高倍率消耗 credits。也就是说，快是快，但要接受对应的额度成本。

## 如果你已经照原文改过，怎么回滚

如果你已经配置过隐藏 WM 路由，建议先恢复到公开模型。

打开 `~/.codex/config.toml`，检查并删除这类配置：

```toml
model_catalog_json = "..."
model = "gpt-5.6-sol-wm"
```

然后改回公开模型：

```toml
model = "gpt-5.6-sol"
model_reasoning_effort = "medium"
```

重启 Codex 后，用下面命令确认当前模型：

```bash
codex -m gpt-5.6-sol
```

如果你之前额外生成过自定义模型目录文件，可以先保留备查；确认 Codex 正常后再删除。不要删除 `auth.json`、token 或其他认证相关文件。

## 怎么判断类似教程能不能跟

以后再看到类似“隐藏模型”“内部路由”“不消耗额度”“无限用”的文章，可以用这几个标准判断：

- 是否要求修改本地模型缓存或自定义模型目录。
- 是否依赖官方文档没有公开列出的模型 slug。
- 是否把“不出现在消费明细”当成长期免费依据。
- 是否建议绕过 UI、隐藏入口或额度统计。
- 是否让你复制别人的认证文件、token、auth 配置。

如果命中多条，就不要当成稳定教程。它可以作为技术现象复盘，但不适合照着改成主力工作流。

## 一句话总结

原文的价值在于提醒我们：Codex 本地模型缓存里可能能看到一些隐藏条目；但真正实用、稳定的做法，不是把隐藏 WM 路由改成可见，而是理解本地目录、配置层和服务器授权的边界，然后使用官方公开的 `gpt-5.6-sol`、`gpt-5.6-terra`、`gpt-5.6-luna`。想要更快就开官方 Fast mode，接受对应 credits 消耗；想要稳定，就别把“暂时没计费”当成长期方案。

## 参考资料

- 原文参考：[GPT-5.6-Sol 隐藏模型无限调用指南 - 任意付费账号不消耗额度（2026 年 8 月实测）](https://blog.caowo.de/posts/codex-gpt56sol-wm-unlimited-guide/)
- OpenAI Docs: [Config basics](https://learn.chatgpt.com/docs/config-file/config-basic)
- OpenAI Docs: [Models](https://learn.chatgpt.com/docs/models)
- OpenAI Docs: [Speed](https://learn.chatgpt.com/docs/agent-configuration/speed)
