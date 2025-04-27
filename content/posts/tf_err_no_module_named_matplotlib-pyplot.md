---
title: Tf_err_no_module_named_matplotlib Pyplot
date: 2018-10-24T18:25:10+08:00
lastmod: 2021-09-28T18:25:10+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/Tf_err_no_module_named_matplotlib Pyplot.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - tensorflow
# nolastmod: true
draft: false
---

今天在编写tensorflow脚本时，报错No module named matplotlib.pyplot

<!--more-->

今天在编写tensorflow 脚本时，报错No module named matplotlib。matplotlib.pyplot是python的一个画图工具库，这里报这个错误是由于我没有安装这个库到本地。所以可以执行下面的命令进行安装。

    python -m pip install matplotlab

装完之后可能还会报错：No module named _tkinter, please install the python-tk package，然后我们需要安装一下python-tk。

    sudo apt-get install python-tk

然后再运行我们的python脚本就可以了。

我的python 脚本如下：

    # -*- coding:utf-8 -*-

    # matplotlib.pyplot 是一个python 的画图工具。后面将使用该工具来可视化经过
    Tensorflow
    # 处理的图像
    import matplotlib.pyplot as plt
    import tensorflow as tf

    # 读取图像的原始数据
    image_raw_data = tf.gfile.FastGFile("./99383371_37a5ac12a3_n.jpg", 'r').read()

    with tf.Session() as sess:
        # 对图像进行jpeg的格式解码从而得到图像对应的三维矩阵。Tensorflow
        # 还提供了tf.image.decode_png 函数对png 格式的图像进行解码。解码之后
        # 的结果为一个张量，在使用它的取值之前需要明确调用运行的过程。
        image_data = tf.image.decode_jpeg(image_raw_data)

        # 输出解码之后的三维矩阵
        print image_data.eval()

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
