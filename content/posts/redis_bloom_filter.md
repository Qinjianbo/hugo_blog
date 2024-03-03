---
title: Redis布隆过滤器|Redis Bloom Filter
date: 2021-10-15T15:59:39+08:00
lastmod: 2021-10-15T15:59:39+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/Redis布隆过滤器Redis Bloom Filter.jpg
# images:
#   - /img/cover.jpg
categories:
  - redis
tags:
  - redis
  - bloomfilter
# nolastmod: true
draft: false
---

为了在线上使用Redis Bloom Filter，在本地测试一下存储不同量级的数据后，Redis Bloom Filter 占用内存大小以及查询速度。

<!--more-->

> 为了方便，我直接使用的docker来进行的测试

```
docker pull redislabs/rebloom
```

> 安装好之后，启动一个container，然后在本地使用`redis-cli`进行连接

```
redis-cli -p 16379
```

> 然后看下安装后的redis内存信息，可以看到没放数据前，大概有857K

```
127.0.0.1:16379> info memory
# Memory
used_memory:875280
used_memory_human:854.77K
used_memory_rss:7503872
used_memory_rss_human:7.16M
used_memory_peak:919640
used_memory_peak_human:898.09K
used_memory_peak_perc:95.18%
...
```

> 接着我执行如下lua脚本，向bloom中加入10W条数据

```
127.0.0.1:16379> EVAL "for i=1,100000 do redis.call('BF.ADD', 'bloomfilter', i) end" 0
```

> 查看内存占用情况，可以看到10W数据的布隆过滤器大概用了1M不到内存

```
127.0.0.1:16379> info memory
# Memory
used_memory:1242368
used_memory_human:1.18M
used_memory_rss:8425472
used_memory_rss_human:8.04M
used_memory_peak:1242432
used_memory_peak_human:1.18M
used_memory_peak_perc:99.99%
...
```

> 然后我在执行如下lua脚本，向bloom中加入1000W条数据

```
127.0.0.1:16379> EVAL "for i=1,10000000 do redis.call('BF.ADD', 'bloomfilter', i) end" 0
```

> 查看内存占用情况，可以看到1000W数据的布隆过滤器大概用了55M内存

```
127.0.0.1:16379> info memory
# Memory
used_memory:58456216
used_memory_human:55.75M
used_memory_rss:61702144
used_memory_rss_human:58.84M
used_memory_peak:58497088
used_memory_peak_human:55.79M
used_memory_peak_perc:99.93%
...
```

> 最后我插入了1亿条数据

```
EVAL "for i=1,100000000 do redis.call('BF.ADD', 'bloomfilter', i) end" 0
```

> 查看内存使用情况，1亿条数据大概占用内存470M内存

```
127.0.0.1:16379> info memory
# Memory
used_memory:519829824
used_memory_human:495.75M
used_memory_rss:493154304
used_memory_rss_human:470.31M
used_memory_peak:519870696
used_memory_peak_human:495.79M
used_memory_peak_perc:99.99%
...
```

> 关于BF.EXISTS的执行时长，那是相当的快了，这个无需担心
> 而且1亿条数据的占用内存在470M左右，可以说也是没啥问题的

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2024 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
