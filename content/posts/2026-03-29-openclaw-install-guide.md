---
title: OpenClaw 安装指南：官方 install 页面中文整理
date: 2026-03-29T20:21:40+08:00
lastmod: 2026-03-29T20:21:40+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - Agent
  - CLI
tags:
  - OpenClaw
  - Install
  - CLI
  - Node.js
  - pnpm
draft: false
description: 把 OpenClaw 官方 install 文档整理成中文安装教程，包含推荐安装脚本、npm 和 pnpm 安装、源码安装、校验命令以及常见 PATH 排障命令。
source_url: https://docs.openclaw.ai/install
---

如果你准备第一次把 OpenClaw 装到本地环境里，官方最推荐的入口就是 `install` 页面。这一页本质上是“安装总览”：先给最快可用的安装命令，再补充 npm、pnpm、源码安装、校验方法，以及装完后命令找不到时该怎么排查。下面是这篇官方文档的中文整理版，示例代码也一并保留下来。

<!--more-->

## 适用场景

- 想在 macOS、Linux、Windows 或 WSL2 上安装 OpenClaw
- 想直接照着官方推荐命令安装，而不是从零研究依赖关系
- 想把安装命令、校验命令和排障命令整理成一篇可复用笔记

## 官方推荐：优先用安装脚本

官方把安装脚本列为最推荐的方式，原因很直接：

- 会自动识别操作系统
- 如果本机没有合适的 Node 版本，会顺手处理
- 会安装 OpenClaw
- 安装完成后直接启动 onboarding

macOS、Linux 和 WSL2 推荐命令：

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

Windows PowerShell 推荐命令：

```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

如果你只想安装，不想安装后立刻进入 onboarding，官方给出的命令是：

macOS、Linux 和 WSL2：

```bash
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
```

Windows PowerShell：

```powershell
& ([scriptblock]::Create((iwr -useb https://openclaw.ai/install.ps1))) -NoOnboard
```

官方文档还特别说明：如果你需要更多 flag，或者准备在 CI、自动化脚本里使用安装器，应该继续看 `Installer Internals`。

## 系统要求

这页文档给出的系统要求很简洁：

- 推荐使用 Node 24
- 最低要求是 Node 22.14+
- 如果你走安装脚本路线，这部分通常会自动处理
- 支持 macOS、Linux、Windows
- Windows 原生和 WSL2 都支持，但官方明确提到 WSL2 更稳定
- `pnpm` 只有在你准备从源码构建时才是必需的

## 替代安装方式

如果你本来就自己管理 Node 环境，官方也给了不走安装脚本的几种方式。

## 1. 用 npm 或 pnpm 安装

如果你已经有现成的 Node 环境，可以直接全局安装：

使用 npm：

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

使用 pnpm：

```bash
pnpm add -g openclaw@latest
pnpm approve-builds -g
openclaw onboard --install-daemon
```

这里有一个官方特别提醒的点：

- `pnpm` 对带 build script 的包要求显式批准
- 所以第一次全局安装后，要补跑一次 `pnpm approve-builds -g`

### npm 安装时如果 `sharp` 报错怎么办？

官方给了一个很具体的处理方式：  
如果 `sharp` 因为全局安装的 `libvips` 出现构建问题，可以这样安装：

```bash
SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install -g openclaw@latest
```

## 2. 从源码安装

如果你是贡献者，或者就是想从本地 checkout 运行，官方示例是：

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install && pnpm ui:build && pnpm build
pnpm link --global
openclaw onboard --install-daemon
```

官方同时提到一个更轻的做法：

- 你也可以不做全局 link
- 直接在仓库目录里运行 `pnpm openclaw ...`
- 更完整的开发流程要看 `Setup` 文档

## 3. 直接安装 GitHub main 分支

如果你就是想装最新主干代码，install 页给出的命令是：

```bash
npm install -g github:openclaw/openclaw#main
```

这种方式适合明确知道自己要跟 `main` 走，而不是安装常规发布版本的人。

## 容器和包管理器部分，这一页讲了什么？

官方 install 页这里更像“索引入口”，不是完整教程。它列出了这些后续专题：

- Docker
- Podman
- Nix
- Ansible
- Bun

对应含义也很简短：

- Docker：适合容器化或无头部署
- Podman：作为 rootless 容器替代方案
- Nix：走声明式安装
- Ansible：适合批量自动化部署
- Bun：偏 CLI-only 使用场景，而且仍然是实验性路线

如果你要的是服务器部署，而不是个人本地安装，那么 install 页会把你继续分流到这些文档，而不是在这一页里展开。

## 安装完以后怎么确认成功？

官方给了 3 条最实用的校验命令：

```bash
openclaw --version      # confirm the CLI is available
openclaw doctor         # check for config issues
openclaw gateway status # verify the Gateway is running
```

这三条命令对应的是三个不同层级：

- `openclaw --version`：先确认 CLI 能不能被终端识别
- `openclaw doctor`：检查配置是否有明显问题
- `openclaw gateway status`：确认 Gateway 真的已经起来了

## 云端托管和运维，这页怎么组织？

这一页对托管部署也主要是入口导航，没有把步骤全写在 install 页面里。官方列出的部署目标包括：

- VPS
- Docker VM
- Kubernetes
- Fly.io
- Hetzner
- GCP
- Azure
- Railway
- Render
- Northflank

如果你的目标是“把 OpenClaw 装到服务器并长期跑”，install 页的作用主要是帮你跳转到对应平台的专项文档。

## 更新、迁移和卸载

install 页最后还把维护类操作统一归类出来：

- Updating：升级 OpenClaw
- Migrating：迁移到新机器
- Uninstall：彻底卸载

也就是说，这一页不是只讲“第一次安装”，它还是安装入口、维护入口和运维入口的总目录。

## 排障：安装成功了，但终端里找不到 `openclaw`

官方给出的判断路径很直接：

```bash
node -v           # Node installed?
npm prefix -g     # Where are global packages?
echo "$PATH"      # Is the global bin dir in PATH?
```

如果 `$(npm prefix -g)/bin` 不在你的 `PATH` 里，就把下面这一行加到 shell 启动文件里，比如 `~/.zshrc` 或 `~/.bashrc`：

```bash
export PATH="$(npm prefix -g)/bin:$PATH"
```

然后重新打开一个终端窗口。  
官方还建议这种情况继续参考 `Node.js` 安装说明页，因为很多“命令找不到”问题，本质上都是全局 bin 目录没有进 PATH。

## 注意事项

- 个人本地首次安装，优先用官方安装脚本，路径最短
- 如果你已经自己管理 Node 环境，再考虑 `npm` 或 `pnpm`
- 想跟最新主干代码走，可以直接装 GitHub `main`
- 如果你是开发者或贡献者，源码安装会更合适
- 容器、云平台、升级迁移这些内容，在 install 页里主要是导航入口，不是完整操作手册

## 一句话总结

OpenClaw 的 `install` 页面不是单纯丢一个安装命令，而是把“最快安装、替代安装、安装校验、PATH 排障、容器入口、云端部署入口”集中在一页里。对大多数人来说，先跑官方安装脚本，再用 `openclaw doctor` 和 `openclaw gateway status` 验证，已经是最稳的起点。

## 原文链接

- 官方文档：<https://docs.openclaw.ai/install>
