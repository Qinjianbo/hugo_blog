---

title: 如何使用ffmpeg将png图片转换成视频
date: 2024-03-17T10:54:01+08:00
lastmod: 2024-03-17T10:54:01+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto/article%20(13).jpg
# images:
#   - /img/cover.jpg
categories:
  - 视频制作
tags:
  - ffmpeg
  - 图片转视频
# nolastmod: true
draft: false
---
FFmpeg是一个强大的开源工具，可以用来录制、转换和流化音频和视频。在本文中，我们将学习如何使用FFmpeg将一系列png图片转换成视频文件。
<!--more-->
## 安装FFmpeg
首先，您需要确保您的系统上安装了FFmpeg。您可以从FFmpeg官网下载并安装它，或者使用包管理器进行安装。例如，在Ubuntu上，您可以使用以下命令：
```bash
sudo apt update
sudo apt install ffmpeg
```
在Windows上，您需要下载安装程序并按照提示进行安装。
## 准备图片
确保所有png图片都位于同一个文件夹中，并且按照您希望它们在视频中出现的顺序进行排序。图片应该以递增的数字顺序命名，例如`image1.png`、`image2.png`，以此类推。
## 使用FFmpeg将png图片转换成视频
打开命令提示符或终端，然后导航到包含图片的文件夹。使用以下FFmpeg命令将png图片转换成视频：
```bash
ffmpeg -f image2 -pattern_type glob -i '*.png' output.mp4
```
这里解释一下命令中的选项：
- `-f image2`：指定输入格式为图片。
- `-pattern_type glob`：允许使用glob通配符。
- `-i '*.png'`：指定输入文件的模式，这里匹配所有png文件。
- `output.mp4`：指定输出视频的文件名。
如果您想要控制视频的帧率，可以使用`-r`选项，例如：
```bash
ffmpeg -f image2 -pattern_type glob -i '*.png' -r 24 output.mp4
```
这将设置视频的帧率为每秒24帧。
## 高级调整
FFmpeg提供了许多其他选项，允许您进行更高级的调整，例如：
- `-s`：设置视频大小。
- `-c:v`：指定视频编码器。
- `-q:v`：设置视频质量。
例如，如果您想要创建一个高质量的视频，可以使用以下命令：
```bash
ffmpeg -f image2 -pattern_type glob -i '*.png' -s 1920x1080 -c:v libx264 -q:v 1 output.mp4
```
这将创建一个1920x1080分辨率的视频，使用x264编码器，并且质量设置为最高。
使用FFmpeg将png图片转换成视频是一个简单的过程，但这个工具的强大之处在于它提供了无数的自定义选项，让您可以根据需要创建几乎任何类型的视频输出。

## 捐赠

感谢老板请我喝杯咖啡！Thank you for buying me a coffee!

| WeChat | AliPay | PayPal |
| --- | --- | --- |
| ![wechatpay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/wechat_%E6%94%B6%E6%AC%BE%E7%A0%81.jpg) | ![alipay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/alipay.jpg) | [PayPal](https://paypal.me/JianboQin?country.x=C2&locale.x=zh_XC) |

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】