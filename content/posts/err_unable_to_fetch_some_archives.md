---
title: Unable to fetch some archives, maybe run apt-get update or try with
date: 2020-01-11T22:19:43+08:00
lastmod: 2021-09-28T22:19:43+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: /img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - apt-get
  - fix-missing
# nolastmod: true
draft: false
---

Unable to fetch some archives, maybe run apt-get update or try with --fix-missing

<!--more-->

> 今天在ubuntu上安装软件的时候，总是会报：Unable to fetch some archives, maybe run apt-get update or try with --fix-missing 错误。

> 解决办法就是：更换apt-get 的源。

```
cd /etc/apt
sudo mv sources.list sources.list.bak
sudo vim sources.list
```

> 这里打开sources.list后，将从 [这里](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/) 获取到的源写入，然后保存退出

> 然后再执行:

```
sudo apt-get update
```

> 执行完上面的步骤后，再安装就可以了

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
