---
title: OpenClaw hooks 有什么用？小白应该怎么选
date: 2026-03-31T22:56:26+08:00
lastmod: 2026-03-31T22:56:26+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - Agent
  - 实用教程
tags:
  - OpenClaw
  - Hooks
  - Automation
  - CLI
draft: false
description: 把 OpenClaw hooks 的作用、常见内置 hook 以及小白用户最稳的启用顺序整理成一篇中文教程。
source_url: https://docs.openclaw.ai/automation/
---

很多人第一次看到 OpenClaw 里的 `hooks`，会以为这是什么高级功能，只有重度玩家才需要碰。其实没那么夸张。你完全可以把它理解成“某个事件发生后，系统自动帮你做一件事”。真正的问题不是 hooks 难不难，而是小白该先开哪个、哪些先不要动。这篇文章就专门回答这个问题。

<!--more-->

## 适用场景

- 刚开始用 OpenClaw，不知道 `hooks` 到底是做什么的
- 想知道哪些 hook 值得开，哪些先别碰
- 想要一套适合新手的最小启用建议

## 先讲最通俗的话：hooks 是什么？

你可以把 `hooks` 理解成：

- 事件触发自动化

也就是说：

- 你在 OpenClaw 里做了某个动作
- 某个事件发生了
- 系统就自动跑一段预先配置好的处理逻辑

所以它不是“你手动调用的工具”，而是“系统在某个时机自动触发的动作”。

## 它和 tools 有什么区别？

这个边界最好先分清：

- `tools`：是 agent 主动拿来用的工具
- `hooks`：是系统在特定事件发生时自动帮你跑的动作

一句话说：

- `tools` 是“我现在要用”
- `hooks` 是“这件事一发生就自动做”

## hooks 常见能做什么？

官方内置 hook 的思路很典型，常见用途包括：

- 在 session 结束或切换时自动保存摘要
- 记录命令日志，方便审计和排障
- 在 bootstrap 时自动注入额外文件
- 在 Gateway 启动时自动执行一些初始化逻辑

这些都属于：

- 不是每次都值得手动做
- 但发生事件时又希望系统自动处理

## OpenClaw 自带的几个典型 hook

官方目前带的几个 hook，最常见的是下面这些：

### `session-memory`

- 在你发 `/new` 时，把当前 session 摘要写进 `workspace/memory/`
- 适合希望 OpenClaw 更有连续记忆的人

### `command-logger`

- 把命令记录到 `~/.openclaw/logs/commands.log`
- 适合排障、留痕、回头查执行历史

### `bootstrap-extra-files`

- 在 agent bootstrap 时自动注入额外文件
- 更偏高级配置

### `boot-md`

- Gateway 启动时运行 `BOOT.md`
- 更像高级自动化入口

## 小白到底该怎么选？

结论其实很简单：

- 0 个 hook 也完全能正常用 OpenClaw
- 第一个该开的 hook 是 `session-memory`
- 第二个才考虑 `command-logger`
- 其他先别碰

## 为什么第一个推荐 `session-memory`？

因为它同时满足几个条件：

- 作用直观
- 风险低
- 出问题代价小
- 对日常使用确实有帮助

它干的事非常容易理解：

- 你发 `/new`
- 系统自动把这段 session 摘要存下来

对新手来说，这类自动化很友好，因为你不需要先理解一堆系统内部机制。

## `command-logger` 值不值得开？

这个要看你自己有没有“留痕”和排障需求。

它适合：

- 想知道自己到底执行过哪些命令
- 想排查某次操作为什么出了问题
- 想保留一个基础审计记录

它的优点是：

- 行为简单
- 结果清晰

它的缺点也很直接：

- 会多出日志文件
- 如果你根本不看日志，它就只是增加存在感而已

所以它不是必须，但在小白可接受范围内。

## 为什么不推荐一上来就碰 `bootstrap-extra-files`？

因为这类 hook 虽然强，但也更容易把上下文搞复杂。

对小白来说，最常见的问题不是“能力不够”，而是：

- 还没理解系统结构
- 就先把初始化逻辑搞得很绕

这种情况下，一旦行为和预期不一致，你会很难判断到底是：

- prompt 问题
- workspace 问题
- 还是 hook 触发带来的副作用

所以这类 hook 更适合：

- 已经知道自己想注入什么
- 也知道为什么要这么做的人

## 为什么 `boot-md` 也不推荐新手先开？

原因类似。

`boot-md` 属于：

- Gateway 启动时自动做事

这对有明确启动流程的人很有用，但对刚上手的人来说，很容易变成：

- 系统每次启动都自动做了些什么
- 但自己又不知道是哪里触发的

这类自动化太早启用，排障成本会升高。

## 新手最稳的选择方案

如果你只是想要一个最不容易翻车的选择，直接按这个做：

### 情况 1：完全新手

- 什么都先别开
- 先把 Gateway、workspace、基本对话流程跑顺

### 情况 2：想让记忆更连续

- 开 `session-memory`

### 情况 3：想顺便留痕排障

- 开 `session-memory`
- 再加 `command-logger`

### 情况 4：还在摸索系统结构

- 先不要碰 `bootstrap-extra-files`
- 先不要碰 `boot-md`

## 最实用的命令清单

先看当前有哪些 hook：

```bash
openclaw hooks list
```

检查 hook 配置是否正常：

```bash
openclaw hooks check
```

查看某个 hook 的详细信息：

```bash
openclaw hooks info session-memory
```

启用推荐 hook：

```bash
openclaw hooks enable session-memory
```

再按需启用日志 hook：

```bash
openclaw hooks enable command-logger
```

如果想关掉某个 hook：

```bash
openclaw hooks disable command-logger
```

## 启用后要不要重启？

最稳妥的做法是：

- 启用或停用 hook 后，重启 Gateway

这样能确保 hooks 重新加载，避免出现“配置改了但当前进程还没感知到”的情况。

## 一个最通俗的生活化理解

你可以把 hooks 想成办公室里的自动规则：

- 有人下班离开时，系统自动关灯
- 有人打印时，系统自动记日志
- 新员工入职时，系统自动发一套资料

这些都不是“人主动拿工具来用”，而是：

- 某个事件发生时，系统自动做动作

OpenClaw hooks 就是同样的思路。

## 注意事项

- hooks 不是越多越好
- 新手最容易犯的错误，不是 hook 太少，而是开太多
- 先开“结果可见、逻辑直观、出问题代价低”的 hook
- 如果一个 hook 会让你说不清系统为什么这样做，那就先别开

## 一句话总结

对小白来说，OpenClaw hooks 最稳的用法不是“一上来全开”，而是先不开也没关系；如果要开，第一个开 `session-memory`，第二个再考虑 `command-logger`，其他会改变启动流程或 bootstrap 行为的 hook，等你真的有明确需求时再碰。

## 参考资料

- Automation：<https://docs.openclaw.ai/automation/>
- CLI hooks：<https://docs.openclaw.ai/cli/hooks>
