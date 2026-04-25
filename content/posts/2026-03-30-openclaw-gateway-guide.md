---
title: OpenClaw Gateway 有什么用？怎么配置、怎么检查状态
date: 2026-03-30T22:34:24+08:00
lastmod: 2026-03-30T22:34:24+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - Agent
  - 实用教程
tags:
  - OpenClaw
  - Gateway
  - CLI
  - 运维
draft: false
description: 把 OpenClaw Gateway 的作用、典型链路、配置方式和状态检查命令整理成一篇中文教程，帮助你快速理解本地与远程 Gateway 的使用方式。
source_url: https://docs.openclaw.ai/cli/gateway
---

刚开始接触 OpenClaw 时，很多人会把 `Gateway` 和 `Agent` 混在一起。其实这两层分工完全不同。`Agent` 负责理解问题和干活，`Gateway` 负责收消息、分发消息、管理连接和维护会话。这篇文章把我们刚刚讨论过的内容整理成一版更适合中文阅读的教程，重点讲清楚 `Gateway` 到底有什么用、怎么配置，以及怎么检查它是不是正常运行。

<!--more-->

## 适用场景

- 刚开始用 OpenClaw，不清楚 `Gateway` 和 `Agent` 的区别
- 想知道为什么本地 CLI、网页、手机节点、消息渠道都要先连到 Gateway
- 想快速学会 `Gateway` 的配置命令、启动命令和状态检查命令

## 先用一句人话理解：Gateway 是什么？

你可以把 OpenClaw 的几层关系理解成这样：

- `Agent` 像真正干活的人
- `Gateway` 像总前台、总机和调度室

它主要做 4 件事：

- 收消息
- 认人和分流
- 管连接和会话
- 把结果转发回去

所以它不是负责“思考”的那一层，而是负责“接单、分单、回单”的那一层。

## 为什么 OpenClaw 需要 Gateway？

如果没有 Gateway，系统会很快变乱：

- Telegram 要自己接一套
- WhatsApp 要自己接一套
- 网页聊天要自己接一套
- 手机 App 和 CLI 还得各自再接一套

有了 Gateway 以后，所有入口先统一进一个中心，再由它把任务转给 agent。  
这样会有几个直接好处：

- 多个聊天渠道不需要各自维护一整套会话逻辑
- 本地 CLI、Web UI、macOS App、移动节点都能共用同一个入口
- 会话路由、鉴权、健康检查、长连接状态都有统一出口
- 远程部署时，你只需要把客户端接到 Gateway，而不是让每个客户端单独碰底层渠道

## 一个最容易懂的链路图

```text
你 / 别人
  |
  | 发消息
  v
Telegram / WhatsApp / 网页 / 手机 App / CLI
  |
  | 全部先连到
  v
+----------------------+
|   OpenClaw Gateway   |
|  收消息 / 认人 / 分流  |
|  管连接 / 管会话 / 鉴权 |
+----------------------+
          |
          | 把任务交给
          v
+----------------------+
|        Agent         |
|   理解问题 / 调工具   |
|   生成回复 / 执行动作 |
+----------------------+
          |
          | 结果返回
          v
+----------------------+
|   OpenClaw Gateway   |
+----------------------+
          |
          | 转发回去
          v
Telegram / WhatsApp / 网页 / 手机 App / CLI
```

一句话总结这张图：

- `Agent` 负责“想”
- `Gateway` 负责“接、转、管”

## 本地场景下，Gateway 通常怎么用？

如果你只是自己本机用，最常见的链路是：

```text
你在电脑上用 CLI / 网页
        |
        v
127.0.0.1:18789 上的 Gateway
        |
        v
本机的 Agent
        |
        v
工具、文件、模型
```

这种模式下，Gateway 通常只监听本地 loopback，也就是：

```text
127.0.0.1:18789
```

优点很直接：

- 安全边界更简单
- 不需要先考虑公网暴露
- 适合单机使用和本地开发

## 远程场景下，Gateway 又是什么角色？

如果你把 OpenClaw 部署在远程服务器上，情况会变成：

```text
你的电脑 / 手机
      |
      | 远程连接
      v
远程服务器上的 Gateway
      |
      v
远程服务器上的 Agent
      |
      v
远程服务器上的工具、文件、模型
```

这时候本地 CLI 或手机并不是直接在连 agent，而是先连远程 Gateway，再由 Gateway 去调远程 agent。

这也是为什么官方 onboarding 文档里一直强调：

- `Remote mode` 只是配置本地客户端去连接一个已经存在的 Gateway
- 它不会顺手替你在远端安装所有东西

## 怎么配置 Gateway？

最简单的方式是走官方交互式配置：

```bash
openclaw configure
```

如果你只想改 Gateway 相关配置，重点通常就是这一项：

```bash
gateway.mode
```

可以先看当前值：

```bash
openclaw config get gateway.mode
```

再按需要切换：

```bash
openclaw config set gateway.mode local
```

或者：

```bash
openclaw config set gateway.mode remote
```

对大多数人来说：

- 单机使用，选 `local`
- 连接远端已有 Gateway，选 `remote`

## 怎么直接启动 Gateway？

本地直接运行：

```bash
openclaw gateway
```

或者显式写成：

```bash
openclaw gateway run
```

如果你只是临时想覆盖一些参数，可以直接在命令行里带：

```bash
openclaw gateway --port 18789 --bind loopback --auth token
```

这里面最常见的几项含义是：

- `--port`：监听端口
- `--bind`：绑定地址，比如只绑 loopback
- `--auth`：认证方式，比如 token

## 怎么把 Gateway 作为后台服务管理？

OpenClaw 的 CLI 里也提供了标准的管理命令：

```bash
openclaw gateway start
openclaw gateway stop
openclaw gateway restart
openclaw gateway install
openclaw gateway uninstall
```

这些命令适合长期运行场景。  
比如你不想每次手工启动，就可以走 `install` 把它装成后台服务。

## 怎么检查 Gateway 的状态？

最常用的一条就是：

```bash
openclaw gateway status
```

这个命令不是只看“进程在不在”，而是通常会看两层：

- 后台服务层状态
- Gateway 本身能不能正常响应

如果你想让输出更适合脚本处理，可以用：

```bash
openclaw gateway status --json
```

如果你希望 RPC 探测失败时直接返回非 0 退出码，用：

```bash
openclaw gateway status --require-rpc
```

如果你只想看服务状态，不做实际探测，可以用：

```bash
openclaw gateway status --no-probe
```

## 如果状态不对，先用什么命令排查？

最值得先跑的是：

```bash
openclaw gateway probe
```

它更像是一次连通性探测，能帮助你判断：

- 当前配置的 Gateway 能不能连通
- 本地 loopback Gateway 能不能响应

如果你只想做更轻量的健康检查，可以用：

```bash
openclaw gateway health --url ws://127.0.0.1:18789
```

这个命令适合快速验证某个明确地址上的 Gateway 是否正常。

## 一个最小可用流程

如果你只是本机想先把 Gateway 跑起来，最短路径通常是这样：

1. 运行配置向导

```bash
openclaw configure
```

2. 确认 Gateway 模式

```bash
openclaw config get gateway.mode
```

3. 启动 Gateway

```bash
openclaw gateway
```

4. 检查状态

```bash
openclaw gateway status
```

5. 如果还有问题，进一步探测

```bash
openclaw gateway probe
```

## 常见理解误区

- `Gateway` 不是模型本身，也不是 agent 本身
- `Gateway` 不负责思考，它负责连接、路由和状态管理
- `workspace` 也不在 Gateway 里“自动同步”，它跟 Gateway 所在主机相关
- 远程模式不是远程自动部署，它只是让本地客户端连接远程已有 Gateway

## 注意事项

- 本地单机使用时，优先绑定 loopback，更稳也更安全
- 如果要远程访问，记得同时考虑认证方式，不要只顾着开端口
- `status` 看的是“有没有活着”，`probe` 更接近“能不能真的连通”
- 真正的生产问题，通常不是命令不会敲，而是把 `local` / `remote`、监听地址、认证方式和运行主机搞混了

## 一句话总结

OpenClaw 的 `Gateway` 本质上是整个系统的总入口和调度中心。CLI、网页、移动节点和消息渠道不是直接连 agent，而是先连 Gateway，再由 Gateway 把任务路由给 agent。实际使用时，记住三件事就够了：先配 `gateway.mode`，再启动 `openclaw gateway`，最后用 `openclaw gateway status` 和 `openclaw gateway probe` 检查状态。

## 参考资料

- CLI Gateway：<https://docs.openclaw.ai/cli/gateway>
- Configure：<https://docs.openclaw.ai/zh-CN/cli/configure>
- Gateway Network Model：<https://docs.openclaw.ai/gateway/network-model>
- Architecture：<https://docs.openclaw.ai/architecture>
