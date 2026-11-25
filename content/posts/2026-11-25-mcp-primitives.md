---
description: "Server 对外暴露的三样东西到底有什么区别：Tools 是模型自己决定调的动作，Resources 是应用决定塞进上下文的数据，Prompts 是用户亲手点的流程模板。"
title: "Tools、Prompts、Resources"
date: 2026-11-25T18:59:00+08:00
lastmod: 2026-11-25T18:59:00+08:00
author: 胡巴
categories: ["技术教程"]
tags: ["MCP"]
series: ["MCP 从入门到精通"]
draft: false
---

第 1 篇说过，Server 对外暴露三样东西：Tools、Resources、Prompts。前三篇里你已经用过其中一样了——filesystem 读文件、fetch 抓网页，用的都是 Tools，另外两样还没露过面。这一篇把三样分清。分清的标准只有一条：**谁决定什么时候用它。**

## 一、一张表分清三样

|  | Tools | Resources | Prompts |
| --- | --- | --- | --- |
| 谁决定用不用 | 模型 | 应用（Host） | 用户 |
| 靠什么认 | 名字 + 参数说明 | URI 地址 | 名字 + 参数 |
| 能不能改东西 | 能 | 不能，只读 | 不能，返回一组消息 |
| 怎么发现、怎么用 | `tools/list`、`tools/call` | `resources/list`、`resources/read` | `prompts/list`、`prompts/get` |
| 长什么样 | `read_text_file`、`fetch` | `schema://main`、一份文档 | `/review-code` 这样的斜杠命令 |

三样东西都是 Server 写的，区别不在谁写，在谁决定用不用。模型自己决定调的，是 Tool；应用决定塞不塞进上下文的，是 Resource；你亲手点的，是 Prompt。

## 二、Tools：模型自己决定调的动作

一个 Tool 有三件套：名字、说明（description）、参数说明（`inputSchema`，一份 JSON Schema），还可以带一份输出说明（`outputSchema`）。客户端用 `tools/list` 把这张清单拿回来，交给模型；模型在干活的过程中自己判断要不要调、参数填什么，再由客户端发 `tools/call`。

**说明是写给模型看的说明书。** 模型就是靠它决定调不调这个工具、每个参数填什么。说明写得含糊，模型就会乱调、错填。

拿前两篇的 filesystem 对照：你说“读一下 notes.txt”，模型自己选了 `read_text_file`，自己把路径填进去——这是模型决定的。而 `write_file` 是真会改文件的，覆盖已有内容。所以 Tool 是三样里唯一能改东西的，也是唯一需要在调用前把关的。

每个 Tool 还可以带一组标注（annotations），比如 `readOnlyHint`（只读）、`destructiveHint`（可能破坏数据）、`idempotentHint`（重复调用结果一样）、`openWorldHint`（会不会碰外部世界）。filesystem 的每个工具都标了：`read_text_file` 标只读，`write_file` 标 destructive。**但标注是 Server 自报的提示，不是保证。** 一个 Server 完全可以把写文件标成只读，所以 Host 不能因为标了只读就免掉审批——看实际动作，不看自报。

Tool 的结果也不只是文字：可以是图片、结构化数据，还可以带一个指向 Resource 的链接（`resource_link`），让客户端顺着地址去取那份数据。这是 Tools 和 Resources 之间的一座桥，第五节会用到。

## 三、Resources：应用决定塞进上下文的数据

一个 Resource 是一份只读数据，靠 URI 地址认人，带名字和类型（`mimeType`）。客户端用 `resources/list` 看有哪些，用 `resources/read` 按地址取内容，取回来的是文字或二进制数据。

典型的 Resource：一份数据库表结构（`schema://main`）、一份文档、一个配置文件。它们是上下文，不是动作——模型读了它能更好地干活，但读本身不改变任何东西。

地址还可以带参数，这叫资源模板（Resource Template）：`users://{userId}/profile` 这样一条地址样式，代表一整类数据，客户端用 `resources/templates/list` 发现它们，填上具体的 ID 就能读到具体那一份。

**和 Tools 最大的区别是：模型通常不能自己去翻 Resources。** 是 Host 决定塞不塞进上下文——你在界面里用 @ 提及选一份、从附件选择器里挑一份，或者应用自动带上。Claude Code 是个例外，它另外给了模型列出和读取 Resources 的内置工具，模型也能自己去拿。

正因为应用可能预取、可能反复读，**`resources/read` 里不能藏写操作**。读就是读，读一百次结果都一样，这一点是规范写死的。

Resources 还能告诉客户端“变了”：清单变了有 `list_changed` 通知，某一份内容变了也能单独通知。版本上提一句：2026 年 7 月 28 日的现行规范里，订阅走 `subscriptions/listen`；老连接上用的是 `resources/subscribe`。两个版本都在市面上，写 Server 时要分清自己在跟谁说话。

## 四、Prompts：用户亲手点的流程模板

一个 Prompt 是一个带参数的模板：名字加几个参数，客户端用 `prompts/list` 列出来，你选中之后用 `prompts/get` 填上参数，拿回一组现成的消息，相当于把一段写好的开场白递给模型。

它在界面里的长相通常是斜杠命令或菜单项。比如一个叫 `review-code` 的 Prompt，参数是代码，你点它、填上代码，它生成的消息就是“按我们的规范审查这段代码”，还可以顺手把规范文档这份 Resource 嵌进来。Claude Code 里这类命令长这样：`/mcp__server__prompt`。

**Prompt 适合人启动的固定流程**：审查代码、写发布说明、总结一张工单。流程由人决定什么时候开始，步骤写在模板里，模型不会自己触发它——这正是它和 Tools 的分工：Tools 是模型临场发挥，Prompts 是人把套路先写好。

## 五、同一个东西，摆成哪样

判断标准就三句话：

- **会改东西，或者参数要模型临场定的，做成 Tool。** 搜索、查询、写文件、发消息。
- **稳定的只读资料，由人或应用决定带不带的，做成 Resource。** 文档、表结构、配置文件。带参数的用模板。
- **人启动的固定流程，做成 Prompt。** 审查、总结、生成报告。

拿沙盒举例：读 notes.txt 是 Tool，模型自己决定读哪份；沙盒的目录清单可以做成 Resource，你 @ 一下就塞进上下文；“总结沙盒里所有文件”可以做成 Prompt，你点了才开始。

最后说一句客户端的现实。按 2026 年 10 月的情况，Tools 是三样里支持面最广的，Resources 和 Prompts 看客户端：Claude Code 三样都接，@ 提及读 Resource、斜杠命令跑 Prompt；ChatGPT 以 Tools 为中心，它的文档里没有 Prompts。所以很多 Server 以 Tools 打头阵，另外两样按需补：filesystem 的主体是 16 个工具，另外把文件登记成了一个 `file://` 资源模板；fetch 是一个工具加一个同名的 Prompt。Tools 打头阵，是兼容面最广的摆法。真想让重要数据在各种客户端里都能用，常见做法是双暴露：同一份数据既登记成 Resource，又给一个返回 `resource_link` 的 Tool，只认 Tools 的客户端也能拿到。

## 练习：20 分钟，把三样都摸一遍

1. 接上官方的 Everything 测试 Server（`npx -y @modelcontextprotocol/server-everything`），它就是拿来练协议的，三样都有；或者打开 MCP Inspector，它有 Tools、Resources、Prompts 三个标签页。数一数它各有几个。
2. 在 Claude Code 里用 @ 提及读一份它的测试 Resource，再用斜杠命令跑一个它的 Prompt。对照着想：一个是你选的，一个是你点的，都不是模型自己决定的。
3. 回到 filesystem：让模型读 notes.txt，这是 Tool，模型决定的。再用 @ 把同一份文件提进来——filesystem 已经把文件登记成了 `file://` 资源模板，这回是你亲手塞的。两种摆法摆在一起看，用起来完全不一样。

## 安全提示

三样东西进上下文的方式不同，风险也不同。**Tools 能改东西，审批看实际动作，不看 Server 自报的标注；Resources 和 Prompts 的内容来自 Server，塞进上下文之后模型会当真**——来路不明 Server 的 Resource 里可以夹带误导模型的文字，Prompt 模板更是 Server 作者写好的指令，点斜杠命令之前先看它要干什么。第 6 篇会把这些风险一次讲透。
