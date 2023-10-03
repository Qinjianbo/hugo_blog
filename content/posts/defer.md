---
title: golang中defer的使用
date: 2022-02-17T14:08:06+08:00
lastmod: 2022-02-17T14:08:06+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/golang%E4%B8%ADdefer%E4%BD%BF%E7%94%A8.jpg
# images:
#   - /img/cover.jpg
categories:
  - golang
tags:
  - defer
# nolastmod: true
draft: false
---

> golang中defer好像一个栈一样，在其后声明的表达式会被先行压入“栈”中，然后按照先进后出的顺序在真正return之前进行执行。

> 什么是真正return？golang中的return不是原子的，它可以分为三个部分执行：1.给返回值进行赋值 2.按照后进先出的顺序执行defer表达式 3.函数返回

<!--more-->

```go
package main

import "fmt"

// defer作用
// 1. 释放资源
// 2. 关闭连接
// 3. 做recover处理
func main() {
	deferStack()
	fmt.Println()
	fmt.Println(returnNotAtomic(1)) // 2
	fmt.Println()
	reference()
	deferFuncReturnWillDrop()
	fmt.Println()
	fmt.Println(Test1())
	fmt.Println()
	fmt.Println(Test2())
	fmt.Println()
	Test3()
	fmt.Println()
	Test4()
}

// 为什么是4 3 2 1 0?
// defer --> 栈 --> 先进后出
func deferStack() {
	for i := 0; i < 5; i++ {
		defer fmt.Println(i)
	}
	// 4
	// 3
	// 2
	// 1
	// 0
}

// golang中return 不是原子的
// return的执行分为三步
// 1. 给返回值赋值
// 2. 执行defer
// 3. return
func returnNotAtomic(a int) (ret int) {
	defer func() {
		ret++
	}()

	return a

//	ret = a
//	func () {
//		ret++
//	}
//	return
}

func reference() {
	for i := 0; i < 5; i++ {
		defer func() {
			// 这里的i是对for中i的一个引用
			// 所以在所有defer执行时，i已经变成了5
			// 最终输出 5 5 5 5 5
			fmt.Println(i)
		}()
	}
}

// defer表达式中若又返回值，将会被丢弃
func deferFuncReturnWillDrop() {
	defer func() (int) {
		return 1
	}()
}

func Test1() (r int) {
	t := 5
	defer func() {
		t = t + 5
	}()

	return t
	// r = t 即 r=5
	// defer t = t + 5 t=10
	// return 此时r=5
}

func Test2() (r int) {
	defer func(r int) {
		r = r + 5
	}(r)

	return 1
	// return_r = 1
	// defer return_r被以值拷贝的方式传入，里面的r和外面的r不是一个r
	// return return_r 的值没有被改变, 所以还是1
}

func deferExec(sli *[]int) {
	fmt.Println(sli)
}

// 最终三个输出结果都是&[5, 6]
func Test3() {
	sli := make([]int, 0)
	defer deferExec(&sli)
	sli = append(sli, 5)
	defer deferExec(&sli)
	sli = append(sli, 6)
	defer deferExec(&sli)

	return
}

type Test struct {
	Max int
}
func (t *Test) Println() {
	fmt.Println(t.Max)
}
func deferExec1(f func()) {
	f()
}
func Test4() (t *Test) {
	// t = nil
	defer deferExec1(t.Println) // 此时传入的t=nil

	//t = new(Test)
	t = &Test{
		Max: 1,
	}
	return
}
```

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
