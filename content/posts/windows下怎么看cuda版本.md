---
title: Windows下怎么看cuda版本
date: 2024-03-05T19:08:34+08:00
lastmod: 2024-03-05T19:08:34+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/windows%E4%B8%8B%E5%A6%82%E4%BD%95%E6%9F%A5%E7%9C%8Bcuda%E7%89%88%E6%9C%AC.jpg
# images:
#   - /img/cover.jpg
categories:
  - AI绘画
tags:
  - CUDA
  - AI绘画
# nolastmod: true
draft: false
---

这篇文章主要讲解 windows 下如何查看 CUDA 的版本。

<!--more-->

在Windows系统下查看CUDA版本的方法有几种：这几种方法需要根据自己实际来用，可以都试一遍。

## **命令提示符**:
   - 打开命令提示符（按下`Win + R`，输入`cmd`，然后回车）。
   - 输入以下命令并回车：
     ```
     nvcc --version
     ```
     如果CUDA正确安装，这个命令会显示CUDA的版本信息。
## **NVIDIA系统信息工具**:
   - 下载并运行NVIDIA提供的系统信息工具`NVIDIA System Information Utility`。
   - 在工具的输出中查找CUDA版本信息。
## **设备管理器**:
   - 右键点击开始菜单，选择“设备管理器”。
   - 展开“显示适配器”，找到你的NVIDIA显卡。
   - 右键点击显卡，选择“属性”。
   - 切换到“驱动程序”选项卡，点击“驱动程序详细信息”。
   - 在出现的列表中查找名为`nvcc`的文件，其版本号通常包含了CUDA版本信息。
## **环境变量**:
   - 打开命令提示符。
   - 输入以下命令并回车：
     ```
     echo %CUDA_PATH%
     ```
     如果设置了CUDA环境变量，这个命令会显示CUDA的安装路径，从中可以推断出CUDA版本。
## **NVIDIA驱动程序控制面板**:
   - 右键点击桌面上的空白区域，选择“NVIDIA控制面板”。
   - 在左边的菜单中选择“系统信息”，这里通常会显示CUDA版本信息。
以上方法中，使用命令提示符运行`nvcc --version`是最直接的方法。如果CUDA没有正确安装或者环境变量没有设置，可能需要使用其他方法来确定CUDA版本。

注意：nvcc 需要电脑安装了才行，不一定能够找到命令。

<!--qr_code-->

## 捐赠

感谢老板请我喝杯咖啡！Thank you for buying me a coffee!

| WeChat | AliPay | PayPal |
| --- | --- | --- |
| ![wechatpay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/wechat_%E6%94%B6%E6%AC%BE%E7%A0%81.jpg) | ![alipay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/alipay.jpg) | [PayPal](https://paypal.me/JianboQin?country.x=C2&locale.x=zh_XC) |

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
