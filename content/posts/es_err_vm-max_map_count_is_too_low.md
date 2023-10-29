---
title: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
date: 2017-12-30T18:40:47+08:00
lastmod: 2021-09-28T18:40:47+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/max virtual memory areas vm.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - elasticsearch
# nolastmod: true
draft: false
---

[Elasticsearch] 启动报错：max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

<!--more-->

# [Elasticsearch] 启动报错：max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

## 解决办法（有两种）

1. 执行命令

       sudo sysctl vm.max_map_count=524288

2. 修改配置：在**/etc/sysctl.conf** 中加入

       vm.max_map_count=524288

    然后执行命令：

        sudo sysctl -p

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
