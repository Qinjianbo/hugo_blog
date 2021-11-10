---
title: chsh PAM Authentication failure
date: 2020-09-07T22:06:13+08:00
lastmod: 2021-09-28T22:06:13+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: /img/posts/hzw22.jpeg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - chsh
  - PAM
  - oh-my-zsh
# nolastmod: true
draft: false
---

今天在装oh my zsh时遇到错误chsh: PAM: Authentication failure

<!--more-->

> 今天在装oh-my-zsh的时候，使用下面的命令进行root用户的默认shell切换后：

```
sudo chsh -s $(which zsh)
```

> 再执行：

```
sudo su
```

> 发现报错：

```
Cannot execute zsh: No such file or directory
```

> 然后尝试再次执行最上面的命令：

```
sudo chsh -s $(which zsh)
```

> 这时发现报错：

```
chsh: PAM: Authentication failure
```

> 最后解决方法：

```
sudo vim /etc/passwd
将passwd里面的:
root:x:0:0:root:/root:zsh
改成
root:x:0:0:root:/root:/usr/bin/zsh
```

> 然后问题就都解决了

> 参考文章：https://blog.nofile.cc/555.html

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
