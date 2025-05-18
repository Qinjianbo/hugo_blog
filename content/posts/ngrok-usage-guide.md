---
title: "如何使用ngrok"
date: 2025-05-18T23:04:39+08:00
lastmod: 2025-05-18T23:04:39+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/%E5%93%94%E5%93%A9%E5%93%94%E5%93%A9%E4%B8%8A%E6%90%9C%E9%9B%86%E7%9A%84%E7%BE%8E%E5%9B%BE%E8%89%B2%E5%9B%BE_1-1000/19.jpg
categories:
  - 网络工具
  - 实用教程
tags:
  - ngrok
  - 内网穿透
  - 端口映射
  - 教程
# nolastmod: true
draft: true
---

ngrok 是一款非常流行的内网穿透工具，可以让你本地的 Web 服务（如 n8n、网站、API 等）快速暴露到公网，方便外部访问和调试。本文将详细介绍 ngrok 的原理、注册、配置、使用步骤及常见问题。

<!--more-->

## 一、ngrok 原理简介

ngrok 通过在本地和云端服务器之间建立安全隧道，将本地端口映射到一个公网地址。外部用户访问该公网地址时，流量会自动转发到你本地服务，实现"内网穿透"。

**典型应用场景：**
- 本地开发调试 Webhook、API 回调
- 远程演示本地项目
- 临时让外部用户访问本地服务

## 二、注册与下载

1. 访问 [ngrok 官网](https://ngrok.com/)，注册一个免费账号。
2. 登录后，在 Dashboard 获取你的 **Authtoken**（认证令牌）。
3. 下载适合你操作系统的 ngrok 客户端（Windows 用户下载 zip 包并解压）。

## 三、配置 ngrok

1. 打开命令行（PowerShell/CMD/终端），进入 ngrok 解压目录。
2. 运行以下命令绑定账号（只需执行一次）：

   ```bash
   ngrok config add-authtoken 你的Authtoken
   ```

## 四、启动本地服务

确保你的本地服务（如 n8n、网站等）已启动，假设端口为 5678。

## 五、启动 ngrok 隧道

在 ngrok 目录下运行：

```bash
ngrok http 5678
```

ngrok 会分配一个公网地址（如 `https://xxxx.ngrok.io`），外部用户可通过该地址访问你的本地服务。

## 六、常见问题与扩展

**Q: 免费版 ngrok 有什么限制？**  
A: 免费版每次启动分配的公网地址不同，带宽有限，适合临时测试或开发。付费版支持自定义域名、固定地址和更高带宽。

**Q: ngrok 支持 HTTPS 吗？**  
A: 支持，ngrok 默认分配 https 和 http 两种访问方式。

**Q: ngrok 需要公网 IP 吗？**  
A: 不需要，ngrok 通过云端中转，无需公网 IP。

**Q: 如何让 ngrok 启动多个端口？**  
A: 可通过配置文件或多开命令行窗口实现，具体见官方文档。

## 七、参考链接

- [ngrok 官方文档](https://ngrok.com/docs)
- [内网穿透原理详解](https://zhuanlan.zhihu.com/p/37051983)

## 小结

ngrok 是开发者必备的内网穿透工具，配置简单、跨平台，适合本地服务临时对外开放。建议注册账号获取更高配额，生产环境建议选择付费版或自建穿透方案。

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