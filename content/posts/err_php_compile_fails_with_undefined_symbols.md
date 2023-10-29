---
title: PHP compile fails with undefined symbols for architecture x86_64
date: 2019-12-22T22:26:09+08:00
lastmod: 2021-09-28T22:26:09+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/PHP compile fails with undefined.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - php
  - x86_64
# nolastmod: true
draft: false
---

PHP compile fails with undefined symbols for architecture x86_64

<!--more-->

> 今日在编译安装PHP时，遇见这么一个错：

```
PHP compile fails with undefined symbols for architecture x86_64
```

> 然后在stackoverflow 上找到个答案试了下，果真可以了，记录一下，以备后面可以使用。

```
brew install libiconv (libiconv will install in /usr/local/opt/libiconv/)
find EXTRA_LIBS variable in MakeFile.
change -liconv to /usr/local/opt/libiconv/lib/libiconv.dylib
Here is the reason:

Mac os has its own libiconv.dylib in dir/usr/lib/libiconv.dylib, which do not contains _libiconv  _libiconv_close . founctions. Update to a new libiconv version and reference to it will solve the case
```

> 参考链接：https://stackoverflow.com/questions/40167324/php-compile-fails-with-undefined-symbols-for-architecture-x86-64-libiconv-on-ma

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
