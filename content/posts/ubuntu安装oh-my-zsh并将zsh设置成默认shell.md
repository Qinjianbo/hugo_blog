---
title: Ubuntu安装oh My Zsh并将zsh设置成默认shell
date: 2018-06-12T18:33:58+08:00
lastmod: 2021-09-28T18:33:58+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/Ubuntu安装oh My Zsh并将zsh设置成默认shell.jpg
# images:
#   - /img/cover.jpg
categories:
  - 技术文章
tags:
  - shell
  - zsh
# nolastmod: true
draft: false
---

今天从新给电脑装了ubuntu系统，然后从新装一遍oh-my-zsh，在此记录安装过程，以备后续自己再使用！

<!--more-->

今天从新给电脑装了ubuntu系统，然后从新装一遍oh-my-zsh，在此记录安装过程，以备后续自己再使用！

第一步：安装zsh

    sudo apt-get install zsh;

第二步：安装git

    sudo apt-get install git;

第三步：安装oh-my-zsh

    sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

第四步：设置zsh为默认shell，并检查是否成功

    sudo chsh -s $(which zsh)
    sudo echo $SHELL
    /usr/bin/zsh

    // 如果是在windows的cmder + wsl下，则需要修改 ~/.bashrc
    // 在最上面的地方增加下面的代码，然后重启终端，才会自动启动zsh
    if test -t 1; then
		    exec zsh
    fi

第五步：重启机器

经过上面5步，zsh应该就是你当前使用的默认shell啦！～～

参考：https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH

第六步：这里还强烈推荐安装zsh-autosuggestions

    sudo git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


第七步：在.zshrc中添加下面插件声明

    zsh-autosuggestions

第八步：从新打开新的terminal，然后就可以有自动补全功能啦。

参考：https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md

如果是在windows下安装cmder + wsl 来使用 oh-my-zsh ，则可以参考这篇文章：https://www.jianshu.com/p/3b2b3e2a3824

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
