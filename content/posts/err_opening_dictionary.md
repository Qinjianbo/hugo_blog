---
title: 如何解决 error opening dictionary /usr/share/appdata
date: 2020-11-07T21:54:11+08:00
lastmod: 2021-09-28T21:54:11+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/error opening dictionary.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - appdata
  - error
# nolastmod: true
draft: false
---

今天安装了一个flameshot,但是在打开时报错error opening dictionary /usr/share/appdata，在此记录解决方法

<!--more-->

> 报错：error opening dictionary /usr/share/appdata 如何解决？

> 打开命令行终端，然后执行：

```
killall snap-store
```

> 然后再重新打开flameshot，问题就解决了。

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
