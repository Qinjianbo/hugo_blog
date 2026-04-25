---
title: OpenClaw Web Tools 中文指南：web_search 与 web_fetch 怎么配置、怎么使用
date: 2026-03-14T22:07:15+08:00
lastmod: 2026-03-14T22:07:15+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - AI
  - Agent
  - 工具
tags:
  - OpenClaw
  - web_search
  - web_fetch
  - Brave
  - Perplexity
  - Gemini
draft: false
description: 把 OpenClaw 官方 Web Tools 文档整理成中文教程，讲清楚 web_search 与 web_fetch 的工作方式、提供方选择、配置方法和示例代码。
source_url: https://docs.openclaw.ai/tools/web
---

如果你准备让 OpenClaw 直接联网查资料，那么最值得先搞清楚的就是 `web_search` 和 `web_fetch` 这两个工具。前者负责搜索，后者负责抓取网页正文。这篇文章把官方文档整理成中文，并把关键配置和示例代码一起搬过来，方便直接照着配。

<!--more-->

## 适用场景

- 想让 OpenClaw 具备联网搜索能力，但不确定该接 Brave、Perplexity 还是 Gemini
- 想知道 `web_search` 和浏览器工具有什么区别，避免工具选错
- 想把官方文档里的配置块和调用示例直接整理成可复用笔记

## 先搞清楚：这两个工具分别做什么？

OpenClaw 官方把 Web Tools 拆成了两个轻量工具：

- `web_search`：负责联网搜索，支持 Brave Search API、Gemini、Grok、Kimi 和 Perplexity Search API
- `web_fetch`：负责用 HTTP 抓网页，并把 HTML 提取成更适合模型阅读的 markdown 或纯文本

这里有一个边界要记住：

- 它们不是浏览器自动化工具
- 如果目标站点强依赖 JavaScript、需要登录，或者要点按钮、滚动页面，应该改用 Browser 工具

## 它的工作方式是什么？

官方文档里的核心逻辑可以压缩成 4 点：

- `web_search` 会调用你配置好的搜索提供方，然后返回搜索结果
- 搜索结果会按 query 缓存，默认缓存 15 分钟
- `web_fetch` 只做普通 HTTP GET，不执行页面里的 JavaScript
- `web_fetch` 默认就是开启的，除非你显式关闭

## 搜索提供方怎么选？

官方文档把不同提供方的能力差异讲得比较清楚，整理如下：

| 提供方 | 返回结果形态 | 过滤能力 | 备注 | API Key |
| --- | --- | --- | --- | --- |
| Brave Search API | 结构化搜索结果 + snippet | `country`、`language`、`ui_lang`、时间过滤 | 支持 Brave 的 `llm-context` 模式 | `BRAVE_API_KEY` |
| Gemini | AI 综合答案 + 引用链接 | 无提供方专属过滤项 | 走 Google Search grounding | `GEMINI_API_KEY` |
| Grok | AI 综合答案 + 引用链接 | 无提供方专属过滤项 | 基于 xAI 的 web-grounded responses | `XAI_API_KEY` |
| Kimi | AI 综合答案 + 引用链接 | 无提供方专属过滤项 | 基于 Moonshot web search | `KIMI_API_KEY` / `MOONSHOT_API_KEY` |
| Perplexity Search API | 结构化搜索结果 + snippet | `country`、`language`、时间、`domain_filter` | 支持内容提取控制；也兼容 OpenRouter Sonar 路径 | `PERPLEXITY_API_KEY` / `OPENROUTER_API_KEY` |

如果你更看重传统搜索结果和筛选能力，Brave 与原生 Perplexity Search API 会更直接。  
如果你更想要“模型先帮你总结，再附上引用来源”，Gemini、Grok、Kimi 这类 AI 合成返回会更适合。

## 没显式指定 provider 时，会怎么自动选择？

如果你没有在配置里明确设置 provider，OpenClaw 会按下面的顺序自动检测：

1. Brave
2. Gemini
3. Grok
4. Kimi
5. Perplexity

对应的检查条件是环境变量或者配置项里有没有可用 key：

- Brave：`BRAVE_API_KEY` 或 `tools.web.search.apiKey`
- Gemini：`GEMINI_API_KEY` 或 `tools.web.search.gemini.apiKey`
- Grok：`XAI_API_KEY` 或 `tools.web.search.grok.apiKey`
- Kimi：`KIMI_API_KEY`、`MOONSHOT_API_KEY` 或 `tools.web.search.kimi.apiKey`
- Perplexity：`PERPLEXITY_API_KEY`、`OPENROUTER_API_KEY` 或 `tools.web.search.perplexity.apiKey`

如果一个都没找到，系统会回退到 Brave，然后再给出缺失 key 的错误提示。

官方还特别提到 `SecretRef` 的行为：

- 会在 Gateway 启动或 reload 时一次性解析
- 自动检测模式下，只会解析最终选中的那个 provider 所需的 key
- 如果选中的 provider 配的是 `SecretRef`，但又解析失败，且没有环境变量兜底，Gateway 会直接在启动或 reload 时失败

## 怎么配置 web search？

官方推荐直接运行：

```bash
openclaw configure --section web
```

如果你更习惯自己写配置，也可以直接改配置文件或者设置环境变量。

## Brave Search 配置

官方给出的步骤是：

1. 去 `https://brave.com/search/api/` 创建 Brave Search API 账户
2. 选择 Search plan 并生成 API key
3. 运行 `openclaw configure --section web`，或者直接设置 `BRAVE_API_KEY`

文档里还特别说明了计费点：

- 每个 Brave plan 都带有每月 5 美元免费额度
- Search 的价格是每 1000 次请求 5 美元
- 也就是说，这个免费额度大致覆盖每月 1000 次查询
- 官方建议你在 Brave 控制台里顺手设置 usage limit，避免超额

如果你想显式指定 Brave 作为 provider，配置可以这样写：

```json5
{
  tools: {
    web: {
      search: {
        enabled: true,
        provider: "brave",
        apiKey: "YOUR_BRAVE_API_KEY", // optional if BRAVE_API_KEY is set // pragma: allowlist secret
      },
    },
  },
}
```

如果你想启用 Brave 的 `llm-context` 模式，可以这样配：

```json5
{
  tools: {
    web: {
      search: {
        enabled: true,
        provider: "brave",
        apiKey: "YOUR_BRAVE_API_KEY", // optional if BRAVE_API_KEY is set // pragma: allowlist secret
        brave: {
          mode: "llm-context",
        },
      },
    },
  },
}
```

这个模式的意思是：返回的不再是普通 snippet，而是更适合给模型做 grounding 的网页内容片段。  
但它也有明确限制：

- `country` 和 `language` / `search_lang` 还能用
- `ui_lang`、`freshness`、`date_after`、`date_before` 会被拒绝

## Perplexity Search 配置

官方给出的步骤是：

1. 去 `https://www.perplexity.ai/settings/api` 创建账号并生成 API key
2. 运行 `openclaw configure --section web`，或者设置 `PERPLEXITY_API_KEY`

原生 Perplexity Search API 的配置例子：

```json5
{
  tools: {
    web: {
      search: {
        enabled: true,
        provider: "perplexity",
        perplexity: {
          apiKey: "pplx-...", // optional if PERPLEXITY_API_KEY is set
        },
      },
    },
  },
}
```

如果你走的是旧的 Sonar / OpenRouter 兼容路径，官方示例是：

```json5
{
  tools: {
    web: {
      search: {
        enabled: true,
        provider: "perplexity",
        perplexity: {
          apiKey: "<openrouter-api-key>", // optional if OPENROUTER_API_KEY is set
          baseUrl: "https://openrouter.ai/api/v1",
          model: "perplexity/sonar-pro",
        },
      },
    },
  },
}
```

这里有两个关键兼容性提醒：

- 如果使用 `OPENROUTER_API_KEY`，或者 `sk-or-...` 这类 key，系统会走 Sonar 兼容路径
- 如果你显式设置了 `tools.web.search.perplexity.baseUrl` 或 `model`，也会切回 chat-completions 兼容路径

在这种兼容模式下，Search API 专属的过滤能力不是都能用。官方明确写了：

- 兼容模式只支持 `query` 和 `freshness`
- 其他只属于原生 Search API 的参数会返回明确错误

## Gemini（Google Search grounding）怎么配？

Gemini 这一条的特点是：它不是传统“列结果页”，而是直接给模型综合答案，并附带基于 Google Search 的引用来源。

官方建议的流程是：

1. 去 `https://aistudio.google.com/apikey`
2. 创建 API key
3. 在 Gateway 环境里设置 `GEMINI_API_KEY`，或者在配置里写 `tools.web.search.gemini.apiKey`

环境变量也可以放到本地：

```bash
~/.openclaw/.env
```

Gemini 的配置块如下：

```json5
{
  tools: {
    web: {
      search: {
        provider: "gemini",
        gemini: {
          // API key (optional if GEMINI_API_KEY is set)
          apiKey: "AIza...",
          // Model (defaults to "gemini-2.5-flash")
          model: "gemini-2.5-flash",
        },
      },
    },
  },
}
```

官方文档里还有几个实现层面的说明，值得记一下：

- 引用里的 Google 跳转链接会被解析成真实直链
- 这个解析过程会经过 SSRF 防护路径，包含 HEAD 和 redirect 检查以及 `http/https` 校验
- 默认 SSRF 策略会拦截私网和内网目标
- 默认模型是 `gemini-2.5-flash`

## `web_search` 的基本要求

要让 `web_search` 可用，至少要满足两件事：

- `tools.web.search.enabled` 不能是 `false`
- 对应 provider 的 API key 必须能拿到

官方给出的通用配置示例如下：

```json5
{
  tools: {
    web: {
      search: {
        enabled: true,
        apiKey: "BRAVE_API_KEY_HERE", // optional if BRAVE_API_KEY is set
        maxResults: 5,
        timeoutSeconds: 30,
        cacheTtlMinutes: 15,
      },
    },
  },
}
```

## `web_search` 支持哪些参数？

官方文档里的参数可以整理成这样：

| 参数 | 是否必填 | 说明 |
| --- | --- | --- |
| `query` | 是 | 搜索关键词 |
| `count` | 否 | 返回结果数，范围 `1-10`，默认 `5` |
| `country` | 否 | 两位国家代码 |
| `language` | 否 | `ISO 639-1` 语言代码 |
| `freshness` | 否 | `day`、`week`、`month`、`year` |
| `date_after` | 否 | 起始日期，格式 `YYYY-MM-DD` |
| `date_before` | 否 | 结束日期，格式 `YYYY-MM-DD` |
| `ui_lang` | 否 | 仅 Brave 支持 |
| `domain_filter` | 否 | 仅 Perplexity 支持 |
| `max_tokens` | 否 | 仅 Perplexity 支持，默认 `25000` |
| `max_tokens_per_page` | 否 | 仅 Perplexity 支持，默认 `2048` |

文档里的适用范围说明也别忽略：

- 除非特别标注，这些参数主要适用于 Brave 和原生 Perplexity Search API
- OpenRouter / Sonar 兼容模式只支持 `query` 和 `freshness`
- 如果你在兼容模式下传了 Search API 专属参数，系统会直接报错，而不是默默忽略

## `web_search` 示例代码

下面这些就是官方文档里给出的典型示例，我按原意保留成可直接参考的版本。

按德国区域与语言搜索：

```javascript
await web_search({
  query: "TV online schauen",
  country: "DE",
  language: "de",
});
```

只看最近一周：

```javascript
await web_search({
  query: "TMBG interview",
  freshness: "week",
});
```

按日期区间搜索：

```javascript
await web_search({
  query: "AI developments",
  date_after: "2024-01-01",
  date_before: "2024-06-30",
});
```

按域名过滤结果，适用于 Perplexity：

```javascript
await web_search({
  query: "climate research",
  domain_filter: ["nature.com", "science.org", ".edu"],
});
```

排除不想看的域名，适用于 Perplexity：

```javascript
await web_search({
  query: "product reviews",
  domain_filter: ["-reddit.com", "-pinterest.com"],
});
```

## `web_fetch` 是干什么的？

`web_fetch` 的职责更简单：拿到一个 URL，然后尽量把网页正文抽出来，交给模型阅读。

它不是浏览器，所以不要指望它帮你执行页面脚本。  
官方文档里写得很明确：

- 默认先用 Readability 提取正文
- 如果 Readability 失败，再走 Firecrawl 作为 fallback
- 如果两条路都失败，就返回错误

## `web_fetch` 的启用要求

`web_fetch` 的基本要求有两条：

- `tools.web.fetch.enabled` 不能是 `false`
- 如果你要使用 Firecrawl fallback，需要 `tools.web.fetch.firecrawl.apiKey` 或 `FIRECRAWL_API_KEY`

官方给出的配置块如下：

```json5
{
  tools: {
    web: {
      fetch: {
        enabled: true,
        maxChars: 50000,
        maxCharsCap: 50000,
        maxResponseBytes: 2000000,
        timeoutSeconds: 30,
        cacheTtlMinutes: 15,
        maxRedirects: 3,
        userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
        readability: true,
        firecrawl: {
          enabled: true,
          apiKey: "FIRECRAWL_API_KEY_HERE", // optional if FIRECRAWL_API_KEY is set
          baseUrl: "https://api.firecrawl.dev",
          onlyMainContent: true,
          maxAgeMs: 86400000, // ms (1 day)
          timeoutSeconds: 60,
        },
      },
    },
  },
}
```

## `web_fetch` 支持哪些参数？

官方给出的工具参数并不多：

| 参数 | 是否必填 | 说明 |
| --- | --- | --- |
| `url` | 是 | 目标地址，只允许 `http/https` |
| `extractMode` | 否 | `markdown` 或 `text` |
| `maxChars` | 否 | 限制返回正文长度 |

## `web_fetch` 的注意事项

这一段在实际使用里很重要，建议直接记住：

- Firecrawl 的请求默认启用 bot-circumvention 和缓存
- Firecrawl 的 `SecretRef` 只会在 Firecrawl 真正启用时解析
- 如果 Firecrawl 处于启用状态，但 `SecretRef` 无法解析，且也没有 `FIRECRAWL_API_KEY` 兜底，Gateway 会在启动或 reload 时失败
- 默认会发送接近 Chrome 的 `User-Agent` 和 `Accept-Language`
- 会拦截私网与内网主机名，并在跳转时继续复检，跳转次数受 `maxRedirects` 限制
- `maxChars` 最终会被 `tools.web.fetch.maxCharsCap` 截断
- 响应体大小受 `tools.web.fetch.maxResponseBytes` 控制，超出时会带 warning 截断
- 一些站点如果正文提取效果不好，或者必须执行 JS，还是要换 Browser 工具

## 如果你用了工具白名单，别忘了这一点

官方文档最后还提醒了一个很容易漏掉的配置：

- 如果启用了 tool allowlist，需要显式加入 `web_search` 和 `web_fetch`
- 或者直接加 `group:web`

另外，如果 `web_search` 缺少 API key，它会返回带有文档链接的 setup hint，而不是只抛一个很干的错误。

## 一句话总结

如果你要的是“查资料并拿到搜索结果”，用 `web_search`；如果你已经有具体 URL，想把正文抓出来给模型读，用 `web_fetch`。前者重点在 provider 选择和 API key，后者重点在正文提取、Firecrawl fallback 和 SSRF 安全边界。

## 原文链接

- 官方文档：<https://docs.openclaw.ai/tools/web>
