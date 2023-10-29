---
title: No space left on device
date: 2018-04-03T18:45:13+08:00
lastmod: 2021-09-28T18:45:13+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/No space left on device.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - space
  - df
# nolastmod: true
draft: false
---

今天访问自己的博客，发现文章排序不正确了，知道是读数据库了，没有走ES！~然后就以为是ES出错了，后来登陆到服务器上面，想看看是怎么了，结果发现在按tab 进行命令提示时，总是报错 cannot create temp file for here-document: No space left on device。

<!--more-->

经过在网上查询这个错误，发现这个错误是磁盘满了造成的。

可以通过命令:

    df -h

来查看一下当前磁盘的空间，果然满了。我这时的磁盘空间状态：

    [hhh@iZ2 var]$ df -h
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/vda1        40G   38G     0 100% /
    devtmpfs        486M     0  486M   0% /dev
    tmpfs           497M     0  497M   0% /dev/shm
    tmpfs           497M   50M  447M  11% /run
    tmpfs           497M     0  497M   0% /sys/fs/cgroup
    tmpfs           100M     0  100M   0% /run/user/1001

我去，咋回事呢？一时想不到原因了。

这里看到有人说先用top 追踪一下，看看系统资源情况（但是我并未发现什么异常）：

    Tasks: 106 total,   2 running, 104 sleeping,   0 stopped,   0 zombie
    %Cpu0  :  2.3 us,  2.0 sy,  0.0 ni,  0.0 id, 95.8 wa,  0.0 hi,  0.0 si,  0.0 st
    KiB Mem :  1016124 total,    63328 free,   636148 used,   316648 buff/cache
    KiB Swap:  2097148 total,  1965792 free,   131356 used.   158876 avail Mem

      PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
     3772 elastic+  20   0 2289488 322540     24 S  2.0 31.7  69:48.12 java
     5384 root      20   0  116332   8092    240 R  2.0  0.8   0:03.71 du
     5486 qinjian+  20   0  157708   1116    456 R  0.7  0.1   0:00.05 top
       25 root      20   0       0      0      0 S  0.3  0.0   9:49.33 kswapd0
     1044 root      20   0  125932   3432    512 S  0.3  0.3  16:17.83 AliYunDun
     1086 mysql     20   0 1173620  33308      0 S  0.3  3.3   2:25.63 mysqld
        1 root      20   0  190748   1396    392 S  0.0  0.1   0:54.06 systemd
        2 root      20   0       0      0      0 S  0.0  0.0   0:00.01 kthreadd
        3 root      20   0       0      0      0 S  0.0  0.0   0:01.50 ksoftirqd/0
        5 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 kworker/0:0H
        7 root      rt   0       0      0      0 S  0.0  0.0   0:00.00 migration/0
        8 root      20   0       0      0      0 S  0.0  0.0   0:00.00 rcu_bh
        9 root      20   0       0      0      0 S  0.0  0.0   0:50.30 rcu_sched
       10 root      rt   0       0      0      0 S  0.0  0.0   0:01.15 watchdog/0
       12 root      20   0       0      0      0 S  0.0  0.0   0:00.00 kdevtmpfs
       13 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 netns
       14 root      20   0       0      0      0 S  0.0  0.0   0:00.08 khungtaskd
       15 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 writeback
       16 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 kintegrityd
       17 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 bioset
       18 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 kblockd
       19 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 md
       26 root      25   5       0      0      0 S  0.0  0.0   0:00.00 ksmd
       27 root      39  19       0      0      0 S  0.0  0.0   0:00.56 khugepaged
       28 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 crypto
       36 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 kthrotld
       38 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 kmpath_rdacd
       39 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 kpsmoused
       40 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 ipv6_addrconf
       59 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 deferwq
       91 root      20   0       0      0      0 S  0.0  0.0   0:00.00 kauditd
      222 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 ata_sff
      232 root      20   0       0      0      0 S  0.0  0.0   0:00.00 scsi_eh_0

看网上说可以使用这个命令：

    du -sh /*

看一下每个文件占用的空间，我的文件占用结果如下：

    0	/bin
    175M	/boot
    0	/dev
    39M	/etc
    3.2G	/home
    0	/lib
    0	/lib64
    16K	/lost+found
    4.0K	/media
    4.0K	/mnt
    8.0K	/opt
    du: cannot access ‘/proc/5384/task/5384/fd/4’: No such file or directory
    du: cannot access ‘/proc/5384/task/5384/fdinfo/4’: No such file or directory
    du: cannot access ‘/proc/5384/fd/4’: No such file or directory
    du: cannot access ‘/proc/5384/fdinfo/4’: No such file or directory
    0	/proc
    327M	/root
    50M	/run
    0	/sbin
    4.0K	/srv
    0	/sys
    21G	/tmp
    2.9G	/usr
    10G	/var

令我吃惊啊，为啥/tmp 会这么大呢？21G！赶紧瞧瞧：

    du -h --max-depth=1 /tmp

运行结果：

    4.0K	/tmp/systemd-private-59d9b85992c748279db6d9a3a279b764-mariadb.service-Osoiqe/tmp
    8.0K	/tmp/systemd-private-59d9b85992c748279db6d9a3a279b764-mariadb.service-Osoiqe
    36K	/tmp/hsperfdata_elasticsearch
    4.0K	/tmp/elasticsearch.Dg3tbcp7
    4.0K	/tmp/.Test-unix
    21G	/tmp/systemd-private-59d9b85992c748279db6d9a3a279b764-php-fpm.service-T8lL7D/tmp
    21G	/tmp/systemd-private-59d9b85992c748279db6d9a3a279b764-php-fpm.service-T8lL7D
    4.0K	/tmp/elasticsearch.uw4Wy84I
    4.0K	/tmp/systemd-private-59d9b85992c748279db6d9a3a279b764-ntpd.service-3C4j3z/tmp
    8.0K	/tmp/systemd-private-59d9b85992c748279db6d9a3a279b764-ntpd.service-3C4j3z
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/laravel-mix/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/laravel-mix
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/source-map/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/source-map
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/webpack-merge/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/webpack-merge
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/sass-loader/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/sass-loader
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/babel-plugin-transform-runtime/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/babel-plugin-transform-runtime
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/resolve-url-loader/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/resolve-url-loader
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/readable-stream/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/readable-stream
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/babel-plugin-syntax-object-rest-spread/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/babel-plugin-syntax-object-rest-spread
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/babel-loader/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/babel-loader
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/vue-template-compiler/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/vue-template-compiler
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/autoprefixer/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/autoprefixer
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/webpack-dev-server/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/webpack-dev-server
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/postcss-loader/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/postcss-loader
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/electron-to-chromium/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/electron-to-chromium
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/vue-loader/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/vue-loader
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/extract-text-webpack-plugin/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/extract-text-webpack-plugin
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/uglifyjs-webpack-plugin/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/uglifyjs-webpack-plugin
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/img-loader/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/img-loader
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/color-convert/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/color-convert
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/ansi-styles/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/ansi-styles
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/cross-env/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/cross-env
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/postcss/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/postcss
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/process-nextick-args/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/process-nextick-args
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/supports-color/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/supports-color
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/caniuse-lite/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/caniuse-lite
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/babel-plugin-transform-object-rest-spread/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/babel-plugin-transform-object-rest-spread
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/node-sass/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/node-sass
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/css-loader/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/css-loader
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/chalk/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/chalk
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/vue/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/vue
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/binary-extensions/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/binary-extensions
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/dotenv-expand/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/dotenv-expand
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/clean-css/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/clean-css
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/webpack-notifier/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/webpack-notifier
    4.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/lru-cache/-
    8.0K	/tmp/npm-4317-7766571c/registry.npmjs.org/lru-cache
    284K	/tmp/npm-4317-7766571c/registry.npmjs.org
    288K	/tmp/npm-4317-7766571c
    4.0K	/tmp/jna--1985354563
    4.0K	/tmp/.X11-unix
    4.0K	/tmp/.font-unix
    4.0K	/tmp/.XIM-unix
    4.0K	/tmp/.ICE-unix
    4.0K	/tmp/systemd-private-59d9b85992c748279db6d9a3a279b764-nginx.service-sYNtzD/tmp
    8.0K	/tmp/systemd-private-59d9b85992c748279db6d9a3a279b764-nginx.service-sYNtzD
    21G	/tmp

可以看到有两个东西：

    21G	/tmp/systemd-private-59d9b85992c748279db6d9a3a279b764-php-fpm.service-T8lL7D/tmp
    21G	/tmp/systemd-private-59d9b85992c748279db6d9a3a279b764-php-fpm.service-T8lL7D

说实话，这俩东西是啥，我还真不知道啊。参考这个文章（https://www.cnblogs.com/lihuobao/p/5624071.html） ， 我大概看了一下，就是为了安全。但是应该是设置了这个人选项，应该会自动清理这个临时文件，为啥我的没有清理呢！好奇怪啊。。。。

望看到这篇文章并知道为啥的小伙伴能通过邮箱告知我哈！~~多谢。。。
如我日后知道答案了，我再写进来哈。。。

这边我的解决办法是先重启一下php-fpm 试试，看看是不是stop掉这个服务，然后在重启服务，它会自己清理临时文件。

    systemctl stop php-fpm
    systemctl start php-fpm
    df -h

    Filesystem      Size  Used Avail Use% Mounted on
    /dev/vda1        40G   18G   21G  46% /
    devtmpfs        486M     0  486M   0% /dev
    tmpfs           497M     0  497M   0% /dev/shm
    tmpfs           497M   50M  447M  11% /run
    tmpfs           497M     0  497M   0% /sys/fs/cgroup
    tmpfs           100M     0  100M   0% /run/user/1001

果然，还真是自己清理掉了。这样我文章列表排序也正确了，并不是ES的问题。

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
