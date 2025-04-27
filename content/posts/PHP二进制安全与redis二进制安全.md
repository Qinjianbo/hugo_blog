---
title: PHP二进制安全与redis二进制安全
date: 2018-09-03T17:41:41+08:00
lastmod: 2021-09-28T17:41:41+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/PHP二进制安全与redis二进制安全.jpg
# images:
#   - /img/cover.jpg
categories:
  - 技术文章
tags:
  - php
  - 二进制安全
# nolastmod: true
draft: false
---

PHP二进制安全与redis二进制安全写的比较明白的文章链接记录

<!--more-->

文章地址:https://blog.csdn.net/foxman209/article/details/41441759

二进制安全：是啥就是啥

这篇文章主要解释了php中的二进制安全和redis中的二进制安全。

C语言中在读取字符串时，是以空字符作为一个字符串的结尾的。

PHP的字符串结构和Redis的字符串结构都定义了自己的数据结构，它们两个的字符串结构中都多了一个len，即表示字符串长度，在读取字符串时是以长度读取，而不是以空字符作为字符串的结尾。

正是数据结构中的那个len ，保证了PHP 和 Reids的二进制安全。

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
