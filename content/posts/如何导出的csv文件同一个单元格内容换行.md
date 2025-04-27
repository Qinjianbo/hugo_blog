---
title: 如何导出的csv文件同一个单元格内容换行
date: 2019-01-11T17:24:38+08:00
lastmod: 2021-09-28T17:24:38+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/如何导出的csv文件同一个单元格内容换行.jpg
# images:
#   - /img/cover.jpg
categories:
  - 技术文章
tags:
  - csv
# nolastmod: true
draft: false
---

导出csv时，使同一个单元格的内容换行的方法。

<!--more-->

> 要想使导出的csv文件的同一个单元格的内容换行，可以使用下面这正方式：

```
<?php
$array = ['aaa', 'bbb', "\"aaa\nbbb\""]; // 注意这里第三个元素的拼接方式
file_put_contents('test.csv', implode(',', $array));
```

> 导出的csv使用记事本带开内容如下：

```
aaa,bbb,"aaa
bbb"
```

> 这样就可以实现换行功能了。

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
