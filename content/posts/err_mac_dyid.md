---
title: MAC dyld Library not loaded /usr/local/opt/openssl/lib/libssl
date: 2020-05-03T22:13:14+08:00
lastmod: 2021-09-28T22:13:14+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/MAC dyld Library not loaded.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - mac
  - libssl
  - openssl
# nolastmod: true
draft: false
---

在执行nginx -t 时报错：dyld: Library not loaded: /usr/local/opt/openssl/lib/libssl.1.0.0.dylib

<!--more-->

今天在自己的mac上执行命令：
```
nginx -t
```
然后发现报错：
```
dyld: Library not loaded: /usr/local/opt/openssl/lib/libssl.1.0.0.dylib
```
在网上搜索了一下这个错误信息，看文章说执行一下：
```
brew switch openssl 1.0.2s
```
在本地尝试后，错误解除，在此记录，以便后用。

<!--declare-declare-->

Copyright &copy; 2017 - 2024 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
