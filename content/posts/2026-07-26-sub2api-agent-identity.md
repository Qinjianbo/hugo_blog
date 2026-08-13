---
title: "Sub2API 最新 Agent Identity 模式：为什么 Codex 账号接入开始从 OAuth Token 转向本地签名"
date: 2026-07-26T17:01:16+08:00
lastmod: 2026-07-26T17:01:16+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - 工具
tags:
  - Sub2API
  - Codex
  - OpenAI
  - Agent Identity
  - API 网关
draft: false
description: "结合 Sub2API 最新 release 与当前源码，梳理 Agent Identity 模式的核心逻辑：从保存 OAuth Token 转向保存 agent_runtime_id 与本地 Ed25519 私钥，并分析它的体验变化和风险边界。"
---

Sub2API 最近的 OpenAI / Codex 账号接入里，一个值得关注的变化是 `Agent Identity` 模式。它的用户侧感知很直接：相比传统 OAuth session、access token、refresh token 导入，Agent Identity 更像是把一个已经注册好的“Agent 身份”交给网关，由网关在每次请求时动态签名。

<!--more-->

这篇文章只做公开资料和源码层面的学习整理，不提供绕过登录、批量注册账号、规避风控、滥用免费账号或提取他人凭据的方法。账号、Session、JWT、私钥都属于敏感凭据，应只在自己拥有和授权的环境里使用。

## 先说结论

Sub2API 当前最新 release 是 `v0.1.165`，GitHub release 说明主要写的是 ChatGPT Live 网关、Anthropic 新模型适配、用量记录和若干 bug fix。虽然 release note 没有把 Agent Identity 单独拎出来讲，但当前 `main` 分支源码里已经能看到完整的 Agent Identity 支持。

从源码看，Sub2API 对 Agent Identity 的定位不是继续保存 OpenAI OAuth access token 或 refresh token，而是导入一份 Codex Agent Identity `auth.json`：

- 前端文案明确写着：导入 Codex Agent Identity `auth.json`，不保存 OAuth access token 或 refresh token。
- 后端要求 `auth_mode=agentIdentity`。
- 后端保存 `agent_runtime_id`、`agent_private_key`、账号 ID、用户 ID 等字段。
- 私钥格式会被校验为 PKCS#8 Ed25519。
- 每次上游请求都会动态生成签名认证，而不是沿用 Bearer Token。

这也是为什么社区会把它描述成“有效 Session -> 校验 JWT -> 生成 Ed25519 密钥对 -> 注册 Runtime -> 保存 agent_runtime_id 与本地私钥 -> 生成 Agent Identity”。Sub2API 这一侧更准确地说，是消费这个已经形成的 Agent Identity，并在请求时用它完成动态签名。

## Sub2API 是什么

Sub2API 项目自己的定位是：

> AI API Gateway Platform for Subscription Quota Distribution

中文 README 里也写得很直接：它是一个“AI API 网关平台 - 订阅配额分发管理”。项目 README 同时有醒目的风险提示：使用项目可能违反上游服务商条款，项目仅供技术学习与研究，风险由使用者自行承担。

所以理解它时要把两个层面分开：

- 技术层面：它是一个多上游、多账号、多分组、多协议适配的 API 网关。
- 合规层面：订阅账号转 API、账号共享、代理调度、免费账号使用等都可能触碰上游服务条款和风控规则。

这篇文章讨论的是技术结构，不代表建议在生产或商业场景中这么使用。

## 传统 OAuth Token 模式的问题

传统接入方式通常围绕这些凭据工作：

- Web Session
- access token
- refresh token
- id token

这种模式的优势是简单：拿到 token 后，网关可以用 `Authorization: Bearer ...` 形式请求上游。

问题也很明显：

- access token 有过期时间。
- refresh token 是高敏感长期凭据。
- 一旦网关数据库泄露，影响面很大。
- 上游可以根据 token 生命周期、刷新行为、设备和网络特征做风控。
- 多账号、多节点、多请求并发时，token 刷新和失效处理会变复杂。

所以 Agent Identity 模式的核心变化不是“更神秘”，而是把长期 OAuth 凭据从请求认证路径里移走，换成 runtime id + 本地私钥的签名模型。

## Agent Identity 模式的核心链路

按社区流传的抽象流程，可以理解为：

```text
有效 Web Session / access_token
-> 校验账号与 JWT 信息
-> 本地生成 Ed25519 密钥对
-> 向服务端登记这个 Agent Runtime 的公钥
-> 服务端返回 agent_runtime_id
-> 本地保存 agent_runtime_id 与私钥
-> 后续请求用私钥生成 Agent Identity 签名
```

这里最重要的是两个东西：

- `agent_runtime_id`：服务端识别这个 Agent Runtime 的 ID。
- `agent_private_key`：本地保存的 Ed25519 私钥，用来给后续请求签名。

也就是说，后续请求不再依赖“拿一个 access token 去当 Bearer Token”，而是由本地私钥签出一个短时认证声明。Sub2API 源码里也能看到，Agent Identity 分支会构造类似 `AgentAssertion` 的认证头。

## Sub2API 源码里能看到什么

当前源码里几个点很清楚。

第一，前端支持导入 Agent Identity。

中文文案里写着：

- `Agent Identity auth.json`
- `导入 Codex Agent Identity auth.json，不保存 OAuth access token 或 refresh token。`
- `文件必须使用 auth_mode=agentIdentity；每次上游请求都会动态签名。`

第二，后端导入时会识别 `agent_identity` 或 `auth_mode=agentIdentity`。

导入逻辑会读取：

- `agent_runtime_id`
- `agent_private_key`
- `task_id`
- `account_id`
- `chatgpt_user_id`
- `email`
- `plan_type`

如果缺少 runtime id、私钥、账号 ID、用户 ID，就会报“agent identity 缺少必要字段”。

第三，私钥不是随便一段字符串。

后端会把 `agent_private_key` 当作 base64 编码的 PKCS#8 私钥解析，并确认它是 Ed25519 私钥。也就是说，这不是普通 token，而是一套非对称密钥身份。

第四，每次请求动态签名。

源码注释里有一句很关键：

> Agent Identity signs a fresh assertion here; OAuth/PAT/API-key keep their existing Bearer behavior.

也就是 Agent Identity 分支会生成新的签名声明；OAuth、PAT、API key 仍然走传统 Bearer 行为。

第五，task 失效时会自动恢复。

源码里有 `task_id` 注册、失效识别、恢复和 WebSocket 连接失效处理。它会识别 `invalid_task_id`、`task_not_found`、`task_expired` 这类错误，然后尝试重新注册 task 并更新本地凭据。

## 为什么会被说成“无需接码”

“任何账号都无需接码，包括 free”这个说法，应该理解成 Agent Identity 模式下的用户侧体验变化：如果已经有有效 Web Session 或可用的本地授权材料，后续网关接入阶段不再围绕短信验证码或二次登录流程展开，而是围绕本地 Agent Identity 文件导入和签名认证展开。

但这不等于账号体系没有风控，也不等于可以绕过登录、地区、手机号、设备、滥用检测或上游条款。更准确的说法是：

- 接入 Sub2API 时，不再保存 OAuth access token / refresh token。
- 请求认证时，不再每次拿 OAuth Bearer Token 直接转发。
- 上游仍然可以基于账号状态、runtime、task、请求行为、网络环境、免费/付费权益做校验。

所以它解决的是“网关如何代表一个 Agent Runtime 发起请求”的认证形态，不是“账号可以不受限制使用”。

## 这种模式的优点

从工程角度看，Agent Identity 有几个明显优点。

第一，长期 OAuth Token 暴露面变小。

Sub2API 的前端文案明确说不保存 OAuth access token 或 refresh token。对网关来说，这是一个重要的敏感面收缩。

第二，每次请求可以短时签名。

签名里可以包含 runtime、task、时间戳等信息。相比长期 Bearer Token，它更接近“设备身份 + 当前任务”的认证模型。

第三，适合 Agent 场景。

Codex、Claude Code、Gemini CLI 这类工具都不是传统网页聊天，它们更像长期运行的本地开发 Agent。Agent Identity 把“谁在请求”从单纯用户 token，细化到 runtime 和 task，对后续限流、追踪、风控都更自然。

第四，Sub2API 可以更好地区分账号类型。

源码和 UI 里已经把 OAuth、PAT、API Key、Agent Identity 分开处理。不同认证模式走不同生命周期和错误恢复逻辑，后续可维护性更好。

## 风险和边界

Agent Identity 并不意味着没有风险，只是风险形态变了。

最重要的风险是私钥泄露。

如果 `agent_private_key` 被泄露，别人就可能伪装成这个 Agent Runtime 发起请求。它虽然不是 OAuth refresh token，但仍然是高敏感凭据。

其次是账号共享和订阅转 API 的合规风险。

Sub2API README 已经提示，使用项目可能违反上游服务商条款。尤其是把个人订阅、免费账号、团队账号包装成对外 API 服务时，风险会进一步放大。

第三是免费账号的风控风险。

即使 Agent Identity 让接入环节更顺滑，上游仍然可以通过额度、模型权限、并发、行为特征、IP、设备、runtime、task 等维度做限制。free 账号能不能稳定使用，最终还是由上游策略决定，不应把它理解成稳定资源池。

第四是网关运营风险。

如果网关面向多人开放，管理员需要考虑：

- 私钥加密存储
- 数据库访问权限
- 日志脱敏
- API key 权限隔离
- 账号分组隔离
- 限流与并发控制
- 用户滥用审计
- 上游异常和封禁风险

Sub2API 源码里已经能看到对 Agent Identity 敏感字段做日志脱敏的处理，包括 `agent_private_key`、`agent_runtime_id`、`task_id`、token、API key 等字段。

## 对使用者的建议

如果你只是想理解这次更新，可以记住一句话：

> Agent Identity 是把 Codex 账号接入从“保存 OAuth Token”推进到“保存 runtime id + 本地 Ed25519 私钥，并在请求时动态签名”的模式。

如果你要实际部署，需要至少注意：

1. 只导入自己拥有并授权使用的账号身份。
2. 不要把 `auth.json`、`agent_private_key`、API key 发给第三方。
3. 不要把免费账号当作稳定生产资源池。
4. 不要对外售卖或共享可能违反上游条款的账号能力。
5. 给 Sub2API 的数据库、配置文件、日志和备份做好权限隔离。
6. 开启分组、限流、并发控制和审计，避免单个账号被打爆。

## 参考资料

- Sub2API GitHub 仓库：`https://github.com/Wei-Shaw/sub2api`
- Sub2API 最新 release：`v0.1.165`
- Sub2API README：项目定位为订阅配额分发管理网关，并提示上游服务条款风险
- Sub2API 当前源码：`openai_agent_identity.go`、`account_codex_import.go`、前端 OpenAI 账号授权文案

## 一句话总结

Sub2API 的 Agent Identity 模式不是简单换一个 token 字段，而是把 Codex 账号接入改造成 runtime id + Ed25519 私钥 + 动态签名的身份模型。它减少了 OAuth Token 暴露，但没有消除账号共享、免费账号滥用、上游风控和服务条款风险。
