---
title: unauthorized incorrect username or password  docker
date: 2019-07-26T22:34:00+08:00
lastmod: 2021-09-28T22:34:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/unauthorized incorrect username or password  docker.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - docker
  - unauthorized
# nolastmod: true
draft: false
---

docker pull 报错 error unauthorized: incorrect username or password

<!--more-->

问题：

     ~ docker pull workpress
    Using default tag: latest
    Error response from daemon: Get https://registry- 1.docker.io/v2/library/workpress/manifests/latest: unauthorized: incorrect username or password

解决方案：

    使用docker login 进行登录
    ~ docker login
    Authenticating with existing credentials...
    Stored credentials invalid or expired Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
    Username (279250819@qq.com): 这里需要输入docker hub 上注册时的用户名ID，不是邮箱地址
    Password:这里输入密码

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
