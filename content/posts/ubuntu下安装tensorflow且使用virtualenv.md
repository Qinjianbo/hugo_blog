---
title: Ubuntu下安装tensorflow且使用virtualenv
date: 2018-06-15T18:32:04+08:00
lastmod: 2021-09-28T18:32:04+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/Ubuntu下安装tensorflow且使用virtualenv.jpg
# images:
#   - /img/cover.jpg
categories:
  - 技术文章
tags:
  - tensorflow
# nolastmod: true
draft: false
---

早就知道有tensorflow这么一个东西，一直想玩一下，今天就对其在ubuntu上进行了安装，顺便记录一下安装过程，本来写了个安装脚本，但是忘记保存了。。。安装过程参考官网教程！

<!--more-->

根据自己的python版本选择其中一个命令进行执行：

    sudo apt-get install python-pip python-dev python-virtualenv # for Python 2.7
    sudo apt-get install python3-pip python3-dev python-virtualenv # for Python 3.n
    
还是根据python版本选择一个进行执行，来创建一个virtualenv虚拟环境

    virtualenv --system-site-packages targetDirectory # for Python 2.7
    virtualenv --system-site-packages -p python3 targetDirectory # for Python 3.n

根据自己所使用的shell来进行source

    source ~/tensorflow/bin/activate # bash, sh, ksh, or zsh
    source ~/tensorflow/bin/activate.csh  # csh or tcsh

source后就进入到刚刚创建的virtualenv环境中了，然后在该环境下进行tensorflow的安装

确认一下pip版本在8.1及以上

    easy_install -U pip

根据自己的python版本及本身需要和硬件支持选择其中的一种进行安装

    pip install --upgrade tensorflow      # for Python 2.7
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade tensorflow     # for Python 3.n
    pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade tensorflow-gpu  # for Python 2.7 and GPU
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade tensorflow-gpu # for Python 3.n and GPU

安装完成后，可以在虚拟环境下进行测试，看看是否安装成功

    python

    import tensorflow as tf
    hello = tf.constant('Hello, TensorFlow!')
    sess = tf.Session()
    print(sess.run(hello))

如果以上过程都顺利进行，那么恭喜你，你的tensorflow已经成功安装了。如果不顺利，那么也别灰心，可以再参考一下官网：https://www.tensorflow.org/install/install_linux#top_of_page
看看是否能让你的安装更顺利些，祝好运！～～

<!--declare-declare-->

Copyright &copy; 2017 - 2024 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
