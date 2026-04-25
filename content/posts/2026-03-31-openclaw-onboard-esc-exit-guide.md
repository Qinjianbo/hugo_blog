---
title: OpenClaw onboard 配到一半按了 Esc 怎么办？如何继续配置
date: 2026-03-31T22:45:00+08:00
lastmod: 2026-03-31T22:45:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - Agent
  - 实用教程
tags:
  - OpenClaw
  - Onboarding
  - CLI
  - Wizard
draft: false
description: 把 openclaw onboard 中途按 Esc 退出后的恢复方法整理成一篇中文教程，讲清楚什么时候重跑向导、什么时候用 configure，以及什么时候才需要 reset。
source_url: https://docs.openclaw.ai/start/wizard
---

很多人第一次跑 `openclaw onboard` 时，都会碰到一个很现实的问题：还没配完，手一抖按了 `Esc` 退出，接下来该怎么办？这件事其实没有那么复杂。官方文档的结论也比较明确：重新运行 wizard 不会默认把你之前的内容清掉，只有你明确选择 `Reset`，或者手动传了 `--reset`，才会真正重置。下面把这个问题整理成一篇可以直接照着做的中文说明。

<!--more-->

## 适用场景

- 跑 `openclaw onboard` 时中途按了 `Esc`
- 不确定重跑 wizard 会不会把之前已经配好的内容清掉
- 想知道什么时候该继续跑 `onboard`，什么时候该改用 `configure`

## 先说结论：直接重新运行就行

最直接的做法就是：

```bash
openclaw onboard
```

官方文档明确说明：

- 重新运行 wizard 不会自动 wipe 现有内容
- 只有你显式选择 `Reset`
- 或者命令里明确传了 `--reset`

所以中途按 `Esc` 退出，并不等于“前面都白配了”。

## 为什么可以放心重跑？

OpenClaw 的 onboarding wizard 在启动时会先检测现有配置。  
如果发现已经有 `~/.openclaw/openclaw.json`，官方文档写的是会给你几个选项：

- `Keep`
- `Modify`
- `Reset`

这几个选项的含义可以这样理解：

- `Keep`：保留已有配置，不清空
- `Modify`：在现有配置基础上继续改
- `Reset`：明确重置后再重来

如果你的目标只是“把刚才没配完的部分补上”，通常就应该选：

```text
Modify
```

## 最常见的正确处理流程

如果你只是中途退出，建议按这个顺序处理：

1. 重新运行：

```bash
openclaw onboard
```

2. 如果检测到已有配置：

- 想继续在原配置上补完，就选 `Modify`
- 想维持现状，不动现有配置，就选 `Keep`
- 只有确定要从头来过，才选 `Reset`

## 没有“断点续传”命令吗？

严格来说，没有一个单独叫“resume”的命令。

官方建议的方式就是：

- 重新运行 `openclaw onboard`
- 然后基于当前已有配置继续处理

所以它不是“从某一步硬续上”，而是“重进 wizard，由 wizard 感知现有状态再继续”。

## 如果我只是想改其中一部分，还要不要重跑 onboarding？

不一定。

如果你后面只是想补某一块配置，而不是重走完整 onboarding，官方建议直接用：

```bash
openclaw configure
```

这个命令更适合：

- 已经基本装好了
- 只是想单独改模型、Gateway、渠道、web search 之类的配置

一句话区分：

- 首次配置、整体引导：`openclaw onboard`
- 后续局部调整：`openclaw configure`

## 如果我想新增一个新的 agent 呢？

这又是另一种情况。

如果你不是继续当前 agent，而是想额外再建一个独立 agent，官方给的命令是：

```bash
openclaw agents add <name>
```

这个命令适合：

- 你想保留现在这个 agent
- 但再新增一个新的工作区、session 和配置入口

## 什么时候才该用 `--reset`？

只有在你明确想“从头来过”的时候，才应该用：

```bash
openclaw onboard --reset
```

官方文档说明：

- `--reset` 默认重置的是 `config + credentials + sessions`

如果你连 workspace 也想一起清掉，才用：

```bash
openclaw onboard --reset-scope full
```

这个命令会更彻底，因为它会把 workspace 也纳入重置范围。

所以不要把 `--reset` 当成“修一修再继续”的常规手段。  
它更像“全部推倒重来”。

## 如果重跑 wizard 时被拦住了怎么办？

官方文档还提到一个常见例外：

- 如果当前配置无效
- 或者配置里还带着 legacy keys

wizard 可能不会直接继续，而是先要求你运行：

```bash
openclaw doctor
```

这时候正确做法不是继续硬跑，而是先修复配置问题，再回来继续。

## 一个最通俗的理解

你可以把 `openclaw onboard` 想成“入住酒店时的前台引导流程”。

如果你办入住办到一半先离开了：

- 酒店不会默认把你已经填过的信息全部撕掉
- 你回来后，前台会看你之前有没有记录
- 然后问你：保留、修改，还是重来

`Esc` 退出更像是：

- 暂时离开了前台

而不是：

- 酒店把你的整份入住资料直接粉碎了

## 一套最实用的命令清单

中途按 `Esc` 后，最常用的几条命令就是：

重新进入 wizard：

```bash
openclaw onboard
```

只改已有配置：

```bash
openclaw configure
```

新增一个独立 agent：

```bash
openclaw agents add <name>
```

从头重置再来：

```bash
openclaw onboard --reset
```

连 workspace 一起重置：

```bash
openclaw onboard --reset-scope full
```

配置损坏时先排查：

```bash
openclaw doctor
```

## 注意事项

- `Esc` 退出不等于自动丢配置
- 重跑 `onboard` 一般是安全的，除非你明确选了 `Reset`
- 只是改某一小块配置时，优先用 `configure`
- `--reset-scope full` 比普通 `--reset` 更重，因为会把 workspace 也纳入范围

## 一句话总结

`openclaw onboard` 配到一半按了 `Esc`，正常处理方式不是找“恢复命令”，而是直接重新运行 `openclaw onboard`。官方设计本来就是让 wizard 先检测已有配置，再让你决定 `Keep`、`Modify` 还是 `Reset`；如果只是继续没配完的内容，通常选 `Modify` 就够了。

## 参考资料

- Onboarding Wizard (CLI)：<https://docs.openclaw.ai/start/wizard>
- CLI Setup Reference：<https://docs.openclaw.ai/start/wizard-cli-flow>
- CLI Reference：<https://docs.openclaw.ai/cli>
- configure：<https://docs.openclaw.ai/cli/configure>
