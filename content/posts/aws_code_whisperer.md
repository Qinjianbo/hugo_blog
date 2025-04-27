---
title: 智能代码编辑助手：AWS CodeWhisperer
date: 2023-09-24T13:27:06+08:00
lastmod: 2023-09-24T13:27:06+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/00068-1425983429.0-masterpiece%2C%20best%20quality%2C%20solo%2C_a%20girl%20fly%20in%20the%20sky%2C%20there%20is%20a%20gold%20cycle%20above%20her%20head%2C%20she%20has%20%28wings%29%2C%20upper%20body%2C%20magic.jpg
# images:
#   - /img/cover.jpg
categories:
  - AI
tags:
  - 代码编辑助手
  - AI
# nolastmod: true
draft: false
---

今天向大家推荐一个程序员代码 AI 辅助神器——亚马逊的 CodeWhisperer。亚马逊的CodeWhisperer是一款程序员不可或缺的AI辅助工具，它支持多种编程语言和IDE，提供强大的代码智能提示、代码重构和其他功能，有助于提高你的编码速度和质量，同时减少了常见的开发烦恼。无论你是新手还是经验丰富的开发人员，都值得一试这个神奇的工具，它将大大提升你的编程体验。

<!--more-->

## CodeWhisperer 简介

> 亚马逊的CodeWhisperer是一款程序员不可或缺的AI辅助工具，它支持多种编程语言和IDE，提供强大的代码智能提示、代码重构和其他功能，有助于提高你的编码速度和质量，同时减少了常见的开发烦恼。无论你是新手还是经验丰富的开发人员，都值得一试这个神奇的工具，它将大大提升你的编程体验。

## 在 VSCode 中安装 CodeWhisperer

> CodeWhisperer 的安装过程很简单，只需要我们在 VSCode 的插件列表进行搜索，然后进行安装即可。详细请看安装过程截图：

![alt VSCode AWS 插件搜索](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_search.PNG)

![alt VSCode AWS 插件安装](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_install.PNG)


> 插件安装完成后，最好重启一下 VSCode

![alt VSCode AWS 插件启动](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_start.PNG)

![alt AWS ToolKit Code Whisperer 授权](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_auth.PNG)

![alt AWS ToolKit Code Whisperer 授权](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_auth1.PNG)

![alt AWS ToolKit Code Whisperer 授权](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_auth2.PNG)

![alt AWS ToolKit Code Whisperer 授权](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_auth3.PNG)

![alt AWS ToolKit Code Whisperer 授权](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_auth4.PNG)

![alt AWS ToolKit Code Whisperer 授权](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_auth5.PNG)

![alt AWS ToolKit Code Whisperer 授权](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_auth6.PNG)

![alt AWS ToolKit Code Whisperer 授权](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_auth7.PNG)

![alt AWS ToolKit Code Whisperer 授权](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_auth8.PNG)

![alt AWS ToolKit Code Whisperer 授权](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/aws_code_whisperer/aws_toolkit_auth9.PNG)

> 到这里就成功在 VSCode 安装并登录了 Code Whisperer。

> 这里有几点需要**注意**的地方：

> 1. **授权登录弹框可能需要科学上网**

> 2. **需要注册 AWS 的账号，无 AWS 账号无法使用，如果不知道怎么注册，可以扫描我的公众号二维码关注并私信我。**

> 3. **科学上网也可以关注我的公众号私信我。(注：只能推荐科学上网工具，且工具本身是收费的)**

## 使用示例

> 安装好了 Code Whisperer，让我们小试牛刀：

> 首先让他帮我写个两数和：

> 额... 这里的示例先空着吧！我是一个 golang 开发者，从使用过程来看，这个 AI 助手对与 golang 开发的提示能力，还是有些距离要走的。。。

> 我用了一会儿，感觉非常不顺畅，另外就是提示会有卡顿，可能还没有我自己写的快，还有就是只有单行提示，没有整块代码提示。

> 不过对于 python 的支持还是挺快的，如果有小伙伴是 python 开发者，我觉得还是可与一用的。

> 待后面如果它对 golang 比较友好了，我再来补充一下示例吧。

## 总结

> 尽管AI助手能够在一定程度上提升我们的开发效率，但就目前来看，免费的AI助手在某些方面可能确实不如收费的版本（尽管我自己没有使用过收费版本，但从我在网上看到的比较文章来看，收费版的Copilot似乎有其优势）。希望未来免费的CodeWhisperer能够持续改进，以提供更出色的服务。

> 免费的AI助手在功能和性能上可能会有一些限制，这很正常。收费的版本通常会投入更多资源用于研发、维护和支持，因此它们往往能够提供更高级的功能、更准确的建议以及更广泛的技术支持。这也是为什么一些开发人员愿意投资购买收费版本的原因。

> 然而，竞争在科技行业中是常态，免费的CodeWhisperer有望通过不断改进来缩小与收费版本之间的差距。随着时间的推移，它可能会提供更多令人印象深刻的功能，以满足开发人员的需求。希望未来的发展能够使这类工具变得更加全面、高效，为更多开发者带来便利。

> 总之，正如你所提到的，免费的AI助手虽然可能存在一些不足，但随着技术的不断进步，我们可以期待它们在未来取得更大的成就。

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
