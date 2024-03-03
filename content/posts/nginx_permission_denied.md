---
title: 26054 open /var/lib/nginx/tmp/client_body/0000000005  failed (13 Permission denied)
date: 2017-11-07T18:12:22+08:00
lastmod: 2021-09-28T18:12:22+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - nginx
  - permission
# nolastmod: true
draft: false
---

ajax 异步提交数据服务器返回500，但程序日志中未发现错误，后来在Nginx错误日志中发现了错误信息：*26054 open() "/var/lib/nginx/tmp/client_body/0000000005" failed (13: Permission denied)

<!--more-->

### 问题出现场景

> 前几天做自己的博客的时候，我在管理后台写好文章，使用ajax post 异步提交文章内容到后台，但是服务器返回总是500。

### 问题排查

> 首先我想到的是看自己的程序错误日志，但是发现程序错误日志中没有任何输出。

> 然后我就查看Nginx的错误日志，果然在错误日志中发现，近几次的反复提交都会出现错误
```
*26054 open() "/var/lib/nginx/tmp/client_body/0000000005" failed (13: Permission denied)
```

### 错误分析

> 错误内容如下
```
open() "/var/lib/nginx/tmp/client_body/0000000005" failed
```
> open文件失败原因：
```
 (13: Permission denied)
```
> 可以看到，提示没有权限，那为什么没权限呢？

> 这里可以确定的是执行Nginx 的这个用户没有权限写 `/var/lib/nginx/tmp/client_body/0000000005` 这个文件。那我们先来看下Nginx 所属用户和用户组。

> 执行命令：

```
ps aux | grep "nginx: worker process" | awk '{print $1}'
```
> 执行结果：

```
qinjian+
nobody
nobody
nobody
```

> 然后我们在看一下`/var/lib/nginx/` 这个文件目录所属的用户和用户组

> 执行命令：

```
sudo ls -al /var/lib/nginx/
```

> 执行结果：

```
total 12
drwx------   3 nginx nginx 4096 Jun 13 12:54 .
drwxr-xr-x. 41 root  root  4096 Sep 15 09:59 ..
drwx------   7 nginx nginx 4096 Jun 13 12:55 tmp
```

> 这里我们就可以看到Nginx 进程和`/var/lib/nginx/tmp` 这个文件夹所属用户和用户组都不同，且tmp文件夹的权限标识为`drwx------`，以至于Nginx 无法对这个文件夹进行写操作。

### 问题解决

> 问题解决起来就相对简单了，我们只需要让两者的所属用户和用户组相同就可以了！ 这里我让 `/var/lib/nginx/` 这个目录的所属用户和用户组变成和Nginx 子进程一样。

> 执行命令：

```
sudo chown -R nobody:nobody /var/lib/nginx/
```

> 再执行命令（进行校验）：

```
sudo ls -al /var/lib/nginx/
```

> 执行结果：

```
total 12
drwx------   3 nobody nobody 4096 Jun 13 12:54 .
drwxr-xr-x. 41 root  root  4096 Sep 15 09:59 ..
drwx------   7 nobody nobody 4096 Jun 13 12:55 tmp
```

> 这回所属用户和用户组都一样了，我再提交一次试试吧！~~
> O(∩_∩)O，问题解决了！

### 疑惑点

> Nginx 为什么要往文件中写数据呢？

> 这个问在网上找了很久，也还是不太明白，我本人的Nginx 中配置的`client_max_body_size 100m;` ,按理说一篇文章内容应该不会超过100m，还有可能就是我本身服务器的内存太小了，可能那时被占用的过多不够用了。具体原因还是不明白，如果有知道原因的小伙伴，希望可以联系我告知我一下，我本人也会再进行网络搜寻，如果找到答案，会再这里说明~

<!--declare-declare-->

Copyright &copy; 2017 - 2024 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
