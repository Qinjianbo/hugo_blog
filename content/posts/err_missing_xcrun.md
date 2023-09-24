---
title: missing xcrun at ...
date: 2021-04-05T21:35:01+08:00
lastmod: 2021-09-28T21:35:01+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/hzw8.jpeg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - mac系统更新
  - xcode-select
# nolastmod: true
draft: false
---

xcrun: error: invalid active developer path (/Library/Developer/CommandLineTools), missing xcrun at: /Library/Developer/CommandLineTools/usr/bin/xcrun

<!--more-->

今天在升级了Mac系统后，在item里面运行git命令后报错：missing xcrun at: /Library/Developer/CommandLineTools/usr/bin/xcrun

解决方案：执行命令

```
xcode-select --install
```

之后再执行git命令就可以了

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
