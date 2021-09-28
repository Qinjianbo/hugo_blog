---
title: PHP中的mkdir如何创建0777权限的文件夹
date: 2019-08-10T17:22:09+08:00
lastmod: 2021-09-28T17:22:09+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: /img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 技术文章
tags:
  - mkdir
  - php
# nolastmod: true
draft: false
---

PHP中的mkdir写的0777创建出来的并不是0777

<!--more-->

 测试文件：

    <?php
    mkdir('./test/test/', 0777, true);

创建出来的结果：

    drwxr-xr-x  3 qinjianbo  staff    96B  8 10 14:52 test

可以看到我第二个参数写的是0777，但是创建出来的确实0755的文件夹，所以在使用mkdir时要注意一下。

那如何创建出0777的文件目录呢？需要用下面这种写法：

    <?php
		$oldmask = umask(0);
		mkdir('./test/test', 0777, true);
		umask($oldmask);

    drwxrwxrwx  3 qinjianbo  staff    96B  8 10 15:11 test1

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
