---
title: twitter雪花算法|snowflake
date: 2021-10-19T17:51:00+08:00
lastmod: 2021-10-19T17:51:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/twitter雪花算法snowflake.jpg
# images:
#   - /img/cover.jpg
categories:
  - 分布式
tags:
  - snowflake
  - 雪花算法
# nolastmod: true
draft: false
---

本文主要介绍分布式唯一ID生成算法--雪花算法。

<!--more-->

## 分布式唯一ID的要求

- 全局唯一性(must)
- 趋势递增(must)
- 单调递增(should)
- 安全(无规律可循)(should)

## twitter雪花算法原理

![](/img/posts/snowflake.png)

> 雪花算法使用一个64位的整数来表示一个唯一ID

> 这64bits如图被分成了5个部分:
- 1bit 作为符号位，总是为0
- 41bits 用来存储毫秒时间戳，计算后可知约可用69年
- 5bits 用来存储数据中心ID，最多可以表示32个数据中心
- 5bits 用来存储工作机器ID，最多可以表示32台工作机器
- 12bits 用来在同节点时间相同时作为自增ID标识唯一性，同1ms可以表示最多4096个ID，所以理论上1s内可以生成约409W个ID

> 注意：数据中心ID+工作机器ID可以唯一确定一个节点，最多可以表示1024个节点

## twitter雪花算法的优缺点

> 根据雪花算法的原理，我们可以很清楚的看出雪花算法有哪些优缺点

> 优点：
- 无依赖（Redis、DB等）
- 秒级别生成百万级ID，速度够快
- 生成的ID是趋势递增的，有利于提升MySQL数据库的插入效率

> 缺点：
- 强依赖时间，时钟回拨会导致生成重复ID
- 1024节点数不一定够用
- 机器ID分配后无法自动回收,重新使用

## 非一成不变

> 雪花算法并不是一成不变的，业务可以根据自身需求，对雪花算法进行变种开发，进而定制出符合自身业务需求的雪花算法。

> 比如：`5bits`数据中心ID，`5bits`工作机器ID，你可以拆分成`3bits`数据中心ID，`7bits`工作机器ID，这样机器ID就可以多一些，数据中心ID就会少一些。

> 再比如：你觉得`41bits`的太多了，可能你们用不了那么些年，就可以分几bits出来用来干别的事情。

## 开源分布式ID框架

以下两个框架分别以不同方式在不同程度上解决了twitter雪花算法的缺点，感兴趣的小伙伴可自行到github中进行研习。

1. [百度的UIDGenerator](https://github.com/baidu/uid-generator)
2. [美团的Leaf](https://github.com/Meituan-Dianping/Leaf)

<!--qr_code-->

## 公众号: 无限递归

> 欢迎扫码关注，共同学习进步

> ![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
