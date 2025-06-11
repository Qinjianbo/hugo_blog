---
title: 各平台下如何修改 hosts
date: 2025-06-05T09:52:20+08:00
lastmod: 2025-06-05T09:52:20+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/%E5%93%94%E5%93%A9%E5%93%94%E5%93%A9%E4%B8%8A%E6%90%9C%E9%9B%86%E7%9A%84%E7%BE%8E%E5%9B%BE%E8%89%B2%E5%9B%BE_1-1000/21.jpg
categories:
  - 网络工具
  - 系统运维
tags:
  - hosts
  - 系统配置
  - 网络
  - 跨平台
# nolastmod: true
draft: false
---

在日常开发、测试或访问特定网站时，我们经常需要修改本地的 hosts 文件来实现域名解析的自定义。本文将介绍在 Windows、macOS 和 Linux 各平台下如何安全、有效地修改 hosts 文件。

<!--more-->

## 什么是 hosts 文件？

hosts 文件是操作系统用于将主机名（域名）映射到 IP 地址的本地文本文件。通过编辑 hosts 文件，可以实现本地 DNS 解析的定制，常用于：
- 屏蔽广告或恶意网站
- 本地开发环境域名映射
- 测试新服务器迁移

## 各平台 hosts 文件路径

- **Windows**：`C:\Windows\System32\drivers\etc\hosts`
- **macOS**：`/etc/hosts`
- **Linux**：`/etc/hosts`

## Windows 下如何修改 hosts

1. **以管理员身份运行记事本**：
   - 在开始菜单搜索"记事本"，右键选择"以管理员身份运行"。
2. **打开 hosts 文件**：
   - 在记事本中选择"文件"→"打开"，输入路径 `C:\Windows\System32\drivers\etc\hosts`，文件类型选择"所有文件"。
3. **编辑并保存**：
   - 按需添加或修改内容，保存文件。

> ⚠️ 修改 hosts 需要管理员权限，否则无法保存。

## macOS 下如何修改 hosts

1. **打开终端**：
   - 可通过 Spotlight（快捷键 Command + 空格，输入"终端"）打开。
2. **使用 nano 编辑 hosts 文件**：
   ```bash
   sudo nano /etc/hosts
   ```
3. **输入密码并编辑**：
   - 按需修改内容，编辑完成后按 `Ctrl+O` 保存，`Ctrl+X` 退出。
4. **刷新 DNS 缓存**（可选）：
   ```bash
   sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
   ```

## Linux 下如何修改 hosts

1. **打开终端**。
2. **使用文本编辑器（如 vim、nano）编辑 hosts 文件**：
   ```bash
   sudo nano /etc/hosts
   ```
3. **保存并退出**。
4. **刷新 DNS 缓存**（部分发行版可选）：
   ```bash
   sudo systemctl restart NetworkManager
   ```

## 编辑 hosts 文件的注意事项

- 每条记录一行，格式为：`IP地址 域名`，如：
  ```
  127.0.0.1   local.test.com
  192.168.1.1 myserver.local
  ```
- IP 与域名之间用空格或 Tab 分隔。
- 修改前建议备份原文件。
- 修改后如未生效，可尝试刷新 DNS 缓存或重启网络服务。

## 常见问题解答

- **Q: 修改 hosts 后无效？**
  - 检查是否有管理员权限。
  - 检查文件格式和内容是否正确。
  - 尝试刷新 DNS 缓存或重启电脑。

- **Q: 如何还原 hosts 文件？**
  - 用备份文件覆盖即可，或删除自定义内容恢复默认。

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