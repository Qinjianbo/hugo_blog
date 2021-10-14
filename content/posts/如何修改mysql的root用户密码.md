---
title: 如何修改mysql的root用户密码
date: 2018-06-15T17:52:25+08:00
lastmod: 2021-09-28T17:52:25+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: /img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 运维必备
tags:
  - mysql
  - 密码修改
# nolastmod: true
draft: false
---

新装的mysql，用root用户就是登录不了，无奈只能更改mysql的root用户密码了，我使用的是方案B的方式，方案A不知道为什么用不了。

<!--more-->

> 方法A：
```
// 停止mysql服务
sudo service stop mysql
// 启用免密登录
sudo mysqld_safe --skip-grant-tables --skip-networking &
// 然后使用mysql进行无密登录
mysql -uroot

// 登录后使用mysql数据
use mysql
// 更新root用户名密码,这里注意密码字段，5.7及以上版本可能变成了authentication_string了!
// 这里还要注意plugin='mysql_native_password'这个设置，新装的有可能是auth_socket，如果是这个改了密码也登录不了。
update user set password=PASSWORD('yourpass'),plugin='mysql_native_password' where user='root';
// 退出MySQL登录
exit;
// 重新启动mysql服务
sudo service mysql start
// 使用root进行登录
mysql -uroot -p yourpass
```

方法B：

```
// 在ubuntu的Debian系统上mysql会分配给系统一个
// 用户来让系统执行特定任务使用，
// 我们也可以使用这个分配的用户名和密码进行登录，然后修改root密码。可查看/etc/mysql/debian.cnf
# Automatically generated for Debian scripts. DO NOT TOUCH!
[client]
host     = localhost
user     = debian-sys-maint
password = sdjfjsdf
socket   = /var/run/mysqld/mysqld.sock
[mysql_upgrade]
host     = localhost
user     = debian-sys-maint
password = sdfsdf
socket   = /var/run/mysqld/mysqld.sock
```

> 参考文章：http://www.ghostchina.com/how-to-reset-mysqls-root-password/

> 关于auth_socket:这个需要自行查询了，看到的文章中的那个链接已经不存在了

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
