---
title: 如何将gif转换成mp4
date: 2024-03-03T22:46:32+08:00
lastmod: 2024-03-03T22:46:32+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/%E5%A6%82%E4%BD%95%E5%B0%86gif%E5%9B%BE%E8%BD%AC%E6%8D%A2%E6%88%90%E8%A7%86%E9%A2%91.jpg
# images:
#   - /img/cover.jpg
categories:
  - AI绘画
tags:
  - AI绘画
  - gif
  - ffmpeg
# nolastmod: true
draft: true
---

本篇文章主要讲述如何将gif图片转换成视频。

<!--more-->

将GIF转换为MP4格式可以通过多种方式完成，包括使用在线工具、视频编辑软件或命令行工具。以下是几种常见的方法：
### 在线工具
1. **Online-Convert.com**：
   - 访问 [Online-Convert.com](https://convertio.co/gif-mp4/)。
   - 上传你的GIF文件。
   - 选择输出格式为MP4。
   - 调整视频设置（如果需要）。
   - 点击“转换”按钮。
2. **CloudConvert**：
   - 访问 [CloudConvert](https://cloudconvert.com/gif-to-mp4)。
   - 按照指示上传GIF文件并选择输出格式为MP4。
   - 调整设置。
   - 开始转换。
### 视频编辑软件
1. **Adobe Premiere Pro**：
   - 在Premiere Pro中导入GIF文件。
   - 将GIF文件拖到时间轴上。
   - 导出视频，选择MP4格式。
2. **Final Cut Pro**：
   - 在Final Cut Pro中导入GIF文件。
   - 将GIF文件添加到时间线。
   - 使用“共享”功能导出为MP4格式。
### 命令行工具
1. **ffmpeg**：
   - 首先，确保你已经安装了ffmpeg。
   - 打开命令行界面。
   - 使用以下命令进行转换：
     ```
     ffmpeg -i input.gif -c:v libx264 -pix_fmt yuv420p output.mp4
     
     这里，-c:v libx264 指定了视频编码器，-pix_fmt yuv420p 指定了像素格式，这是许多播放器和设备的通用格式。
     ```
     这条命令会读取名为`input.gif`的文件，并将其转换为名为`output.mp4`的MP4文件。
选择哪种方法取决于你的具体需求和个人偏好。在线工具通常是最简单的选择，尤其是如果你不经常需要进行这种转换。如果你需要更高级的控制或者经常进行视频转换，使用视频编辑软件或命令行工具可能更合适。

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
