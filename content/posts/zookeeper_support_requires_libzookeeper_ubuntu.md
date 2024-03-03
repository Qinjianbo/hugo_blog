---
title: zookeeper support requires libzookeeper ubuntu
date: 2020-01-12T16:15:50+08:00
lastmod: 2021-09-28T16:15:50+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/zookeeper support requires libzookeeper ubuntu.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - zookeeper
  - ubuntu
# nolastmod: true
draft: false
---

pecl install zookeeper error zookeeper support requires libzookeeper

<!--more-->

在ubuntu 中使用pecl 安装 php zookeeper 扩展时，总是提示，找不到 libzookeeper，提示关键字有：zookeeper support requires libzookeeper

然后使用 apt-cache search libzookeeper

发现有下面一些包：

```
libzookeeper-java - Core Java libraries for zookeeper
libzookeeper-java-doc - API Documentation for zookeeper
libzookeeper-mt-dev - Development files for multi threaded zookeeper C bindings
libzookeeper-mt2 - Multi threaded C bindings for zookeeper
libzookeeper-st-dev - Development files for single threaded zookeeper C bindings
libzookeeper-st2 - Single threaded C bindings for zookeeper
```

然后我就尝试安装了 apt-get install libzookeeper-mt-dev， 安装完成后，再运行 pecl install zookeeper-0.6.4.tgz

结果安装成功，问题成功解决。。。。

看到网上有很多说下载zookeeper 源码，然后进入src/c 进行编译安装的，但是在apache 官网下载的zookeeper 资源中并未找到 src/c 。。。

不过还好通过上面的方式解决了这个问题： zookeeper support requires libzookeeper

<!--declare-declare-->

Copyright &copy; 2017 - 2024 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
