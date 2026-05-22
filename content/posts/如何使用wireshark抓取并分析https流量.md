---
title: "如何使用 Wireshark 抓取并分析 HTTPS 流量"
date: 2026-05-22T16:30:00+08:00
lastmod: 2026-05-22T16:30:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto/article%20(7).jpg
categories:
  - 技术教程
tags:
  - Wireshark
  - HTTPS
  - 抓包
  - TLS
draft: false
aiSummary: "本文记录如何在 macOS 上使用 Wireshark 抓取 HTTPS 流量，并通过 Chrome 的 SSLKEYLOGFILE 让 Wireshark 解密 HTTP/2 内容。"
aiKeyPoints:
  - "先确认抓对网卡"
  - "用 DNS、TLS SNI 和 IP 过滤定位目标网站"
  - "通过 SSLKEYLOGFILE 解密 HTTPS"
faq:
  - q: "这篇文章讲什么？"
    a: "本文记录如何在 macOS 上使用 Wireshark 抓取 HTTPS 流量，并通过 Chrome 的 SSLKEYLOGFILE 让 Wireshark 解密 HTTP/2 内容。"
  - q: "适合谁阅读？"
    a: "适合需要排查网页请求、接口调用、TLS 连接和网络问题的开发者。"
---

最近排查网页接口时，我重新整理了一套用 Wireshark 抓取 HTTPS 流量的流程。普通抓包只能看到 DNS、IP、TLS 握手和包大小；如果想看到 HTTPS 里的请求路径、请求头和响应内容，还需要配合浏览器导出的 TLS key log。

<!--more-->

## 适用场景

这套方法适合这些场景：

- 想确认浏览器有没有真正访问某个域名。
- 想看网页发起了哪些 HTTP/2 请求。
- 想分析 DNS、TLS 握手、连接失败、重传和延迟问题。
- 想把某个网站的相关流量导出成 `.pcapng` 给别人分析。

注意：只能分析你自己设备、自己账号、自己有权限访问的流量。抓包文件和 TLS key log 可能包含 Cookie、Token、请求体、账号信息，不要随便分享。

## 安装 Wireshark

macOS 可以直接从官网下载安装：

```text
https://www.wireshark.org/download.html
```

安装时如果提示安装 capture helper 或 ChmodBPF，建议允许安装，否则可能没有权限抓取网卡流量。

## 第一步：选对网卡

打开 Wireshark 后，首页会列出多个网卡。macOS 常见网卡如下：

| 网卡 | 常见用途 |
|---|---|
| `en0` | Wi-Fi |
| `en1` / `en5` / `en6` | 有线网卡、USB 网卡、扩展坞 |
| `lo0` | 本机回环地址，也就是 localhost |

最简单的判断方法：看哪个网卡右侧有实时波形。访问网页时波形明显变化的，通常就是当前正在使用的网卡。

## 第二步：先抓普通 HTTPS 流量

双击网卡开始抓包，然后在浏览器里打开目标网站。比如：

```text
https://www.boboidea.com/
```

打开后回到 Wireshark，先用 DNS 过滤：

```wireshark
dns.qry.name contains "boboidea.com"
```

如果能看到记录，说明浏览器发起过域名解析。

再用 TLS SNI 过滤：

```wireshark
tls.handshake.extensions_server_name contains "boboidea.com"
```

如果能看到记录，说明抓到了访问这个域名的 TLS 握手。

## 如果 DNS 和 TLS SNI 都没有结果

常见原因有几个：

1. 抓错了网卡。
2. 浏览器或系统已经缓存 DNS。
3. Chrome 开启了安全 DNS，也就是 DoH。
4. 网站走了 HTTP/3/QUIC。
5. 抓包开始前连接已经建立了。

可以先在终端查目标 IP：

```bash
dig +short www.boboidea.com
```

然后在 Wireshark 里按 IP 过滤：

```wireshark
ip.addr == 目标IP
```

如果怀疑是 QUIC，可以看 UDP 443：

```wireshark
udp.port == 443
```

为了方便分析 HTTPS，建议临时关闭 QUIC，或者用命令启动 Chrome：

```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --disable-quic
```

## 第三步：配置 TLS key log 解密 HTTPS

普通 HTTPS 抓包只能看到：

```text
TLSv1.3 Application Data
```

如果想在 Wireshark 里看到 HTTP/2 请求，需要让 Chrome 把 TLS 会话密钥写入文件。

先彻底关闭 Chrome：

```bash
pkill -x "Google Chrome"
```

然后用环境变量启动 Chrome：

```bash
SSLKEYLOGFILE=$HOME/Desktop/sslkeys.log /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --disable-quic
```

打开目标网站后，检查文件是否生成：

```bash
ls -lh ~/Desktop/sslkeys.log
```

如果没有生成，可以先手动创建：

```bash
touch ~/Desktop/sslkeys.log
chmod 600 ~/Desktop/sslkeys.log
```

然后重新用上面的 `SSLKEYLOGFILE=...` 命令启动 Chrome。

## 第四步：在 Wireshark 里引入 key log

打开 Wireshark 设置：

```text
Wireshark -> Settings -> Protocols -> TLS
```

找到：

```text
(Pre)-Master-Secret log filename
```

填入完整路径：

```text
/Users/你的用户名/Desktop/sslkeys.log
```

不要写 `~/Desktop/sslkeys.log`，有些 GUI 不会展开 `~`。

设置完成后，重新开始抓包，并且必须使用刚才通过 `SSLKEYLOGFILE=...` 打开的那个 Chrome 访问网站。

## 第五步：确认是否解密成功

抓包后可以过滤：

```wireshark
http2
```

如果能看到 `HyperText Transfer Protocol 2`，说明解密成功。

常见字段包括：

```text
:method
:scheme
:authority
:path
user-agent
content-type
```

也可以过滤某个域名：

```wireshark
http2.header.value contains "boboidea.com"
```

如果仍然只能看到：

```text
TLSv1.3 Application Data
```

通常是下面这些原因：

- Chrome 不是通过 `SSLKEYLOGFILE=...` 启动的。
- Wireshark 里 key log 路径填错了。
- 抓包开始前 TLS 连接已经建立。
- Chrome 走了 HTTP/3/QUIC。
- 使用的不是 Chrome/Chromium，或者浏览器不支持 key log。

## 常用过滤器

DNS：

```wireshark
dns
```

某个域名的 DNS：

```wireshark
dns.qry.name contains "example.com"
```

TLS SNI：

```wireshark
tls.handshake.extensions_server_name contains "example.com"
```

某个 IP：

```wireshark
ip.addr == 1.2.3.4
```

HTTPS 端口：

```wireshark
tcp.port == 443
```

HTTP/2：

```wireshark
http2
```

HTTP/3 / QUIC：

```wireshark
quic || http3 || udp.port == 443
```

TCP 重传：

```wireshark
tcp.analysis.retransmission
```

## 导出给别人分析

如果抓包文件太大，不要直接发完整文件。可以先过滤出目标流量：

```wireshark
dns.qry.name contains "boboidea.com" || tls.handshake.extensions_server_name contains "boboidea.com" || ip.addr == 目标IP
```

然后导出当前显示的包：

```text
File -> Export Specified Packets -> Displayed
```

保存为 `.pcapng`。

如果要让别人解密 HTTPS，还需要同时提供 `sslkeys.log`。但这个文件非常敏感，能解密对应抓包里的 HTTPS 内容，除非完全信任对方，否则不要分享。

## 注意事项

- `sslkeys.log` 不是自动存在的，只有用 `SSLKEYLOGFILE=...` 启动浏览器后，新建 HTTPS 连接时才会写入。
- 已经打开的旧 Chrome 窗口不会自动开始写 key log。
- 已经建立的 TLS 连接不会补写历史密钥，最好重新打开页面。
- 抓包文件可能包含账号、Token、Cookie、请求体，导出前要确认范围。
- 分析第三方网站时，只做自己设备上的调试，不要尝试绕过授权或抓取他人数据。

## 一句话总结

用 Wireshark 看 HTTPS，普通抓包先用 DNS、TLS SNI 和 IP 确认有没有抓到；如果要看 HTTP/2 明文内容，就用 `SSLKEYLOGFILE` 启动 Chrome，并在 Wireshark 的 TLS 设置里引入 `sslkeys.log`。
