---
title: Git命令行如何批量删除本地无用分支
date: 2017-12-07T17:57:32+08:00
lastmod: 2021-09-28T17:57:32+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 工具
tags:
  - git
  - 分支删除
# nolastmod: true
draft: false
---

在使用git管理自己的项目时，不免会遇到想要删除多个本地分支的情况，这时，我们可以采用git brand -D 来进行逐个删除，那有没有更好的办法，让我来一次性删除多个无用分支呢？答案是肯定的，我们可以通过执行命令...
Cut out summary from your post content here.

<!--more-->

# [Git]Git命令行如何批量删除本地无用分支

### 查看本地现有分支

    git branch


### 使用grep 命令过滤掉有用分支

     git branch |grep fea |grep -v fea_3.7


### 进行批量删除

1. 结合[xargs](https://en.wikipedia.org/wiki/Xargs) 和 git branch 命令将无用分支删除

       git branch |grep fea |grep -v fea_3.7 |xargs -I {} git branch -D {}


2. 另一种批量删除

       git branch -D $(git branch |grep fea |grep -v fea_3.7)


<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
