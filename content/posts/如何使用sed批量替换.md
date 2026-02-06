---
title: 如何使用sed批量替换?
date: 2017-12-30T18:38:29+08:00
lastmod: 2021-09-28T18:38:29+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 技术文章
tags:
  - sed
  - 批量替换
# nolastmod: true
draft: true
build:
  render: never
  list: never
  publishResources: false
aiSummary: "如何使用sed批量替换？"
aiKeyPoints:
  - "如何使用sed批量替换？"
faq:
  - q: "这篇文章讲什么？"
    a: "如何使用sed批量替换？"
  - q: "适合谁阅读？"
    a: "适合关注“如何使用sed批量替换?”相关主题的读者。"
---

如何使用sed批量替换？

<!--more-->

> 执行命令：

```
sed -i "s/Liugj\\\Arch/ShopApiOld/g" `grep -rl 'Liugj\\\Arch' src/`
```

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
