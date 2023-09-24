---
title: Ubuntu下如何连接GlobalProtect的vpn
date: 2021-11-07T21:51:25+08:00
lastmod: 2021-09-28T21:51:25+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 技术文章
tags:
  - globalproject
  - vpn
  - openconnect
# nolastmod: true
draft: false
---

公司的vpn是使用globalprotect来进行连接的，但是在ubuntu下没有globalprotect的客户端可以使用

<!--more-->

公司的vpn是使用globalprotect来进行连接的，但是在ubuntu下没有globalprotect的客户端可以使用，所以必须使用别方式来进行globalconnect的vpn连接。那我们如何在ubuntu下进行globalprotect的vpn连接呢？

首先，我们需要安装openconnect

打开终端，然后执行下面的命令，来进行安装：

```
sudo apt-get install openconnect
```

openconnect 是linux下用来进行vpn连接的一个比较好用的工具，具体使用方式可以到[此处](http://www.infradead.org/openconnect/mail.html)进行查看，我这里就只介绍如何连接globalconnect了

执行完上面的命令后，等待安装openconnect 及其依赖，安装完成后，可以执行：

```
sudo openconnect --protocol=gp vpn.baidu.com // vpn.baidu.com 替换成你要连接的globalconnect的地址
```

接着输入你自己的用户名，密码后就可以正常连接了。

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
