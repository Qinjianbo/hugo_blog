---
title: 匿名函数和闭包的区别及用法
date: 2022-02-10T10:59:02+08:00
lastmod: 2022-02-10T10:59:02+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/hzw100.jpeg
# images:
#   - /img/cover.jpg
categories:
  - golang
tags:
  - 匿名函数
  - 闭包
# nolastmod: true
draft: false
---

golang中的匿名函数和闭包的区别和用法。匿名函数可以作为函数的入参实现“表现延时”，闭包则可以作为函数返回值来作为函数内部与外部沟通的桥梁,使外部访问函数内部的局部变量。

该文章内容仅作为自己学习理解之用，用于自己后续复习可以想到当时的想法，如有不符合广大小友的思维之处，还请谅解。

<!--more-->

```go
package main

import "fmt"

var MyPrintf = func(str string) {
	for i, v := range str {
		fmt.Printf("index: %v value: %v ", i, v)
	}
	fmt.Println()
}

var MyPrintln = func(str string) {
	for _, v := range str {
		fmt.Println(v)
	}
}
// 匿名函数作为函数的回调函数
// 可以使运行时体现不同的表现
// func(params) (returns) {
//     function body
// }
// func name(params) (returns) {
//     function body
//}
func main() {
	//MyPrint("胡巴", func(str string) {
	//	for i, v := range str {
	//		fmt.Printf("index: %v value: %v ", i, v)
	//	}
	//	fmt.Println()
	//})

	//MyPrint("胡巴", func(str string) {
	//	for _, v := range str {
	//		fmt.Println(v)
	//	}
	//})
	// name := "MyPrintln"
	// if name == "MyPrintln" {
	//     MyPrint("胡巴", MyPrintln)
	// }

	c1 := createCounter(1)
	fmt.Println(c1())
	fmt.Println(c1())

	c2 := createCounter(10)
	fmt.Println(c2())
	fmt.Println(c1())
}

func MyPrint(name string, processor func(str string)) {
	processor(name)
}

// 闭包:保存了状态和行为
// 正常情况下 initial 外部使不能访问到的
// 但是通过返回一个函数进行闭包处理
// 外部就可以访问到这个内部的initial了
// 同时会造成内存逃逸
func createCounter(initial int) func() int {
	if initial < 0 {
		initial = 0
	}

	return func() int {
		initial++
		return initial
	}
}
```

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
