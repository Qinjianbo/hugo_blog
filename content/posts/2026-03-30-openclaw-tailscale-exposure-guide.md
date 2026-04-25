---
title: OpenClaw Tailscale Exposure 是什么？一篇讲清 off、serve、funnel
date: 2026-03-30T22:52:04+08:00
lastmod: 2026-03-30T22:52:04+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - Agent
  - 实用教程
tags:
  - OpenClaw
  - Tailscale
  - Gateway
  - 网络
draft: false
description: 把 OpenClaw 的 Tailscale exposure 功能整理成一篇中文说明，讲清 off、serve、funnel 三种模式的区别，以及它和 gateway.bind tailnet 的边界。
source_url: https://docs.openclaw.ai/gateway/tailscale
---

很多人第一次看到 OpenClaw 里的 `Tailscale exposure`，会以为它只是“开个远程访问开关”。其实它更准确的作用是：让 `Gateway` 通过 Tailscale 对外提供访问入口。真正容易混淆的地方，不是能不能访问，而是 `off`、`serve`、`funnel` 分别意味着什么，以及它和 `gateway.bind: "tailnet"` 根本不是一回事。这篇文章把这些点一次讲清楚。

<!--more-->

## 适用场景

- 想让手机、另一台电脑或远程节点访问你本机上的 OpenClaw
- 已经在用 Tailscale，但不清楚 OpenClaw 里的 `Tailscale exposure` 到底暴露了什么
- 想快速理解 `off`、`serve`、`funnel` 三种模式的区别

## 先讲一句最通俗的话：这个功能是干什么的？

`Tailscale exposure` 的作用就是：

- 让 OpenClaw 的 `Gateway` 可以通过 Tailscale 被别的设备访问

默认情况下，Gateway 往往只监听本机：

```text
127.0.0.1:18789
```

这意味着：

- 当前这台机器自己能访问
- 其他设备默认访问不到

而开启 `Tailscale exposure` 之后，Tailscale 会帮你把这个 Gateway 暴露给别的设备访问。

## 最简单的设备示例

假设你有这几个设备：

- 家里一台 Mac，OpenClaw 跑在上面
- 公司一台 Windows 笔记本
- 一部手机
- 这三台设备都登录了同一个 Tailscale 网络

这时候就能很容易看懂三种模式。

## 情况一：不开 Tailscale exposure

如果不开，Gateway 只在本机开放：

```text
127.0.0.1:18789
```

结果就是：

- Mac 自己能用
- Windows 访问不了
- 手机也访问不了

这就像：

- 你把办公室门锁死了，只允许坐在房间里的人自己进出

## 情况二：开 `serve`

这是最推荐的日常模式。

效果会变成：

- 你的 Windows 笔记本可以通过 tailnet 访问这台 Mac 上的 Gateway
- 你的手机也可以访问
- 但公网陌生人进不来

这就像：

- 你没有把办公室开到大街上
- 只是给“同一个内网门禁系统里的人”开了门

换句话说：

- `serve` 是把访问范围控制在你的 Tailscale 私有网络里

## 情况三：开 `funnel`

`funnel` 的含义就更激进了：

- 不是只给 tailnet 里的设备访问
- 而是直接把入口暴露到公网

所以风险明显更高。  
官方文档也因此要求：

- 如果你用 `funnel`，必须配 `password` 认证

这就像：

- 你不只是给公司内网员工开门
- 而是把办公室前台直接开到了街边
- 理论上路人也能找到入口，只是还要再过认证

## 三种模式，用一句话记住

- `off`：只有当前机器自己能访问
- `serve`：只有你 Tailscale 网络里的设备能访问
- `funnel`：公网也能找到这个入口

如果只是个人远程使用，优先考虑：

```text
serve
```

## 它和 `gateway.bind: "tailnet"` 有什么区别？

这个点特别容易搞混。

两者不是一回事：

- `tailscale.mode: "serve"` / `"funnel"`：是让 Tailscale 帮你做代理入口和转发
- `gateway.bind: "tailnet"`：是 Gateway 自己直接监听 Tailscale IP

也就是说：

- 前者更像“让 Tailscale 替你对外接客”
- 后者更像“Gateway 自己直接开在 tailnet 地址上”

所以不要把这两个配置当成同义词。

## 什么时候该用 `serve`？

最典型的场景就是：

- 你在家里一台机器上跑 OpenClaw
- 想在公司电脑、另一台笔记本、手机上继续访问
- 但不想直接暴露公网端口

这种时候：

- `serve` 最自然
- 安全边界也最容易理解

## 什么时候才该用 `funnel`？

只有在你明确知道自己需要“公网可访问入口”时，才考虑它。

比如：

- 你不只是自己设备之间互联
- 而是有必须经由公网访问的需求

这种模式下，认证一定不能偷懒。  
官方也明确要求用：

```text
password
```

## CLI 怎么开？

官方 CLI 示例可以写成这样：

```bash
openclaw gateway --tailscale serve
```

或者：

```bash
openclaw gateway --tailscale funnel --auth password
```

这两个命令分别对应：

- 在 tailnet 内暴露
- 通过公网暴露，并强制使用密码认证

## 配置文件怎么写？

如果你更习惯写配置文件，可以参考这种形式：

```json5
{
  gateway: {
    bind: "loopback",
    tailscale: { mode: "serve" },
  },
}
```

这个配置表达的意思是：

- Gateway 本体还是绑在 loopback
- 由 Tailscale 提供额外访问入口

## 最实用的选型建议

如果你只是个人使用，直接按这个判断就行：

- 只在本机用：`off`
- 自己多设备远程访问：`serve`
- 真要让公网进来：`funnel`

如果你不确定自己是不是需要 `funnel`，那大概率就不需要。

## 一个最短的生活化总结

可以直接记成这三句：

- 不开 exposure：只有你坐在这台机器前面才能用
- 开 `serve`：你的自己人能远程用
- 开 `funnel`：全世界都能找到这个入口

## 注意事项

- `serve` 通常比 `funnel` 更适合日常个人使用
- 不要把 `Tailscale exposure` 和 `bind: tailnet` 当成同一个开关
- 需要公网暴露时，认证一定要加强
- 如果你只是想让自己的设备互联，没必要为了“能远程”直接走公网

## 一句话总结

OpenClaw 的 `Tailscale exposure` 不是简单的“远程访问开关”，而是让 `Gateway` 通过 Tailscale 提供访问入口。实际使用时，记住三件事就够了：`off` 只给本机，`serve` 给 tailnet，`funnel` 给公网；而且它和 `gateway.bind: "tailnet"` 不是一回事。

## 参考资料

- Tailscale：<https://docs.openclaw.ai/gateway/tailscale>
- CLI Gateway：<https://docs.openclaw.ai/cli/gateway>
