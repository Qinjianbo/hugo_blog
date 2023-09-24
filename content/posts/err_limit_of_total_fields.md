---
title: Limit of total fields [1000] in index [xxx] has been exceeded
date: 2020-05-21T22:09:46+08:00
lastmod: 2021-09-28T22:09:46+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - elasticsearch
# nolastmod: true
draft: false
---

更新ES报错Limit of total fields [1000] in index [xxx] has been exceeded

<!--more-->

今天在往我们测试环境自己自建的ES中更新数据时发现报错：Limit of total fields [1000] in index [goods_profile_v1] has been exceeded

后来查看索引的settings，发现里面有默认配置：
```
"ignore_malformed": "false",
        "total_fields": {
          "limit": "1000"
        }
```

经过从网上查找该错误，知道需要调整索引的设置才行

然后我从kibana中从新修改了设置值：
```
"index.mapping.total_fields.limit": "3000",
```

修改成功后再更新，更新成功了！～～

但是由此可见我这个索引中的fields有点多，可能需要从新设计索引mapping才行

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
