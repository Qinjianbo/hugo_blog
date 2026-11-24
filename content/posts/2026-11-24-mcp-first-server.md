---
description: "用官方参考 Server 把 MCP 真正跑起来：filesystem 管本地文件，fetch 负责联网取网页，十分钟接通 Claude 桌面版。"
title: "第一个 MCP Server：跑起来"
date: 2026-11-24T22:04:00+08:00
lastmod: 2026-11-24T22:04:00+08:00
author: 胡巴
categories: ["技术教程"]
tags: ["MCP"]
series: ["MCP 从入门到精通"]
draft: false
---

上一篇讲了 MCP 是什么，这一回动手：把官方的两个参考 Server 跑起来，一个管本地文件，一个负责联网取网页。十分钟，接通，模型就能真的读你的文件、抓网页了。用的全是官方参考实现，不用自己写一行代码。

## 一、先准备两样东西

两个参考 Server 分属两种语言。filesystem 是 TypeScript 写的，用 `npx` 起；fetch 是 Python 写的，用 `uvx` 起。开始之前先确认两样工具装好了：

```bash
node --version
uv --version
```

`node` 要 24 或更新——filesystem 从 v2.0.0 起把最低版本提到了 Node 24，老版本跑不起来。`uv` 没有的话去 astral.sh 按官方说明装一个，它是 Python 的包管理工具，`uvx` 的作用是一次性下载并运行，不往你的系统里装东西。

再建一个专门用来练手的沙盒文件夹，别直接拿真实项目开刀：

```bash
mkdir -p ~/Desktop/mcp-playground
echo "这是我的 MCP 练习文件。" > ~/Desktop/mcp-playground/notes.txt
```

**只给模型一个空沙盒，是这篇最重要的习惯。** 后面你会看到，filesystem 的权限边界就是你命令行里列出的那几个文件夹。

## 二、先在终端里跑起来看一眼

先不急着配客户端，直接在终端里把两个 Server 各起一次：

```bash
npx -y @modelcontextprotocol/server-filesystem ~/Desktop/mcp-playground
```

你会发现终端“卡住”了，什么都不输出。这不是坏了：**本地 Server 默认走 stdio，也就是标准输入输出，它在等客户端跟它说话。** 没有客户端连上来，它就一直等着。按 `Ctrl+C` 退出就行。

fetch 也一样：

```bash
uvx mcp-server-fetch
```

同样是起起来就等着，同样 `Ctrl+C` 退出。`npx -y` 和 `uvx` 的意思都是“没有就先下载再运行”，所以第一次会慢一点，之后就快了。

这一步的意义是验货：命令能起起来、没有报错，说明 Node、uv 和网络都没问题。起不来先看报错里有没有版本号和网络问题，别急着去改配置文件。

## 三、写进配置文件，让客户端接上

终端里手动起 Server 只能验货，真正用起来要让客户端去起它。以 Claude 桌面版为例，它的 Server 都写在一个 JSON 配置文件里：

- macOS：`~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows：`%APPDATA%\Claude\claude_desktop_config.json`

在 Claude 里点“设置 → 开发者 → 编辑配置”也能打开这个文件，没有就新建一个。把下面这段写进去：

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/你的用户名/Desktop/mcp-playground"
      ]
    },
    "fetch": {
      "command": "uvx",
      "args": ["mcp-server-fetch"]
    }
  }
}
```

注意三处：路径必须是绝对路径，把“你的用户名”换成你自己的；filesystem 后面列出的文件夹就是它能碰的全部范围，沙盒之外的一概碰不到；JSON 里不能有多余的逗号，保存前检查一遍。

**写好保存，完全退出 Claude 桌面版再重新打开。** 不重启，新配置不会加载，这是最常见的“配好了怎么没用”的原因。重启后对话框里出现锤子图标或者工具列表，就说明两个 Server 都接上了。

## 四、让模型真正用一次

接上了就试三句话，一句比一句真：

1. “列一下 mcp-playground 里有什么文件。”——模型应该能调 filesystem 的工具，把 notes.txt 列出来。
2. “读一下 notes.txt，告诉我里面写了什么。”——验证它真的能读文件内容，而不只是列名字。
3. “抓一下 https://modelcontextprotocol.io 这个页面，告诉我它讲了什么。”——验证 fetch 能联网取网页并转成模型能读的文字。

三句都对上了，这根线就算通了。如果某句失败，先看模型是不是真的调了工具：它应该明确说出用了哪个工具、拿到了什么结果，而不是凭空编一个答案。**凡是没调工具就回答的，都是模型在猜，不是 MCP 在工作。**

## 五、出问题先查这三处

第一次接 MCP，十有八九会在这三处绊一下：

**第一，改完配置没重启客户端。** Claude 桌面版只在启动时读一次配置文件，改完必须完全退出重开，关窗口不算退出。

**第二，Node 版本太老。** filesystem v2.0.0 起要求 Node 24，跑 `node --version` 看一眼，低于 24 先升级 Node。

**第三，filesystem 没给文件夹。** 启动时不列文件夹，Server 会直接退出或者对每个工具调用都报错。检查配置里 `args` 的最后一项是不是一个真实存在的绝对路径。

还有一句版本上的实话：参考 Server 一直在变，2026 年 11 月 18 日的 v2.5.0 刚修了 14 个漏洞。`npx -y` 和 `uvx` 每次都会拉最新版，跟着官方走就行；如果哪天命令变了，先去 modelcontextprotocol/servers 这个仓库的 README 对一下。另外要知道，**这些参考 Server 是教学用的示范实现，不是生产方案**，够你练手，不够你直接拿去给全公司用。

## 练习：20 分钟，搭一个自己的试验场

1. 在沙盒里再放两样东西：一个你自己的真实文件复制品（别放原件），和一个子文件夹，里面放三篇你常看的文章链接清单。
2. 问模型三件事：沙盒里一共有几个文件、那篇复制品的第三段写了什么、把清单里的第一个链接抓下来总结成三句话。
3. 故意试一次边界：让模型读沙盒外面的一个文件，比如你桌面上的另一个文件，看它是不是拒绝——拒绝了才是对的，说明权限边界在起作用。

## 安全提示

filesystem 能读写你给它的文件夹，写错了是真会改文件的。**练手只给沙盒文件夹，永远别把整个用户目录或者桌面整个交出去。** fetch 会联网，抓回来的网页内容也可能夹带误导模型的文字，重要的操作先自己看一眼再点头。第 6 篇会把这些风险一次讲透。
