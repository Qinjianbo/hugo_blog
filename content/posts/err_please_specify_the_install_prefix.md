---
title: Please specify the install prefix of iconv with --with-iconv=
date: 2019-12-22T22:28:26+08:00
lastmod: 2021-09-28T22:28:26+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/Please specify the install.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - 编译PHP
  - iconv
# nolastmod: true
draft: false
---

Please specify the install prefix of iconv with --with-iconv=<DIR>

<!--more-->

> 自己在mac上编译安装PHP过程中遇到了这个报错:

```
Please specify the install prefix of iconv with --with-iconv=<DIR>
```

> 特此记录一下如何处理，才能解决这个报错。

> 如果你不需要用到iconv的话，那么你可以在./configure 执行后面增加参数 --without-iconv

```
./configure --without-iconv
```

> 这样的话，在预编译过程中就不会进行iconv的检查了。

> 如果你是需要用到iconv的话，那么你可以先在命令行中执行：

```
iconv --help
```

> 看看是否已经安装了iconv到本地，我这里是输出了正确结果的，但是我用whereis iconv看到iconv的路径是 /usr/bin/iconv， 然后我指定了 --with-iconv=/usr/bin/iconv，结果依然报错。

> 后来我用brew从新安装了libiconv

```
brew install libiconv
```

> 安装完成后，我使用下面的命令指定了libiconv的路径，结果就预编译成功了

```
./configure --with-iconv=$(brew --prefix libiconv)
```

> 希望也能帮到别的遇到同样错误的小伙伴。

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
