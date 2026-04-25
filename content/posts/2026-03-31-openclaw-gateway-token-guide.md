---
title: OpenClaw Gateway Token 有什么作用？一篇讲清它和 password 的区别
date: 2026-03-31T22:28:12+08:00
lastmod: 2026-03-31T22:28:12+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - Agent
  - 实用教程
tags:
  - OpenClaw
  - Gateway
  - Token
  - 认证
draft: false
description: 把 OpenClaw Gateway token 的作用、典型使用场景，以及它和 password、setup token 的区别整理成一篇中文说明。
source_url: https://docs.openclaw.ai/cli/gateway
---

很多人看到 OpenClaw 里的 `Gateway token`，第一反应会是“是不是类似 API Key”。这个理解不算错，但还不够准确。更通俗地说，`Gateway token` 是 Gateway 的门禁卡。谁想连上 Gateway，先得证明自己手里有这张卡。这篇文章把它的作用、为什么连本机 localhost 也默认需要 token、以及它和 `password`、`setup token` 的区别一次讲清楚。

<!--more-->

## 适用场景

- 刚开始用 OpenClaw，不清楚 `Gateway token` 到底是干什么的
- 想知道为什么本机 `localhost` 也默认要 token
- 想搞明白 `Gateway token`、`password` 和 `setup token` 之间的区别

## 先讲一句最通俗的话：Gateway token 是什么？

可以直接把它理解成：

- OpenClaw Gateway 的访问口令

谁想连接 Gateway，先要过这一关：

- 证明自己持有正确 token

没有 token，就不能调用这个 Gateway 提供的能力。

## 用生活化的比喻理解

如果把 OpenClaw 想成一家公司：

- `Agent` 是真正干活的人
- `Gateway` 是前台
- `Gateway token` 就是前台门禁卡

别人想进来办事，不是直接冲进办公室，而是先到前台刷卡。  
卡不对，前台就不放人进来。

所以它不是“让 agent 更聪明”的东西，而是“控制谁能接入 Gateway”的东西。

## 它到底保护了什么？

`Gateway token` 保护的是：

- 谁可以连接 Gateway
- 谁可以通过 Gateway 发请求
- 谁可以调用 Gateway 暴露出的能力

这些能力通常包括：

- Web UI / Control UI 连接 Gateway
- `openclaw tui`
- `openclaw node run`
- 远程 CLI 连接远端 Gateway
- OpenResponses HTTP API 调用 Gateway

也就是说，token 控制的是“入口权限”。

## 为什么本机 localhost 也默认要 token？

这点很多人会觉得反直觉：

- 明明只绑在 `127.0.0.1`
- 为什么还要 token？

原因很简单：

- `localhost` 只表示“别的机器连不到”
- 不代表“这台机器上的其他进程连不到”

OpenClaw 默认连本机也要求 token，就是为了防止：

- 同一台机器上的其他程序偷偷连接你的 Gateway
- 本地恶意脚本或不受信进程直接调用你的 OpenClaw

所以它的防护对象不只是“外部网络”，也包括“本机其他进程”。

## 如果我没手动设置 token，会发生什么？

官方文档提到一个很关键的行为：

- 如果你没有手动配置 token
- Gateway 启动时通常会自动生成一个 token
- 然后把它写到 `gateway.auth.token`

也就是说，OpenClaw 并不是默认“裸奔”。

## 什么时候 token 尤其重要？

如果 Gateway 不只是绑在 loopback，而是暴露给更大范围，比如：

- `tailnet`
- 局域网
- 其他可远程访问的地址

那 token 就更重要了。

因为这时候已经不是“只有本机进程可能碰到你”，而是：

- 其他设备也有机会访问你的 Gateway

所以官方才会强调：

- 非 loopback 绑定必须有共享认证

## 最常见的相关配置

最常见的配置就是这两项：

```text
gateway.auth.mode: "token"
gateway.auth.token: "<your-token>"
```

如果你想从环境变量传，也可以：

```bash
export OPENCLAW_GATEWAY_TOKEN="<your-token>"
```

## 它和 `password` 有什么区别？

这两个都属于 Gateway 认证方式，但定位不完全一样。

可以这样理解：

- `token` 更像程序间使用的访问口令
- `password` 更像给人类登录或远程访问时使用的密码

在很多自动化或客户端接入场景里：

- `token` 更常见

而在需要更明确的人工认证场景里：

- `password` 会更自然

比如前面我们聊过的 `Tailscale funnel`，官方就要求：

- 必须使用 `password` 认证

所以这两者不是互相叠加，而是 Gateway 的不同认证模式。

## 它和 `setup token` 又有什么区别？

这个也很容易搞混。

最简单的区别是：

- `Gateway token`：是“连接 Gateway 的门禁口令”
- `setup token`：更偏向首次引导、初始配对、setup 流程里的口令

换句话说：

- 一个是长期“进门凭证”
- 一个是某些初始化流程里的“临时接入凭证”

所以不要把它们当成同一个东西。

## 一个最通俗的场景例子

假设你家里一台 Mac 跑着 OpenClaw，Gateway 开在：

```text
127.0.0.1:18789
```

这时候你在浏览器里打开 Control UI，或者用 CLI 去连 Gateway。  
如果配置的是 token 模式，那么流程可以理解成：

1. 你发起连接
2. Gateway 先问：“你的门禁卡呢？”
3. 客户端把 token 带上
4. Gateway 核对通过，才允许继续操作

如果 token 不对：

- 你就算知道地址
- 也进不去

## 为什么它不是“多此一举”？

很多人会觉得：

- 只在本机用
- 还要 token
- 是不是太麻烦

但从安全角度看，这反而是更稳的默认值。

因为真正危险的情况往往不是：

- 黑客从公网直接打进来

而是：

- 本机上某个你没注意的进程顺手把 Gateway 调起来了

所以这个 token，本质上是在给 Gateway 加一道最基本的访问控制。

## 什么时候该优先用 token？

一般来说，这些场景更适合 token：

- 本机客户端连接本机 Gateway
- 远程 CLI 连接远端 Gateway
- 节点、自动化工具、API 客户端接入 Gateway

如果你问最短建议，可以直接记：

- 自动化、客户端接入，优先 `token`
- 明确的人类交互认证场景，再考虑 `password`

## 注意事项

- 不要把 `Gateway token` 当成模型 API Key，它们不是一层东西
- `localhost` 不等于安全，token 仍然有意义
- 如果 Gateway 绑定到非 loopback，认证就更不能省
- `Gateway token` 和 `setup token` 不是一回事

## 一句话总结

OpenClaw 的 `Gateway token` 本质上就是 Gateway 的门禁卡。谁想连上 Gateway，先拿出正确 token。它的作用不是提升 agent 能力，而是控制谁能进入 Gateway 并调用它的功能；而且它不仅防外部设备，也防本机其他进程。

## 参考资料

- CLI Gateway：<https://docs.openclaw.ai/cli/gateway>
- Gateway Network Model：<https://docs.openclaw.ai/gateway/network-model>
- Nodes：<https://docs.openclaw.ai/nodes>
- OpenResponses HTTP API：<https://docs.openclaw.ai/gateway/openresponses-http-api>
