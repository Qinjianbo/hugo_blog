---
title: homebrew undefined method `xxx`
date: 2021-11-29T21:44:29+08:00
lastmod: 2021-09-28T21:44:29+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: /img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - homebrew
# nolastmod: true
draft: false
---

homebrew undefined method `license'，homebrew 安装软件过程中出错，找不到方法xxx

<!--more-->

今天在使用homebrew安装openconnect时，报错 homebrew undefined method `license' #<Class:0x00007fd15fc92fb0>

查了一下，并未找到一个确定的原因，但是通过尝试，最终解决了问题。

解决方法是更新homebrew

在终端执行：brew update -v

等待更新完成后，再执行 brew install openconnect ， 就可以成功安装了

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
