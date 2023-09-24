---
title: ACCESS_REFUSED - Login was refused using authentication mechanism AMQPLAIN
date: 2019-08-25T16:26:25+08:00
lastmod: 2021-09-28T16:26:25+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - rabbitmq
  - access
# nolastmod: true
draft: false
---

ACCESS_REFUSED - Login was refused using authentication mechanism AMQPLAIN

<!--more-->

> 今天在做公司项目的时候，发现自己本地怎么也连不上rabbitmq,总是报下面这个错误：

    Fatal error: Uncaught PhpAmqpLib\Exception\AMQPProtocolConnectionException: ACCESS_REFUSED - Login was refused using authentication mechanism AMQPLAIN. For details see the broker logfile. in /opt/pt-php-push/vendor/php-amqplib/php-amqplib/PhpAmqpLib/Connection/AbstractConnection.php:726

> 主要信息其实是：

    Login was refused using authentication mechanism AMQPLAIN. For details see the broker logfile.

> 然后我打开mq的log看了下，里面有这样的信息：

    2019-08-25 22:49:38.916 [error] <0.2761.0> Error on AMQP connection <0.2761.0> (192.168.1.105:57246 -> 192.168.1.105:5672, state: starting):
    AMQPLAIN login refused: user 'guest' can only connect via localhost

> 意思是说guest这个用户只能通过localhost连接。

> 然后解决办法参考的是这篇文章：

    https://ask.openstack.org/en/question/90260/amqplain-login-refused-user-guest-can-only-connect-via-localhost/?sort=latest

> 通过重新创建一个新用户，并进行授权，然后使用新用户连接，就成功了。

    ➜  ~ /usr/local/Cellar/rabbitmq/3.7.15/sbin/rabbitmqctl add_user qinjianbo qinjianbo

    Adding user "qinjianbo" ...

    ➜  ~ /usr/local/Cellar/rabbitmq/3.7.15/sbin/rabbitmqctl set_permissions -p / qinjianbo '.*' '.*' '.*'

    Setting permissions for user "qinjianbo" in vhost "/" ...

    ➜  ~ brew services restart rabbitmq

    Stopping `rabbitmq`... (might take a while)

    ==> Successfully stopped `rabbitmq` (label: homebrew.mxcl.rabbitmq)

    ==> Successfully started `rabbitmq` (label: homebrew.mxcl.rabbitmq)

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
