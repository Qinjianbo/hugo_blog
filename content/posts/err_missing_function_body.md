---
title: missing function body;syntax error unexpected semicolon or newline before
date: 2019-09-22T22:30:36+08:00
lastmod: 2021-09-28T22:30:36+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - golang
  - syntax_err
# nolastmod: true
draft: false
---

missing function body;syntax error: unexpected semicolon or newline before {,今天在学习golang时报了这个错误

<!--more-->

今天在学习golang的时候写了这样一段代码：

     func main()
     {
        fmt.Println("go test")
	 }

然后使用go run go_test.go后报错：syntax error: unexpected semicolon or newline before {，可能是我写其它语言写习惯了的原因，顺手把main后面的 { 给换行了，所以导致报这个错误了。
golang 中，函数体的开始大括号需要放在函数同行才行，正确写法，应该是下面这样：

    function main {
		    fmt.Println("go test")
		}

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
