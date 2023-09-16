---
title: 如何在mac下制作ubuntu的u盘启动盘
date: 2018-06-12T18:36:03+08:00
lastmod: 2021-09-28T18:36:03+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 技术文章
tags:
  - 启动盘
  - ubuntu
  - mac
# nolastmod: true
draft: false
---

公司给我们配了台式机，要求开发统一安装ubuntu作为开发机系统，借此学习ubuntu的相关知识。目前用的mac，需要制作一个u盘启动盘来安装ubuntu到台式机，但是找不到好的工具，在网上看到一篇文章，在此进行记录。

<!--more-->

> 原文链接：https://blog.csdn.net/jeikerxiao/article/details/71747375

> 第一步：准备一个u盘作为启动盘载体。

> 第二步：将u盘挂载到mac系统上。插入u盘到mac，然后使用命令diskutil list查看挂载结果。

```
diskutil list

/dev/disk0
#:                       TYPE NAME                    SIZE       IDENTIFIER
0:      GUID_partition_scheme                        *160.0 GB   disk0
1:                        EFI                         209.7 MB   disk0s1
2:                  Apple_HFS Macintosh HD            159.2 GB   disk0s2
3:                 Apple_Boot Recovery HD             650.0 MB   disk0s3
/dev/disk1
#:                       TYPE NAME                    SIZE       IDENTIFIER
0:     Apple_partition_scheme                        *17.3 MB    disk1
1:        Apple_partition_map                         32.3 KB    disk1s1
2:                  Apple_HFS Flash Player            17.3 MB    disk1s2
/dev/disk2
#:                       TYPE NAME                    SIZE       IDENTIFIER
0:     FDisk_partition_scheme                        *15.7 GB    disk2
1:             Windows_FAT_32 KINGSTON                15.7 GB    disk2s1
```

> 第三步：使用命令diskutil unmountDisk /dev/disk2 命令解除u盘的挂载。

```
diskutier unmountDisk /dev/disk2
```

> 第四步：使用命令dd将ubuntu的iso文件写入u盘中。

```
dd if=Downloads/ubuntu-18.04-desktop-amd64.iso of=/dev/disk2 bs=1m
```

> 第五步：等待写入完毕，过程持续时间视情况而定。最后会输出如下：

```
1832+1 records in
1832+1 records out
1921843200 bytes transferred in 674.251601 secs (2850335 bytes/sec)
```

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
