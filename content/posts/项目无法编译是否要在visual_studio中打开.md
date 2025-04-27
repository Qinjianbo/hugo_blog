---
title: 项目无法编译是否要在visual studio中打开
date: 2019-12-24T22:23:00+08:00
lastmod: 2021-09-28T22:23:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/项目无法编译是否要在visual studio中打开.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - unreal4
  - ue4
  - 项目无法编译
# nolastmod: true
draft: false
---

 unreal4新建c++项目会提示项目无法编译是否要在visual studio中打开?这个怎么解决...

<!--more-->

> 最近在学习unreal4时，创建C++项目总是遇见：项目无法编译是否要在visual studio中打开?

> 当遇见这个问题的时候，一定要看清楚里面具体提示的错误内容是什么，我这里遇到过两种：这里错误信息我只记录关键信息了哈

> 第一种：windows sdk v8.1 must be installed ...

```
windows sdk v8.1 must be installed ...
```

> 这种的解决方案就是，打开`visual studio installer`, 然后在修改里面，找到`windows sdk v8.1`然后进行确认修改，安装`sdk v8.1`即可。

![1.PNG](http://ww1.sinaimg.cn/large/c3ee7931gy1ga88jh1plyj20zu0k0wfj.jpg)
![2.PNG](http://ww1.sinaimg.cn/large/c3ee7931ly1ga88khvkrqj20zu0k0768.jpg)

> 第二种：Error: Missing UCLASS name

```
Error: Missing UCLASS name
```

> 这个的解决办法就是看看自己创建项目的时候的的项目名称是不是包含中文了，如果包含了中文，需要将中文换成英文就可以了。

> 希望对有需要的小伙伴有帮助。如有疑问，可以在下方留言，我会第一时间帮助你的，共同学习，共同进步哦！~~

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
