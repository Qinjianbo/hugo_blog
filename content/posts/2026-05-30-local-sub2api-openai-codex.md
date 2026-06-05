---
title: "本地 sub2api 配置 OpenAI 渠道，并让 Codex 走 sub2api"
date: 2026-05-30T00:00:00+08:00
lastmod: 2026-05-30T00:00:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - OpenAI
tags:
  - sub2api
  - Codex
  - OpenAI
  - Docker
draft: false
description: "记录本地 sub2api 添加 OpenAI 渠道，并配置 Codex CLI 通过 sub2api 调用模型的一套最小可用流程。"
aiSummary: "这篇文章整理了一套本地 sub2api 接入 OpenAI 并让 Codex CLI 通过 sub2api 调用模型的最小可用配置，包括 Docker 容器代理、OpenAI 上游账号、sub2api 用户 Key、curl 测试、Codex provider 配置和常见问题排查。"
aiKeyPoints:
  - "Docker 容器中的 sub2api 如何正确使用宿主机代理"
  - "sub2api 后台如何添加 OpenAI OAuth 或 API Key 渠道"
  - "Codex CLI 如何通过自定义 provider 走 sub2api 的 /v1/responses"
faq:
  - q: "这篇文章解决什么问题？"
    a: "解决本地已经搭建好 sub2api 后，如何添加 OpenAI 渠道，并让 Codex CLI 通过本地 sub2api 调用模型的问题。"
  - q: "为什么 Codex 配置里要关闭 WebSocket？"
    a: "因为 sub2api 通常兼容普通 HTTP 的 /v1/responses，而 Codex 默认可能尝试连接 ws://127.0.0.1:8080/v1/responses，容易出现 WebSocket 401 等问题。"
---

本文记录一套最小可用配置：本地已经搭建好 `sub2api`，目标是添加 OpenAI 渠道，然后让 Codex CLI 通过 sub2api 调用模型。

<!--more-->

整体链路如下：

```text
Codex CLI
   ↓
本地 sub2api: http://127.0.0.1:8080/v1
   ↓
OpenAI 上游账号 / OAuth 账号
   ↓
模型响应
```

## 一、给 sub2api 容器配置代理

如果 sub2api 是跑在 Docker 里的，不能直接使用：

```bash
127.0.0.1:7897
```

因为容器里的 `127.0.0.1` 指的是容器自己，不是宿主机。

应该在 `docker-compose.yml` 里配置：

```yaml
environment:
  - HTTP_PROXY=http://host.docker.internal:7897
  - HTTPS_PROXY=http://host.docker.internal:7897
  - ALL_PROXY=socks5://host.docker.internal:7897
  - http_proxy=http://host.docker.internal:7897
  - https_proxy=http://host.docker.internal:7897
  - all_proxy=socks5://host.docker.internal:7897
  - NO_PROXY=localhost,127.0.0.1
  - no_proxy=localhost,127.0.0.1
```

然后重启服务：

```bash
docker compose down
docker compose up -d
```

如果你本地使用的是 Clash、Mihomo 或 Clash Verge，需要确保代理软件允许局域网连接。

常见配置类似：

```yaml
allow-lan: true
mixed-port: 7897
```

或者在软件设置中开启：

```text
Allow LAN / 允许局域网连接
```

## 二、在 sub2api 后台添加 OpenAI 渠道

进入 sub2api 管理后台：

```text
AI 平台账号
→ 添加账号
→ 平台选择 OpenAI
```

如果使用 OAuth 账号，选择：

```text
账号类型：oauth
```

如果使用官方 OpenAI API Key，选择：

```text
账号类型：apikey
Base URL：https://api.openai.com
API Key：你的 OpenAI API Key
```

注意，上游 Base URL 建议填写：

```text
https://api.openai.com
```

不要填写：

```text
https://api.openai.com/v1
```

`/v1` 是客户端访问 sub2api 时使用的，不是这里上游账号的 Base URL。

## 三、测试 OpenAI 上游账号

在 sub2api 后台找到刚添加的 OpenAI 账号，点击测试。

如果测试结果类似：

```text
开始测试账号：free #2
账号类型：oauth
已连接到 API
使用模型：gpt-5.5
发送测试消息："hi"
响应：
Hi! What can I help you with?
测试完成！
```

说明 sub2api 已经可以正常访问 OpenAI 上游。

## 四、生成 sub2api 用户 Key

进入：

```text
用户管理
→ API Key 管理
→ 新建 Key
```

生成一个 sub2api 自己的用户 Key，例如：

```text
sk-xxxxxxxx
```

注意，这个 Key 不是 OpenAI 官方 Key，而是 sub2api 分发给客户端使用的 Key。

同时检查：

```text
用户余额 > 0
OpenAI 平台权限已开启
用户 Key 没有禁用
用户 Key 和 OpenAI 上游账号在同一个分组
```

最简单的做法是全部先放到：

```text
default
```

也就是：

```text
OpenAI 上游账号分组：default
用户分组：default
API Key 分组：default
```

## 五、用 curl 测试 sub2api

先测试 `/v1/responses`：

```bash
curl http://127.0.0.1:8080/v1/responses \
  -H "Authorization: Bearer 你的sub2api用户key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "input": "你好"
  }'
```

如果返回类似：

```json
{
  "status": "completed",
  "model": "gpt-5.5",
  "output": [
    {
      "type": "message",
      "role": "assistant",
      "content": [
        {
          "type": "output_text",
          "text": "你好！有什么我可以帮你的吗？"
        }
      ]
    }
  ]
}
```

说明 sub2api 的 OpenAI 渠道已经跑通。

也可以测试 Chat Completions：

```bash
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Authorization: Bearer 你的sub2api用户key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }'
```

## 六、配置 Codex 走 sub2api

编辑 Codex 配置文件：

```bash
mkdir -p ~/.codex
nano ~/.codex/config.toml
```

写入：

```toml
model = "gpt-5.5"
model_provider = "sub2api"

approval_policy = "on-request"
sandbox_mode = "workspace-write"

[model_providers.sub2api]
name = "Sub2API"
base_url = "http://127.0.0.1:8080/v1"
env_key = "OPENAI_API_KEY"
wire_api = "responses"
supports_websockets = false
```

这里有一个关键配置：

```toml
supports_websockets = false
```

因为 Codex 默认可能会尝试使用 WebSocket 连接：

```text
ws://127.0.0.1:8080/v1/responses
```

但 sub2api 通常兼容的是普通 HTTP 的 `/v1/responses`，所以这里要关闭 WebSocket。

## 七、设置 Codex 使用的 API Key

Codex 会从环境变量读取 Key：

```bash
export OPENAI_API_KEY="你的sub2api用户key"
```

如果想永久生效，可以写入 `~/.zshrc`：

```bash
nano ~/.zshrc
```

加入：

```bash
export OPENAI_API_KEY="你的sub2api用户key"
```

然后执行：

```bash
source ~/.zshrc
```

检查是否生效：

```bash
echo $OPENAI_API_KEY
```

## 八、启动 Codex 测试

如果你需要切换 Node 版本：

```bash
nvm use 22
```

然后启动 Codex：

```bash
codex -s danger-full-access
```

或者直接测试：

```bash
codex exec --model gpt-5.5 "你好"
```

如果 Codex 正常返回内容，说明已经成功走到：

```text
Codex → sub2api → OpenAI
```

## 常见问题

### 1. sub2api 返回 Service temporarily unavailable

一般检查：

```text
OpenAI 上游账号是否启用
上游账号测试是否通过
代理是否配置到 Docker 容器里
用户 Key 是否有余额
用户 Key 和上游账号是否在同一分组
模型名是否可用
```

### 2. Codex 报 Missing environment variable: OPENAI_API_KEY

说明当前终端没有设置环境变量。

执行：

```bash
export OPENAI_API_KEY="你的sub2api用户key"
```

然后重新启动 Codex。

### 3. Codex 报 WebSocket 401

如果看到类似：

```text
failed to connect to websocket: HTTP error: 401 Unauthorized
url: ws://127.0.0.1:8080/v1/responses
```

需要在 `~/.codex/config.toml` 里使用自定义 provider，并关闭 WebSocket：

```toml
supports_websockets = false
```

### 4. curl 可以通，但 Codex 不通

检查：

```bash
cat ~/.codex/config.toml
echo $OPENAI_API_KEY
```

同时查看 sub2api 日志：

```bash
docker compose logs -f --tail=100
```

如果日志里出现 `/v1/responses` 请求，说明 Codex 已经走到了 sub2api。

## 一句话总结

这套配置的关键点其实只有三个：Docker 容器里的 sub2api 要能通过宿主机代理访问 OpenAI，上游账号和用户 Key 要在 sub2api 里正确分组，Codex 侧要使用自定义 provider 并关闭 WebSocket，让请求稳定走普通 HTTP 的 `/v1/responses`。
