---
title: AI Agent 入门：轻松看懂 ReAct 核心原理
date: 2025-08-19T09:38:16+08:00
lastmod: 2025-08-19T09:38:16+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/%E5%93%94%E5%93%A9%E5%93%94%E5%93%A9%E4%B8%8A%E6%90%9C%E9%9B%86%E7%9A%84%E7%BE%8E%E5%9B%BE%E8%89%B2%E5%9B%BE_1-1000/28.jpg
categories:
  - 自动化
  - AI
tags:
  - AI Agent
  - ReAct
  - Plan-and-Execute
# nolastmod: true
draft: false
---

# AI Agent 入门：轻松看懂 ReAct 核心原理

AI Agent 的浪潮已经到来，但你真的理解它是什么，以及它背后是如何工作的吗？本文将带你从概念到原理，再到亲手实现，彻底搞懂 AI Agent 的核心。

今天，我们来聊聊 AI 领域最火的概念之一：**Agent**。

随着大模型的普及，"Agent" 这个词被频繁提及，但很多人对它其实一知半解：

*   🤔 **到底什么是 Agent？** 它和我们平时用的 ChatGPT 、Deepseek 有什么区别？
*   😟 **Agent 是如何实现的？** 它思考和行动的逻辑是怎样的？

别担心，这篇文章会用最通俗易懂的方式，带你彻底搞明白这两个问题。

## 大模型只是“大脑”，Agent 才是“完全体”

我们都知道，现在的大模型（LLM），比如 GPT-4o、DeepSeek，非常强大。它们就像一个超级“大脑”，逻辑清晰，擅长回答各种问题。

但这个“大脑”有一个天生的限制：它**无法感知或改变外部的真实世界**。

举个例子：

1.  **你让大模型写一个贪吃蛇游戏**：它能完美地给你提供 HTML、CSS、JS 代码。但是，它无法帮你创建文件、把代码粘贴进去。这些“动手”的活儿，还得你自己来。
2.  **你让它修改电脑上已有的代码**：你必须先把代码复制给它。因为它看不到你电脑里的文件，无法主动感知。

简单来说，**单纯的大模型，是个“缸中之脑”，有思想但没有手脚。**

![缸中之脑](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1755524684093-264d71c4-6751-4372-98d9-543eee6d5b0d.png)

## 如何让大模型有感知能力？

怎么解决？很简单，给它配上“手脚”和“感官”——也就是 **工具（Tools）**。

这些工具可以是：
*   读写文件的函数
*   执行终端命令的脚本
*   调用搜索引擎的 API
*   ...任何能与外部环境交互的程序

**当我们将一个大模型（大脑）与一系列工具（感官和四肢）组合起来，形成一个能够自主感知环境、进行规划并执行任务的智能程序时，我们就称之为一个 Agent。**

`▲ Agent = 大模型（大脑） + 工具（感官与四肢）`

正因如此，我们通常用一个“机器人”的图标来代表 Agent，因为它不再仅仅是一个会思考的大脑，而是一个能独立做事的“完全体”。

`▲你可以想象一下：自己的大脑就像LLM，五官、四肢、皮肤都是工具，帮助你的大脑干活。`
`▲我认为：其实Agent就是在模拟人类。`

![](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1755571614306-a0f9cca9-32a3-4b42-af22-63ddad00c02d.png)

## AI Agent 能做什么？看这两个例子就懂了

Agent 的种类繁多，可以用于编程、制作PPT、深度搜索等等。下面是两个典型的例子：

### 1. 编程 Agent：Cursor

Cursor 是一款著名的 AI 编程工具。你只需要给它下达一个任务，比如：“用 HTML、CSS 和 JS 写一个贪吃蛇游戏，代码分别放在不同文件里。”

它会：
1.  **规划步骤**：创建 `index.html`、`style.css` 和 `script.js` 三个文件。
2.  **执行动作**：自动生成并写入这三个文件的代码。
3.  **完成任务**：整个过程你几乎不需要插手，一个完整的项目就创建好了。

### 2. 制作PPT的Agent：Kimi PPT助手

假设你想让AI帮你制作一份PPT，你可以说：“帮我制作一份介绍AI Agent的PPT”。

Kimi 会：
1.  **撰写符合PPT主题的内容**：
    *   首先KIMI会根据你提出的主题，确认要在PPT中呈现的内容
2.  **制作PPT**：在你确认后，kimi PPT助手会根据你选的PPT模板制作精美PPT。

![](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1755571252559-23fe86a1-ced5-4801-b5a3-6c680367c3f2.gif)


这两个例子充分展示了 Agent 的核心能力：**将复杂任务自动化，从头到尾独立完成。**

## 揭秘 Agent 的思考方式：ReAct 框架

那么，Agent 是如何实现这种复杂的“思考-行动”循环的呢？目前最主流、最经典的一种模式叫做 **ReAct**。

ReAct 是 **Reasoning and Action** (推理与行动) 的缩写。它为 Agent 定义了一个标准的工作流程。

这个流程的核心是一个循环：

1.  **思考 (Thought)**：首先，Agent 会根据当前任务和已知信息，进行思考和推理。“我为了完成目标，下一步该做什么？”
2.  **行动 (Action)**：基于思考的结果，Agent 决定调用某个具体的工具来执行一个动作。比如，调用 `write_to_file` 工具写入代码。
3.  **观察 (Observation)**：工具执行完毕后，会返回一个结果。Agent 会“观察”这个结果。“文件写入成功了。”
4.  **再次思考**：Agent 将观察到的结果作为新的信息，进行新一轮的“思考”，规划下一步的“行动”。

这个 **“思考 → 行动 → 观察”** 的循环会一直重复，直到 Agent 认为任务已经全部完成，最后输出一个 **最终答案 (Final Answer)**。

![](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1755571908589-8f2944d3-55d4-41ff-b95a-2cf035f184a0.png)

## ReAct 的魔法核心：万能的“系统提示词”

你可能会好奇，大模型怎么会知道要遵循 ReAct 这个流程呢？难道是经过了特殊的训练？

其实不然。实现 ReAct 的核心魔法，在于 **系统提示词 (System Prompt)**。

我们可以为大模型编写一个详细的“剧本”（也就是系统提示词），告诉它扮演一个遵循 ReAct 模式的 Agent 角色。这个剧本通常包含以下几个部分：

*   **职责描述**：明确告诉模型它的工作模式，即通过“思考-行动-观察”的循环来解决问题。
*   **格式要求**：定义好 `Thought`, `Action`, `Observation`, `Final Answer` 等标签的格式。
*   **示例 (Few-shot)**：给出几个完整的交互示例，让模型学习如何使用这些标签。
*   **可用工具列表**：告诉模型它有哪些工具（函数）可以用，以及每个工具的功能和参数。
*   **注意事项**：规定一些严格的规则，比如标签的使用顺序等。
*   **环境信息**：提供当前的工作目录、操作系统等动态信息。

只要把这个精心设计的系统提示词和用户的任务一起发给大模型，它就能像一个演员一样，按照剧本的要求，一步步地进行思考和行动，从而实现 Agent 的功能。

下面是一个具体示例：

![](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1755582289467-bc936d90-04a3-48e1-81f6-b46abfd8da8a.gif)

## 不止 ReAct：Plan-and-Execute 模式简介

当然，ReAct 并不是唯一的 Agent 构建模式。另一种常见的模式是 **Plan-and-Execute (规划并执行)**。

与 ReAct 走一步看一步的模式不同，Plan-and-Execute 模式的流程是：

1.  **规划 (Plan)**：首先，用一个专门的 **Planner (规划者)** 模型，根据用户任务，一次性生成一个完整的、包含多个步骤的执行计划。
2.  **执行 (Execute)**：然后，由一个 **Executor (执行者)** Agent，按照计划列表，一步步地执行任务。
3.  **（可选）重新规划 (Re-plan)**：在每一步执行后，还可以用一个 **Re-planner (重新规划者)** 模型，根据最新的执行结果，来动态地修改和调整后续的计划。

这种模式更适合需要长期规划和复杂步骤的任务，因为它具有更好的全局观。

典型案例：claude code：

![claude code](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1755574544644-8ed75693-3672-4093-ac77-5f713c91e20d.png)


## 当下的Agent是存在泡沫的

我前两天看过一篇文章[《Agent泡沫方显架构师本色》](https://mp.weixin.qq.com/s/ZNG7tMocvNsUfr5id3_nVQ)，文章提到的一点我个人认为很正确，在这里分享给大家：`在Agent系统中，我们倾向于仅实现确定的Step，然后让大模型（LLM）针对每一次请求动态的将这些Step拼接成Workflow，这样就使得系统具有”自主性“（也就是智能性），但这样每一个Step执行或者不执行就存在了不确定性，Agent系统的不可靠性是一个难题。借助于LLM做决策和规划的干扰因素非常的多，典型如：模型能力、System Prompt的质量、用户Query的复杂性、上下文干扰、Tool的质量等等，这意味着在一开始就让模型规划出一个多步骤的路径并期望它能够最终完成用户的诉求是非常理想的。`

## 结束语

今天我们深入探讨了 AI Agent 的世界，总结一下核心要点：

1.  **Agent 的本质**：是“大模型”这个大脑，加上“工具”这副手脚，从而能够与世界交互并完成任务。
2.  **ReAct 框架**：是 Agent 实现“思考-行动”循环的主流模式，其核心驱动力是精心设计的系统提示词。
3.  **Plan-and-Execute 框架**：提供了另一种先规划后执行的思路，更适合复杂任务。
4. **当下的Agent是存在泡沫的**：Agent 具有 `动态规划不确定性`。

Agent 技术正在飞速发展，它将从根本上改变我们与软件交互的方式。希望这篇文章能帮你打下坚实的基础，更好地理解和应用这项激动人心的技术。

如果觉得本文对你有帮助，别忘了**点赞**、**关注**、**转发**，我们下期再见！

---

这里是每天进步的`胡巴`，关注我，让我们一起解锁AI的无限可能，让生活变得更简单、更高效！

![](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1755265607084-cf0899b5-587b-4700-90a9-c859259eaec3.png)

## 往期推荐

1. [如何从眼花缭乱的AI工具中匹配出属于你的那一款](https://mp.weixin.qq.com/s/vPld-pgBc8BQeN2_9PHq3A)
2. [RAG技术详解--那些高质量智能助手背后的技术手段](https://mp.weixin.qq.com/s/kczEKTuHLSn8AzEEFxUVqA)
3. [比官方便宜72%，无需翻墙！这款Claude镜像工具让AI编程成本直降，开发者都在抢着用。](https://mp.weixin.qq.com/s/RIljqL4Y9X2Q7dvJJybREQ)
4. [n8n实战之初出茅庐：让AI帮你审代码！N8N+GitLab+Deepseek 自动化智能评审全流程实战](https://mp.weixin.qq.com/s/mNlnqExtW6pKPTJMCEA01A)
5. [[APP扫码版]告别手动签到！用n8n打造京东自动签到神器](https://mp.weixin.qq.com/s/qc-17vTWclmyJjSnRBUK_Q)

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】 