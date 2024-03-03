---
title: TypeError Expected binary or unicode string
date: 2018-10-24T18:16:00+08:00
lastmod: 2021-09-28T18:16:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/TypeError Expected binary or unicode string.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - tensorflow
# nolastmod: true
draft: false
---

TypeError: Expected binary or unicode string, got <tf.Tensor 'EncodeJpeg:0' shape=() dtype=string>

<!--more-->

今天在编写python的tensorflow 的图像处理脚本时，报错如下：

    TypeError: Expected binary or unicode string, got <tf.Tensor 'EncodeJpeg:0' shape=() dtype=string>

我的原始脚本信息如下：

    # -*- coding:utf-8 -*-

    import tensorflow as tf

    # 读取图片原始数据
    image_raw_data = tf.gfile.FastGFile('./rose.jpg').read()

    with tf.Session() as sess:
        # 解码
        image_data = tf.image.decode_jpeg(image_raw_data)
        # 转换数据类型为实数类型
        image_data = tf.image.convert_image_dtype(image_data, dtype=tf.float32)

        # 对图片进行按比例缩放,tf.image.central_crop函数可以对图片进行按比例缩放
        # 第一个参数是原始图像，第二个参数为缩放比例，比例范围(0, 1]
        central_cropped = tf.image.central_crop(image_data, 0.3)

        # 将数据类型转化回整数型
        central_cropped = tf.image.convert_image_dtype(central_cropped, dtype=tf.uint8)

        # 对转化后的图像进行编码
        encoded_central_cropped = tf.image.encode_jpeg(central_cropped.eval())

        # 将图像输出成.jpg文件
        with tf.gfile.GFile("./central_cropped_rose.jpg", "wb") as f:
            f.write(encoded_central_cropped)

问题就出在最后一行：

     f.write(encoded_central_cropped)

这里需要改成：

     f.write(encoded_central_cropped.eval())

这个问题导致就是因为f.write方法接收的是二进制数据或者是unicode字符串，而我刚开始没有调用eval()方法，所以传入的是一个tensorflow张量类型。

<!--declare-declare-->

Copyright &copy; 2017 - 2024 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
