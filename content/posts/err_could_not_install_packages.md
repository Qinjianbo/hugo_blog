---
title: ERROR Could not install packages due to an OSError
date: 2023-10-30T04:20:23+08:00
lastmod: 2023-10-30T04:20:23+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/ERROR%20Could%20not%20install%20packages%20due%20to%20an%20OSError.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - python
  - pip
# nolastmod: true
draft: false
---

ERROR: Could not install packages due to an OSError: [WinError 5] 拒绝访问。: 'E:\\webui\\sd-webui-aki-v4.2\\python\\Lib\\site-packages\\cv2\\cv2.pyd'
Consider using the `--user` option or check the permissions.

<!--more-->

### 问题

安装报错：

```shell
E:\webui\sd-webui-aki-v4.2>pip install insightface-0.7.3-cp310-cp310-win_amd64.whl

Looking in indexes: https://pypi.tuna.tsinghua.edu.cn/simple
... 此处省略一万字 ...
ERROR: Could not install packages due to an OSError: [WinError 5] 拒绝访问。: 'E:\\webui\\sd-webui-aki-v4.2\\python\\Lib\\site-packages\\cv2\\cv2.pyd'
Consider using the `--user` option or check the permissions.
```

### 解决方案

解决方案很简单，就是使用错误后面给出的 `Consider using the `--user` option`，执行命令时加上 --user 就可以了

```shell
E:\webui\sd-webui-aki-v4.2>pip install insightface-0.7.3-cp310-cp310-win_amd64.whl --user

```

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
