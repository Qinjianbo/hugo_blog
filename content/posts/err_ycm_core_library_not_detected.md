---
title: YCM core library not detected; you need to compile YCM before using it
date: 2020-12-12T22:01:06+08:00
lastmod: 2021-09-28T22:01:06+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/YCM core library not detected.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - YCM
  - vim
# nolastmod: true
draft: false
---

今天在brew upgrate 后，vim升级了版本，再打开vim编辑文件时报错YCM core library not detected; you need to compile YCM before using it

<!--more-->

> 今天在brew upgrate 后，vim升级了版本，再打开vim编辑文件时报错YCM core library not detected; you need to compile YCM before using it

> 解决方案：

> 在控制台执行下面的命令：

```shell
cd
cd cd .vim/plugged/YouCompleteMe
./install.py
```

> 等待上面的install完成，再用vim编辑东西就不会报错了

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
