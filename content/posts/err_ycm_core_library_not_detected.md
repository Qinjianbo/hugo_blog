---
title: YCM core library not detected; you need to compile YCM before using it
date: 2020-12-12T22:01:06+08:00
lastmod: 2021-09-28T22:01:06+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: /img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - YCM
  - vim
# nolastmod: true
draft: true
---

今天在brew upgrate 后，vim升级了版本，再打开vim编辑文件时报错YCM core library not detected; you need to compile YCM before using it

<!--more-->

今天在brew upgrate 后，vim升级了版本，再打开vim编辑文件时报错YCM core library not detected; you need to compile YCM before using it，那么如何解决这个问题呢？

解决方案：我是这么解决的

在控制台执行下面的命令：

```shell
cd
cd cd .vim/plugged/YouCompleteMe
./install.py
```

等待上面的install完成，再用vim编辑东西就不会报错了

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
