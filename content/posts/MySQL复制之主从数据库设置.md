---
title: MySQL复制之主从数据库设置
date: 2018-07-14T17:48:04+08:00
lastmod: 2021-09-28T17:48:04+08:00
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
  - 主从复制
# nolastmod: true
draft: false
---

最近又自己弄了台小服务器，学习了下mysql的主从数据库配置，记录一下配置过程，其实是mariadb的，但是应该都差不多。整个过程配置起来还是比较简单的，没有遇到什么坑，嘿嘿！

<!--more-->

1.开启主库的bin_log

编辑my.cnf文件，在里面添加如下信息：

    # 这里的mysql-bin可以自己定义，是bin_log的文件名字的一部分
    log_bin = mysql-bin
    # 必须指定的唯一服务器ID
    server_id = 100

添加完成后保存并退出，重新启动MySQL服务器

启动后可以登录mysql，使用下面命令看看是否已经成功开启了bin_log

    show master status;

命令执行完成后，如果看到如下信息，则表示已经开启了bin_log日志啦

    +------------------+----------+--------------+------------------+
    | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
    +------------------+----------+--------------+------------------+
    | mysql-bin.000001 |      245 |              |                  |
    +------------------+----------+--------------+------------------+

还可以执行下面的命令来看一下：

    show variables like '%log_bin%';

显示内容如下：

    +---------------------------------+-------+
    | Variable_name                   | Value |
    +---------------------------------+-------+
    | log_bin                         | ON    |
    | log_bin_trust_function_creators | OFF   |
    | sql_log_bin                     | ON    |
    +---------------------------------+-------+

2.OK,主库的bin_log已经开启啦。接着我们来创建一个账号并赋予一些权限。

        grant replication slave,replication client on *.* to slave@'126.24.6.*' identified by 'yourpass'

3.账号创建好了，因为我这个主库是有一定数据的，所以现在需要将主库的已有数据先备份到从库一份。这里备份的方式有很多中，可以根据自己需要进行选择。我这里选择使用mysqldump的方式。【这里注意要给相应的用户设置一下登录的IP哦，否则可能执行不成功呢！】】还有一点需要自己注意一下，我这里复备份了所有库，你备份时可以根据实际需要进行备份就行。】【在这里执行之前，记得show master status看下position，后面从库启动复制时会用到。】

        mysqldump --single-transaction --all-databases --master-data=1  -uroot -pyourpass |mysql --host=47.94.5.239 -uroot -pyourpass

上面的命令执行视数据量大小执行时间应该会不同，我的数据量不大，所以几秒中就执行好了。如果数据量大的话，又不想影响应用的使用，建议采用其他的备份方式。例如：Percona Xtrabackup

4.好了，可以设置一下从库的my.cnf配置文件了，这里我把从库的bin_log也开起来，虽然开启bin_log可能会增加一些开销，但是还是有必要的，因为在进行主从互换，或者数据恢复时，bin_log应该还是很有用的。

编辑从库my.cnf文件，在里面添加如下信息：

    # 这里的mysql-bin可以自己定义，是bin_log的文件名字的一部分
    log_bin = mysql-bin
    # 必须指定的唯一服务器ID
    server_id = 101
    # 指定中继日志的位置
    relay_log=/var/log/mariadb/mysql-relay-bin
    # 允许从库将其重放的事件也记录到自身的二进制日志中
    log_slave_updates=1
    # 阻止任何没有特权权限的线程修改数据
    read_only=1

保存并退出，然后重启数据库，执行一下show master status,看到的结果应该和之前配置主库时差不多。

5.接下来，我们启动复制。

使用mysql 链接从库mysql。连接上之后执行如下SQL命令。

    CHANGE MASTER TO MASTER_HOST='主库host地址',MASTER_USER='当时在主库建立的slave',MASTER_PASSWORD='建立slave账号时设置的pass',MASTER_LOG_FILE='在主库show master status 看到的mysql-bin.000001',MASTER_LOG_POS=在你备份数据时主库show master status看到的Position;

这里我执行上面的SQL命令后，报错：

    ERROR 1201 (HY000): Could not initialize master info structure; more error messages can be found in the MariaDB error log

然后我执行了一下：

    reset slave;

在执行上面的CHANGE命令，就可以了。

接着，我们执行一下下面的命令：

    show slave status;

看到如下(这里省略了一些信息)：可以看到其实还没有启动复制，因为从库的线程都还没有启动。

    *************************** 1. row ***************************
               Slave_IO_State:
                  ...
             Slave_IO_Running: No
            Slave_SQL_Running: No
              ...

然后我们执行一下：

    start slave;
    show slave status;

这回我们再看（省略了一些信息）：相关线程已经启动起来啦。

        Slave_IO_State: Waiting for master to send event
                  ...
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
            ....

我们还可以在主库和从库上分别执行show processlist\G;来看下一,可以看到主库已经有线程在往slave发送binlog,从库上面也有线程在等待master发送binlog过来了。

主库：

    *************************** 1. row ***************************
      Id: 234
    User: root
    Host: localhost
      db: NULL
     Command: Query
        Time: 0
       State: NULL
        Info: show processlist
    Progress: 0.000
    *************************** 2. row ***************************
          Id: 236
        User: slave
        Host: 47.94.5.239:54126
          db: NULL
     Command: Binlog Dump
        Time: 812
       State: Master has sent all binlog to slave; waiting for binlog to be updated
        Info: NULL
    Progress: 0.000

从库：

    *************************** 1. row ***************************
      Id: 6
    User: root
    Host: localhost
      db: NULL
     Command: Query
        Time: 0
       State: NULL
        Info: show processlist
    Progress: 0.000
    *************************** 2. row ***************************
          Id: 7
        User: system user
        Host:
          db: NULL
     Command: Connect
        Time: 768
       State: Waiting for master to send event
        Info: NULL
    Progress: 0.000
    *************************** 3. row ***************************
          Id: 8
        User: system user
        Host:
          db: NULL
     Command: Connect
        Time: 767
       State: Slave has read all relay log; waiting for the slave I/O thread to update it
        Info: NULL
    Progress: 0.000


到这里，主从库就算配好了，接着我们来更新一条主库数据，看看从库会不会跟着更新。

在主库查看一条信息如下：

    select * from myblog.users where id = 2;
    +----+----------+----------------------------------+-------+-------+-------+------------+--------+----------+---------------------+---------------------+
    | id | username | password                         | email | phone | intro | avatar_url | device | nickname | created_at          | updated_at          |
    +----+----------+----------------------------------+-------+-------+-------+------------+--------+----------+---------------------+---------------------+
    |  2 | wanghui  | 585b66ed3c06f4cadcb3084c0a621437 |       | 0     |       |            | pc     | 王慧     | 2018-05-17 15:04:22 | 2018-05-17 15:04:22 |
    +----+----------+----------------------------------+-------+-------+-------+------------+--------+----------+---------------------+---------------------+
    1 row in set (0.00 sec)

从库同样查看这条信息：

    select * from myblog.users where id = 2;
    +----+----------+----------------------------------+-------+-------+-------+------------+--------+----------+---------------------+---------------------+
    | id | username | password                         | email | phone | intro | avatar_url | device | nickname | created_at          | updated_at          |
    +----+----------+----------------------------------+-------+-------+-------+------------+--------+----------+---------------------+---------------------+
    |  2 | wanghui  | 585b66ed3c06f4cadcb3084c0a621437 |       | 0     |       |            | pc     | 王慧     | 2018-05-17 15:04:22 | 2018-05-17 15:04:22 |
    +----+----------+----------------------------------+-------+-------+-------+------------+--------+----------+---------------------+---------------------+
    1 row in set (0.00 sec)

然后我们在主库进行更新：

    MariaDB [(none)]> update myblog.users set nickname='测试更新' where id = 2;
    Query OK, 1 row affected (0.00 sec)
    Rows matched: 1  Changed: 1  Warnings: 0

然后我们来看一下从库是否有更新：

    select * from myblog.users where id = 2;
    +----+----------+----------------------------------+-------+-------+-------+------------+--------+--------------+---------------------+---------------------+
    | id | username | password                         | email | phone | intro | avatar_url | device | nickname     | created_at          | updated_at          |
    +----+----------+----------------------------------+-------+-------+-------+------------+--------+--------------+---------------------+---------------------+
    |  2 | wanghui  | 585b66ed3c06f4cadcb3084c0a621437 |       | 0     |       |            | pc     | 测试更新     | 2018-05-17 15:04:22 | 2018-05-17 15:04:22 |
    +----+----------+----------------------------------+-------+-------+-------+------------+--------+--------------+---------------------+---------------------+
    1 row in set (0.01 sec)

到这里，看来主从配置已经大功告成啦！～

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
