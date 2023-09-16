---
title: MySQL复制之复制概述
date: 2018-07-07T17:50:59+08:00
lastmod: 2021-09-28T17:50:59+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 运维必备
tags:
  - mysql
  - 主从复制
# nolastmod: true
draft: false
---

记录mysql学习过程中对复制概念的学习。

<!--more-->

### 复制的概述：

1. 复制是干啥滴？

   实现数据库间的数据同步。

2. 实现复制的方式有哪两种？

    a. 基于行复制

    b. 基于语句复制

3. 复制会产生的问题？

    主从不一致问题，且延迟不可控

4. 复制的兼容性？

    向后兼容，新版MySQL可以作为旧版MySQL的从库。

### 复制解决的问题是什么：

1. 数据分布
2. 负载均衡
3. 备份
4. 可用性和故障切换
5. MySql升级测试

### 复制是如何工作的：拢共分三步

1. 主库开启二进制日志记录 -- record binary log
2. 从库将主库的binary log复制到自己的中继日志 -- copy binary log to relay log
3. 从库读取relay log并进行重放

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
