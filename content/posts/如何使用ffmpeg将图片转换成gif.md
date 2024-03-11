---
title: 如何使用ffmpeg将图片转换成gif
date: 2024-03-10T22:02:06+08:00
lastmod: 2024-03-10T22:02:06+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto/article%20(7).jpg
# images:
#   - /img/cover.jpg
categories:
  - ffmpeg
tags:
  - gif
  - ffmpeg
# nolastmod: true
draft: false
---

这篇文章主要介绍如何使用ffmpeg将一组图片转换成gif图片。

<!--more-->

FFmpeg 是一个非常强大的开源工具，可以用来处理视频和音频文件，也可以将一组图片转换成 GIF 动画或者 MP4 视频文件。

以下是一些基本的命令行示例，用于将一组图片转换成 GIF 或者 MP4 文件：

### 将图片转换为 GIF

假设你有一组图片文件 `image1.jpg`, `image2.jpg`, `image3.jpg` ...，你想将它们转换为一个 GIF 动画。

```bash
ffmpeg -f image2 -pattern_type glob -i 'image*.jpg' -vf "fps=10,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" output.gif
```

这里 `-f image2` 表示使用图片格式，`-pattern_type glob` 允许你使用通配符来匹配一系列图片，`-i` 后面跟着的是图片的匹配模式。`-vf` 选项用来指定视频滤镜，`fps=10` 表示 GIF 的帧率为每秒 10 帧，`split[s0][s1]` 分割滤镜用来创建两个流，`palettegen` 用来生成调色板，`paletteuse` 用来应用调色板。

### 将图片转换为 MP4

如果你想要将图片转换为 MP4 视频，可以使用类似下面的命令：

```bash
ffmpeg -f image2 -pattern_type glob -i 'image*.jpg' -c:v libx264 -r 30 output.mp4
```

这里 `-c:v libx264` 指定了视频编码器为 H.264，`-r 30` 表示视频的帧率为每秒 30 帧。

在使用这些命令之前，请确保你已经安装了 FFmpeg，并且图片文件与 FFmpeg 可执行文件位于同一目录下，或者提供图片文件的完整路径。同时，根据你的具体需求，你可能需要调整命令中的帧率、编码器等参数。

<!--qr_code-->

## 捐赠

感谢老板请我喝杯咖啡！Thank you for buying me a coffee!

| WeChat | AliPay | PayPal |
| --- | --- | --- |
| ![wechatpay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/wechat_%E6%94%B6%E6%AC%BE%E7%A0%81.jpg) | ![alipay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/alipay.jpg) | [PayPal](https://paypal.me/JianboQin?country.x=C2&locale.x=zh_XC) |

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2024 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
