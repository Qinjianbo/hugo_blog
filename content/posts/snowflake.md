---
title: 雪花算法|snowflake
date: 2021-10-19T17:51:00+08:00
lastmod: 2021-10-19T17:51:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: /img/posts/hzw17.jpeg
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

## twitter雪花算法原理

![](/img/posts/snowflake.png)

> 雪花算法使用一个64位的整数来表示一个唯一ID

> 这64bits如图被分成了5个部分:
- 1bit 作为符号位，总是为0
- 41bits 用来存储毫秒时间戳，计算后可知约可用49年
- 5bits 用来存储数据中心ID，最多可以表示32个数据中心
- 5bits 用来存储工作机器ID，最多可以表示32台工作机器
- 12bits 用来在同节点时间相同时作为自增ID标识唯一性，同1ms可以表示最多4096个ID，所以理论上1s内可以生成约409W个ID

> 注意：数据中心ID+工作机器ID可以唯一确定一个节点，最多可以表示1024个节点

## twitter雪花算法的优缺点

> 根据雪花算法的原理，我们可以很清楚的看出雪花算法有哪些优缺点

> 优点：
- 无依赖（Redis、DB等）
- 秒级别生成百万级ID，速度够快

> 缺点：
- 

## 开源分布式ID框架

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
