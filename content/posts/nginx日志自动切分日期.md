---
title: Nginx日志自动切分日期
date: 2018-07-14T17:44:16+08:00
lastmod: 2021-09-28T17:44:16+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 运维必备
tags:
  - nginx
  - 日志切分
# nolastmod: true
draft: false
---

今天在网上查询nginx的其他问题的时候，无意间看到原来nginx其实是可以自动按天切分日志的，记得之前在公司看到公司的运维都是写脚本切分日志的，这里配置并记录一下nginx如何按天自动切分日志。

<!--more-->

其实还挺简单的，直接上配置文件内容了。配置完记得：`nginx -s reload`。如果自己之前有nginx日志，且有用的话，那就需要先mv走之前的日志，然后`nginx -s reload`。

    server {
             ...
            # 不重要的直接去掉了，重要的就是下面这点了
            if ($time_iso8601 ~ '(\d{4}-\d{2}-\d{2})') {
                set $tttt $1;
            }
            access_log /var/log/nginx/search.boboidea.com-access-$tttt.log main;
            ...
    }

我今天设置了，是可以正确切分的，再观察几天再看看。

参考文章：https://blog.csdn.net/muyan9/article/details/54616585

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
