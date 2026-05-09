---
title: "Codex Automations 上手指南：让 Codex 按计划自动巡检、跟进和执行任务"
date: 2026-05-03T12:10:00+08:00
lastmod: 2026-05-03T12:10:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - OpenAI
tags:
  - Codex
  - Automations
  - OpenAI
  - AI 自动化
draft: false
description: "基于 OpenAI 官方 Codex 文档，梳理 Codex Automations 的工作方式、线程自动化与独立自动化区别、worktree 隔离和权限安全边界。"
aiSummary: "Codex Automations 是 Codex App 里用于定时执行后台任务的能力。你可以让 Codex 按计划巡检项目、轮询 PR、跟进部署或持续执行某个技能，同时通过 worktree、sandbox 和 rules 控制风险边界。"
aiKeyPoints:
  - "Codex Automations 的核心能力与适用场景"
  - "Thread automation 与 standalone automation 的区别"
  - "worktree、sandbox 与 rules 带来的安全边界"
faq:
  - q: "这篇文章讲什么？"
    a: "这篇文章基于 OpenAI 官方 Codex 文档，介绍 Codex Automations 的作用、常见场景、两类自动化的区别，以及实际使用时需要注意的权限和安全问题。"
  - q: "适合谁阅读？"
    a: "适合正在使用 Codex、希望把巡检、跟进、回访、代码检查和技能工作流自动化的开发者与团队。"
---

如果你已经在用 Codex 写代码、做 review 或查问题，那么很快就会碰到一个需求：有些事情不是“现在做一次”就够了，而是要让它隔一段时间自动回来再做一遍。OpenAI 在 Codex App 里提供的 `Automations`，就是专门解决这个问题的。

<!--more-->

它的核心思路很直接：把一个可重复的 Codex 任务挂上时间表，让它在后台按计划执行，执行结果回到 Codex 的收件箱里。如果没有新发现，也可以自动归档，不打扰你。

## Codex Automations 是什么

按照 OpenAI 官方文档的定义，`Automations` 用来调度周期性 Codex 任务，让它们在后台自动运行。

你可以把它理解成三件事的组合：

- 一段稳定可重复的 prompt
- 一套固定的执行环境与权限边界
- 一个定时触发的计划

Codex 跑完之后，会把有价值的结果放进 app 侧边栏里的 `Triage` 区域，也就是一个专门用来接收自动化结果的 inbox。

## 适合拿来自动化的事情

OpenAI 这页文档给出的方向非常实用，基本不是“炫技型自动化”，而是开发团队每天真的会反复做的事情。

比如：

- 定时检查一个长时间运行的命令是否结束
- 轮询 GitHub、Slack 或其他接入源，看有没有新的状态变化
- 固定节奏继续某个 review loop
- 跑一个 skill 驱动的工作流，比如检查 PR 状态并处理新增反馈
- 持续跟进一个研究、排障或 triage 任务

如果你平时已经在一个线程里反复说“半小时后再帮我看一下”“明早提醒我继续查这个 PR”“部署完成后告诉我”，那这些都很适合变成 automation。

## 两种自动化：最关键的区别

这页文档里最重要的概念，不是 schedule，而是自动化类型。

OpenAI 把它拆成两类：

### 1. Thread automation

这类自动化绑定当前线程，可以理解为“定时唤醒同一个对话”。

它的特点是：

- 保留当前线程上下文
- 每次执行都沿着这条对话继续
- 适合持续跟进同一件事

官方给出的典型用法包括：

- 检查一个长命令是否已经跑完
- 持续轮询 GitHub、Slack 等来源，但结果要留在同一条线程里
- 固定频率继续一个 review loop
- 用同一个线程持续推进研究或排障任务

如果你要的是“保持上下文连续性”，那就选它。

### 2. Standalone / project automation

这类自动化每次都是独立运行，更像一个按时启动的新任务。

它的特点是：

- 每次从新的运行开始
- 结果以单独 automation run 的形式出现在 `Triage`
- 更适合跨项目、批量巡检和独立报告

官方文档明确提到，这类自动化适合：

- 每次运行都应该相互独立
- 一个 automation 要跑多个项目
- 希望每次结果都作为独立记录保存

如果你想做的是“每天早上扫描项目变化并生成一份简报”，这类就比 thread automation 更合适。

## Git 项目里的 worktree 很关键

如果 automation 面向的是 Git 仓库，Codex 允许你选择两种运行方式：

- 在当前本地项目里运行
- 在新的 `worktree` 里运行

这不是一个小设置，而是风险控制的核心。

### 在当前项目里运行

优点是直接、方便，不需要额外隔离目录。

但缺点也很明显：

- 它可能改动你正在编辑的文件
- 和你当前未完成的本地工作互相影响
- 自动化结果更容易和人工改动混在一起

### 在 worktree 里运行

官方推荐的价值是把 automation 改动和你手头未完成的工作隔离开。

这样做的好处是：

- 自动化改动不会直接污染主工作目录
- 更适合频繁巡检、自动修复、周期性 review
- 更容易回看每次 automation run 的独立产出

如果你的自动化有任何“可能改代码”的行为，优先选 `worktree` 会更稳。

## 技能、插件和 Automations 可以组合起来

OpenAI 在这页文档里特别提到，automations 可以使用 Codex 里同样可用的：

- `skills`
- 插件
- 默认工具与 sandbox 配置

而且，你可以直接在 automation prompt 里写 `$skill-name` 来触发一个 skill。

这意味着什么？

意味着你不需要每次都把复杂步骤重新写一遍。更好的方式通常是：

1. 先把动作抽成 skill
2. 再让 automation 定时调用这个 skill

这样有两个好处：

- prompt 更短、更稳定
- 更容易在团队里共享、维护和复用

官方甚至举了一个很典型的例子：为 babysit pull request 的 skill 配一个定时 automation，自动检查 PR 状态并处理新 review feedback。

## 官方推荐的写法：先手动跑，再定时

这点非常值得照做。

OpenAI 明确建议，在把一个任务挂上 schedule 之前，先在普通线程里手动测试这段 prompt。主要是为了确认三件事：

- prompt 是否真的清晰、范围是否合理
- 默认或指定的模型、reasoning effort、工具是否合适
- 产出的 diff 是否可 review

这其实就是一个很成熟的工程思路：不要先自动化一个你自己都还没跑稳的流程。

## 权限和安全边界，别跳过

Automations 是后台无人值守执行，所以权限问题比普通对话更重要。

官方文档明确说，automations 会使用你的默认 sandbox 设置。

### 如果是 read-only

那么凡是需要下面这些能力的工具调用都会失败：

- 修改文件
- 访问网络
- 操作你电脑上的 app

这适合纯观察型任务，但很多真正有价值的自动化会受限。

### 如果是 workspace-write

这时 Codex 可以修改工作区内文件，但仍然不能：

- 改工作区外文件
- 访问网络
- 直接操作本机 app

这是一个相对平衡的默认选择。官方文档也提示，你可以配合 `rules` 选择性放行命令。

### 如果是 full access

这个模式最强，但风险也最高。因为后台自动化在这个模式下，可能会：

- 改文件
- 跑命令
- 访问网络
- 且不经过你当场确认

官方对这一点说得很直白：后台 automation 在 full access 下有更高风险。实践上更推荐 `workspace-write` 加有限放行，而不是一上来就全开。

## Thread automation 什么时候最有价值

我觉得最有价值的，不是“大而全”的自动化，而是那些你本来就会反复回来查看的任务。

例如：

- “每 10 分钟检查一次部署状态，直到成功后告诉我”
- “每隔 30 分钟看一下这个 PR 有没有新 review comment”
- “今晚每小时检查一次日志目录，看错误是否继续增长”

这类任务的共同点是：

- 需要上下文延续
- 需要多次回访
- 不适合每次都重新开题

这正是 thread automation 的强项。

## Standalone automation 更适合什么

如果你要的是周期性的、独立的一次性结果，它更适合。

比如：

- 每天早上生成项目最近 24 小时变更简报
- 每周检查某个目录最近的 commit 活动
- 每天扫描一个项目的 issue / PR 状态并汇总
- 定时跑某个 skill，对多个项目进行同类检查

这种场景下，每次运行本来就应该是相对独立的一份输出，因此 standalone 更自然。

## 使用时的几个注意事项

### 1. prompt 要写得“耐久”

官方对 thread automation 有一个很好的建议：prompt 要 durable。

也就是说，这段 prompt 不能只适用于“这一次”，而要清楚描述：

- 每次唤醒时要做什么
- 如何判断有没有重要发现
- 什么时候该汇报
- 什么时候该停止或向你提问

### 2. 高频 worktree 会堆积

文档里还提醒了一个容易被忽略的问题：如果你在 Git 仓库里用 worktree，而且 schedule 很频繁，时间一长会生成很多 worktree。

所以要定期：

- 归档不再需要的 automation runs
- 避免无意义地 pin 太多历史 run

### 3. 跨团队共享时尽量 skill 化

如果一个 automation 未来会给别人一起用，那最好别把所有逻辑都硬编码在一长段 prompt 里。

更稳的方式是：

- skill 负责动作定义、上下文和工具
- automation 负责调度

## 一句话总结

Codex Automations 的价值，不在于“让 AI 自己忙起来”，而在于把那些你本来就会反复回来检查、跟进和执行的工作，变成一个稳定、可调度、可隔离、可控风险的后台流程。

如果你已经在用 Codex，那么最值得先尝试的自动化，通常不是复杂的大系统，而是把一件你每天都会重复催一次的事，先交给它按计划做起来。

## 适用场景

- 需要 Codex 定时巡检项目、PR、Slack 或部署状态
- 需要持续跟进同一线程中的任务
- 想把 skill 变成可重复执行的后台流程

## 注意事项

- 会改代码的自动化优先放到 `worktree`
- 先手动验证 prompt，再上 schedule
- 默认优先考虑 `workspace-write`，谨慎使用 `full access`

## 一句话总结

把“回头再看一次”的重复性工作交给 Codex Automations，能比单次对话更接近真实团队里的持续协作流。

## 参考链接

- OpenAI 官方文档：<https://developers.openai.com/codex/app/automations>

<!--qr_code-->
