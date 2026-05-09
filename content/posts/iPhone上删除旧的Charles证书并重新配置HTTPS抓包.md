---
title: iPhone上删除旧的Charles证书并重新配置HTTPS抓包
date: 2026-05-09T09:20:00+08:00
lastmod: 2026-05-09T09:20:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
categories:
  - 问题积累
tags:
  - Charles
  - iPhone
  - HTTPS抓包
  - 证书
draft: false
aiSummary: "这篇文章记录了如何在 iPhone 上删除旧的 Charles 证书，重新下载并安装新的 Charles Proxy CA，并完成 HTTPS 抓包验证。"
aiKeyPoints:
  - "删除 iPhone 上旧的 Charles 证书"
  - "重新安装并信任 Charles Proxy CA"
  - "验证 Safari HTTPS 抓包是否正常"
faq:
  - q: "这篇文章讲什么？"
    a: "这篇文章介绍如何在 iPhone 上删除旧的 Charles 证书，并重新配置 HTTPS 抓包环境。"
  - q: "适合谁阅读？"
    a: "适合需要在 iPhone 上用 Charles 抓 HTTPS 请求、但遇到证书混乱或重复证书问题的读者。"
---

在 iPhone 上配 Charles 抓包时，最容易把人卡住的地方不是代理，而是证书。尤其是之前装过多次 `Charles Proxy CA`，在 `证书信任设置` 里看到两个甚至多个同名证书时，后面经常会出现下载不了新证书、HTTPS 站点打不开，或者 Charles 里只能看到乱码的问题。

<!--more-->

这篇文章把我刚处理完的一套流程整理一下，目标很简单：先删掉 iPhone 上旧的 Charles 证书，再重新安装一张新的证书，把 HTTPS 抓包恢复正常。

## 适用场景

如果你遇到下面这些情况，这套流程基本都适用：

- iPhone 的 `证书信任设置` 里出现两个 `Charles` 相关证书
- 访问 `http://chls.pro/ssl` 没有正常弹出下载
- Charles 已经能抓到手机流量，但 HTTPS 内容还是看不到明文
- Safari 打开 HTTPS 网站提示不安全，或者 App 请求异常

## 第一步：删除 iPhone 上旧的 Charles 证书

先不要急着重新安装，旧证书不清掉，新的配置很容易继续乱。

### 1. 删除描述文件

打开：

`设置 -> 通用 -> VPN与设备管理`

如果这里能看到 `Charles Proxy CA` 或者类似名称的描述文件，点进去直接删除。

这里要注意一件事：  
只在 `证书信任设置` 里把开关关掉，不算真正删除证书。真正的删除入口还是在 `VPN与设备管理` 里。

### 2. 检查证书信任设置

再打开：

`设置 -> 通用 -> 关于本机 -> 证书信任设置`

确认里面和 `Charles` 相关的证书都已经不存在，或者至少不再保留旧的信任状态。

如果这里之前出现两个 `Charles` 证书，通常说明历史上安装过不止一次，按上面的方式逐个删掉对应描述文件即可。

## 第二步：确认手机代理已经正确指向 Charles

证书下载页 `chls.pro/ssl` 能不能正常打开，前提是手机流量真的经过了 Charles。

打开 iPhone 当前 Wi-Fi 的详情页，找到：

`配置代理 -> 手动`

然后填写：

- 服务器：你的 Mac 在局域网中的 IP 地址，比如 `192.168.x.x`
- 端口：Charles 的代理端口，默认一般是 `8888`

这里不要填：

- `127.0.0.1`
- `localhost`

因为这两个地址在手机上指向的是手机自己，不是你的 Mac。

同时确认这几件事：

- iPhone 和 Mac 在同一个局域网
- Mac 上的 Charles 已经打开
- Charles 没有拒绝手机的连接请求

## 第三步：重新下载并安装新的 Charles 证书

代理确认无误后，在 iPhone 的 Safari 中访问：

`http://chls.pro/ssl`

这里一定要用 `http`，不要写成 `https`。

正常情况下，iPhone 会提示下载一个描述文件。下载完成后继续：

`设置 -> 通用 -> VPN与设备管理`

找到刚下载的 `Charles Proxy CA`，点进去安装。

安装完成后，还差最后一步信任：

`设置 -> 通用 -> 关于本机 -> 证书信任设置`

把新安装的 `Charles Proxy CA` 开关打开，明确设为信任。

## 第四步：验证 HTTPS 抓包是否恢复正常

证书安装完以后，直接在 Safari 里打开一个普通 HTTPS 网站，比如：

`https://example.com`

然后回到 Charles 看请求详情：

- 如果可以看到正常的 `Request` 和 `Response`
- 如果 `Contents` 不再是乱码

那就说明这次 HTTPS 抓包已经打通了。

如果还是不正常，继续检查这几个点：

- Charles 里是否已经开启 `Enable SSL Proxying`
- 是否给目标域名加了 SSL Proxying 规则
- 手机请求是否真的经过 Charles
- 目标 App 是否做了证书绑定（certificate pinning）

最后这一条很关键：  
Safari 能抓，不代表所有 App 都一定能抓。有些 App 自带证书校验，就算 Charles 配好了，也可能仍然失败。

## 注意事项

- `http://chls.pro/ssl` 打不开时，优先怀疑代理没有真正走通
- `证书信任设置` 里关开关，不等于删除证书本身
- 删除旧证书后再装新证书，排错效率最高
- Mac 本机浏览器先确认可以正常抓 HTTPS，再配置 iPhone，路径会更清晰

## 一句话总结

iPhone 上 Charles HTTPS 抓包出问题时，最稳妥的处理方式就是：先删掉旧证书，再确认代理走通，最后重新访问 `http://chls.pro/ssl` 安装并信任新的 `Charles Proxy CA`。

<!--declare-declare-->

Copyright &copy; 2017 - 2026 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
