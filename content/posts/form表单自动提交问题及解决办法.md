---
title: Form表单自动提交问题及解决办法
date: 2018-05-15T10:03:49+08:00
lastmod: 2021-09-29T10:03:49+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - form
  - 自动提交
# nolastmod: true
draft: false
---

今天收到一个任务，任务内容是这样：有一个搜索输入框，在搜索输入框内输入内容后，回车，发现页面自动刷新了，要求回车后进行搜索而不是刷新页面。开始以为是vue的问题，后来查了查原来是form表单的一种提交机制，解决办法有两种！

<!--more-->

今天收到一个任务，任务内容是这样：有一个搜索输入框，在搜索输入框内输入内容后，回车，发现页面自动刷新了，要求回车后进行搜索而不是刷新页面。

开始以为是vue的问题，后来查了查原来是form表单的一种提交机制 : 当form表单中只有一个`<input type="text" name='name' />`时按回车键将会自动将表单提交。

浏览器自处理规则：

1. 如果表单里有一个type=”submit”的按钮，回车键生效。
2. 如果表单里只有一个type=”text”的input，不管按钮是什么type，回车键生效。
3. 如果按钮不是用input，而是用button，并且没有加type，IE下默认为type=button，FX默认为type=submit。
4. 其他表单元素如textarea、select不影响，radio checkbox不影响触发规则，但本身在FX下会响应回车键，在IE下不响应。
5. type=”image”的input，效果等同于type=”submit”，不知道为什么会设计这样一种type，不推荐使用，应该用CSS添加背景图合适些。

防止回车自动提交的办法有三种：

1. 在要提交的form 标签中加入 onsubmit="return false;"

        <form role="form" class="row-bottom" onsubmit="return false;">
        </form>

2. 在表单内部多加一个隐藏的`<input />`的标签。

        <form role="form" class="row-bottom">
            <input type="hidden"/>
            <input name="name" value=""/>
        </form>

3. 给input标签添加事件 onkeydown="if(event.keyCode==13){return false;}

        <form role="form" class="row-bottom">
            <input name="name" value="" onkeydown="if(event.keyCode==13){return false;}" />
        </form>

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
