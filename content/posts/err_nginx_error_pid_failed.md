---
title: nginx [error] open() "/usr/local/var/run/nginx.pid" failed
date: 2021-04-25T22:16:44+08:00
lastmod: 2021-09-28T22:16:44+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/nginx [error].jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - nginx
# nolastmod: true
draft: false
---

nginx: [error] open() "/usr/local/var/run/nginx.pid" failed 如何解决

<!--more-->

## 问题

> nginx报错: `[error] open() "/usr/local/var/run/nginx.pid" failed`

## 解决方法

> 执行：

```
sudo nginx -t
```

> 根据执行结果找到 `/usr/local/etc/nginx/nginx.conf`

```
nginx: the configuration file /usr/local/etc/nginx/nginx.conf syntax is ok
nginx: configuration file /usr/local/etc/nginx/nginx.conf test is successful
```

> 然后执行：

```
sudo nginx -c /usr/local/etc/nginx/nginx.c
```

> 最后在执行：

```
sudo nginx -s reopen
```

> 经过上面的步骤后，nginx就能成功启动了

<!--declare-declare-->

Copyright &copy; 2017 - 2024 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
