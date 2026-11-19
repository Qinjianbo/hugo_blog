---
description: "本地/开源大模型系列第五篇：把 Ollama 接进 Claude Code、Codex 和 OpenCode 三个日常编程工具，一个地址、一个模型名、64K 上下文，三步接好，附按内存档选编码模型的办法。"
title: "接进日常工具"
date: 2026-11-19T14:20:00+08:00
lastmod: 2026-11-19T14:20:00+08:00
author: 胡巴
categories:
  - 技术教程
tags:
  - 本地大模型
series:
  - 本地/开源大模型从入门到精通
draft: false
---

# 接进日常工具

前四篇把本地的脑子搭好了：Ollama 常驻在后台、按内存挑了模型、算清了量化与显存、按你的内存档配好了主力配置。这一篇把脑子接进每天用的编程工具：**Claude Code、Codex、OpenCode**。三个工具的接法各不相同，但要对齐的其实只有三件事：**告诉工具去哪找模型、告诉它用哪个模型、给模型多大的上下文**。接好之后，你的代码就不用再发到云端了。

## 一、接之前先对齐的三件事

1. **上下文至少给 64K，两边都要给。** 编程工具不像聊天，它要把整个仓库的 relevant 文件、对话历史和工具调用都塞进上下文，上一篇默认的 4K 根本不够用。启动 Ollama 之前先把上下文开大：`OLLAMA_CONTEXT_LENGTH=65536 ollama serve`，用 Mac App 的话在设置里改上下文长度也一样。**光开 Ollama 这边还不够**：Claude Code 对不认识的模型名默认按 200K 的窗口来，只在 200K 才压缩对话，会先把 Ollama 的 64K 撑爆，所以 Claude Code 这边也要告诉它上限是 64K：`export CLAUDE_CODE_MAX_CONTEXT_TOKENS=65536`，和上面那个数保持一致。两边都设了，窗口才真正对齐。没开够的表现很典型：工具一调就报错、或者答到一半把前面的事忘了。
2. **模型要会调工具。** 不是所有模型都能当编程工具的脑子，工具调用（tool use）是单独的能力：模型得按规定格式输出“读这个文件”“改那几行”这样的指令，格式一乱工具就执行不了。所以这一篇用的都是代码模型，不是上一篇里日常聊天的通用模型。
3. **地址分两种方言。** Claude Code 说的是 Anthropic 的方言（`/v1/messages`），Codex 和 OpenCode 说的是 OpenAI 的方言（`/v1`）。好消息是 Ollama 两种都会说：**0.14.0 以上版本自带 Anthropic 兼容接口**，OpenAI 兼容接口则一直都有。先把 Ollama 升到最新（`ollama --version` 看一眼，`ollama launch` 命令要 0.15 以上），再往下接。

LM Studio 也一样能接：它的 1234 端口同样提供 OpenAI 兼容地址，把下面各节里的 `http://localhost:11434` 换成 `http://127.0.0.1:1234` 就行，上下文在 LM Studio 里加载模型时指定。

## 二、Claude Code：一行命令接上

Claude Code 是 Anthropic 的终端编程工具，平时连的是它自己的云端模型。Ollama 官方给了最短的一条路：

1. **先拉一个代码模型**，比如 `ollama pull qwen2.5-coder:14b`（按内存档选哪个模型见第五节）。
2. **一行命令启动**：`ollama launch claude`。它会自动把 Claude Code 指到本地 Ollama，启动时可以选模型，也可以直接写死：`ollama launch claude --model qwen2.5-coder:14b`。
3. **想自己配也行**，就四个环境变量（写进 `~/.zshrc`，每次开终端都生效）：`export ANTHROPIC_BASE_URL=http://localhost:11434`，`export ANTHROPIC_AUTH_TOKEN=ollama`，`export ANTHROPIC_API_KEY=`（留空），`export CLAUDE_CODE_MAX_CONTEXT_TOKENS=65536`。前三个告诉 Claude Code 去哪找模型，第四个把它的窗口上限钉在 64K，和 Ollama 那边对齐。注意地址**不带 `/v1`**，这是 Claude Code 和另外两个工具最容易写错的区别。

两句实话要先说清楚：**Anthropic 官方说它不支持把 Claude Code 指到非 Claude 模型上**，这条路是 Ollama 提供的，不是 Anthropic 支持的，出了问题找 Anthropic 客服没用；另外联网搜索这类托管功能在本地模型上不完全支持。还有，上面这四个变量一旦设了，Claude Code 就不再走你的 Claude 订阅登录，**想回云端先把它们 unset 掉**，别两边混着用还以为走的是本地。

## 三、Codex：`--oss` 一把梭

Codex 是 OpenAI 的终端编程工具，本地模型是它官方就留好的路，比 Claude Code 更顺：

1. **最快的一步**：`codex --oss`。它默认用内置的 Ollama 提供方、默认拉 `gpt-oss:20b` 这个开源模型，不用写配置文件。
2. **想固定下来**，在 `~/.codex/config.toml` 里写两行：`oss_provider = "ollama"`，再加 `model = "gpt-oss:20b"`。以后打 `codex --oss` 就是本地模型。注意：**不加 `--oss` 的 `codex` 还是走云端**，上面这两行只在加了 `--oss` 时才生效。想在云端和本地之间切换着用，把 `model` 那行写进一个单独的 profile 文件（`~/.codex/local.config.toml`），启动时用 `codex --profile local --oss`。
3. **换模型**用 `-m`：`codex --oss -m qwen2.5-coder:14b`。想长期用别的模型，把上面那行 `model` 改掉就行。
4. **接远程机器上的 Ollama**（比如家里有台带显卡的机器）要走 profile，不走 `--oss`：`--oss` 是写死连本机的。先在 `~/.codex/config.toml` 里加一个提供方，名字用英文，别和内置的撞车（`openai`、`ollama`、`lmstudio` 都是保留名，比如叫 `ollama-remote`）：`[model_providers.ollama-remote]`，`base_url` 写 `http://那台机器的地址:11434/v1`，`wire_api = "responses"`。再在 `~/.codex/remote.config.toml` 里写 `model_provider = "ollama-remote"`，`model = "qwen2.5-coder:14b"`，顺手加 `model_context_window = 65536`，启动用 `codex --profile remote`。注意两点：**新版 Codex 只认 Responses API**，`wire_api` 现在只有 `"responses"` 这一个合法值，旧教程里的 `"chat"` 会直接报错；Ollama 也要新版，太旧的版本没有 Responses 接口，Codex 的请求会 404。

Codex 的配置文件只认家目录下的 `~/.codex/config.toml`，项目里的 `.codex/config.toml` 不认提供方配置，别把地址写错地方。

## 四、OpenCode：写一段 JSON

OpenCode 是开源的终端编程工具，接本地模型要写一段配置，但写一次就不用再动：

1. **先拉模型**，和前面一样，比如 `ollama pull qwen2.5-coder:14b`。
2. **在 `~/.config/opencode/opencode.json` 里加一个提供方**（没有这个文件就新建一个，项目根目录下放一个同名文件只对这个项目生效）：`provider` 下面加 `ollama`，里面写 `"npm": "@ai-sdk/openai-compatible"`，`"baseURL": "http://localhost:11434/v1"`，`"models"` 下面写你要用的模型，键名必须和 `ollama list` 显示的一字不差，比如 `"qwen2.5-coder:14b"`。
3. **给本地模型补一个上下文上限**：`models` 里每个模型再加 `"limit": { "context": 65536 }`。OpenCode 对云端模型能自己查上下文大小，对本地模型查不到，不写这一行它就不知道什么时候该压缩对话。
4. **启动后用 `/models` 切换模型**，或者启动时直接指定：`opencode --model ollama/qwen2.5-coder:14b`（斜杠前面是提供方名，后面是模型名）。
5. **想省事就用快捷方式**：`ollama launch opencode`，它会直接带一个模型启动，不改你已有的 `opencode.json`。但注意，只写在 `opencode.json` 里的模型不会出现在 `ollama launch` 的选择器里，两边各管各的。

## 五、按内存档选编码模型

和上一篇一样的规矩，先按内存档选，再按工具接。编码模型比聊天模型更吃内存，因为 64K 上下文的 KV 缓存也要算进去：

1. **8GB 内存**：`qwen2.5-coder:7b`，Q4 版约 4.7GB，留足上下文余量。小任务（改一个函数、补几行注释）没问题，别指望它一次重构整个模块。
2. **16GB 内存**：`qwen2.5-coder:14b`，Q4 版约 9GB。这是这个档位的甜点，代码补全和改 bug 都稳得多。
3. **24GB 以上**：`qwen3-coder:30b`（约 19GB）或 `gpt-oss:20b`（约 13GB，Codex 的 `--oss` 默认就是它）。30B 配 64K 上下文很吃内存，跑起来先用 `ollama ps` 看 SIZE 那一列，开始往 CPU 上溢就说明到顶了，降回 20B 或者把上下文收一点。

期望要先摆正：**本地小模型调工具的稳定性不如云端的 Sonnet 和 GPT**，偶尔会输出格式不对、或者改错地方。先从小任务开始练手：让它给一个函数加测试、修一个明确报错、改几行配置，跑通了再慢慢放大任务。工具的规矩和上一篇一样：只在自己的项目上练，别让它动你不熟悉的仓库。

## 六、三个常见翻车

1. **上下文没给够就接**：工具能启动、能聊天，但一让它读文件就报错或者答非所问。先查 `OLLAMA_CONTEXT_LENGTH` 设了没有，`ollama ps` 里看不到上下文，得回到启动 Ollama 的那一步确认。
2. **模型名写错一个字**：`opencode.json` 里模型的键名、`--model` 后面跟的名字、Codex 配置里的 `model`，都必须和 `ollama list` 显示的标签一字不差，`qwen2.5-coder:14b` 写成 `qwen2.5-coder:14B` 都不行。
3. **`/v1` 加错地方**：Claude Code 的 `ANTHROPIC_BASE_URL` 是 `http://localhost:11434`，**不带 `/v1`**；Codex 和 OpenCode 的地址是 `http://localhost:11434/v1`，**必须带 `/v1`**。两边混了就连不上，报错还不直说，照着这一条先对。

这一篇里的命令和配置，核对日期是 **2026 年 11 月 18 日**，来源是 Ollama 官方的 Claude Code 与 Codex 集成文档、Anthropic 的 Claude Code 网关文档、OpenAI 的 Codex 配置文档和 OpenCode 的提供方文档。其中 Claude Code 的上下文上限和 Codex 的 `--oss` 行为这两处，是按第三方教程（2026 年 11 月）核对的，官方文档里没写这么细，也没实际跑过，配的时候以你机器上的实际表现为准。工具更新很快，照着配之前先确认你装的版本和文档里写的一致——这也是本系列每篇都要写核对日期的原因。

## 练习：20 分钟，让本地模型改一行代码

1. 按你的内存档拉一个编码模型（第五节那张表），再把上下文开到 64K：`OLLAMA_CONTEXT_LENGTH=65536 ollama serve`。
2. 按第二节到第四节，挑一个你最常用的工具接上（只接一个，别三个一起配）。
3. 找一个自己的小项目，让它做一件小事：给一个函数加一段测试、或者修一个你已经知道原因的小 bug。先让它只读（`claude --model … -p "先看一下这个函数是干嘛的"` 这种只读的问题），确认它读对了再让它动手改。
4. 跑 `ollama ps` 看一眼 SIZE，记下来：你的机器上，这个模型加 64K 上下文实际占多少内存。下一篇讲 RAG 的时候，这个数就是你的预算。

## 安全提示

这一篇的安全提示还是那两句，换个说法：**Ollama 的 11434 端口只听本地**，别为了图方便改成 `0.0.0.0` 对外暴露——接远程机器那节除外，而且那也要走你自己的内网，别直接挂到公网上；**本地最大的好处就是代码不离本机**，别因为配错了地址又把代码送回云端。另外，模型许可证那句照旧：开源权重不等于随便商用，商用之前先确认许可证。
