---
title: 使用css固定背景图片 background-attachment
date: 2018-07-27T18:29:15+08:00
lastmod: 2021-09-28T18:29:15+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/使用css固定背景图片 background-attachment.jpg
# images:
#   - /img/cover.jpg
categories:
  - 技术文章
tags:
  - css
# nolastmod: true
draft: false
---

最近在优化自己的博客样式时，需要做一件事情，就是在博客首页添加一张背景图片，然后让该背景图不进行滚动，固定住，只有上面的文字进行滚动。这里使用到了background-attachment这个css属性。

<!--more-->

> 最近在优化自己的博客样式时，需要做一件事情，就是在博客首页添加一张背景图片，然后让该背景图不进行滚动，固定住，只有上面的文字进行滚动。这里使用到了background-attachment这个css属性。

> 这里直接贴自己的源码了。只要这样使用就可以将背景进行固定了。

```
.blog-body {
	margin-top: 50px;
	background-image: url('/background_img.jpeg');
	background-repeat: no-repeat;
	background-attachment: fixed;  // 这个属性就是让背景图片固定不动的
}
```

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
