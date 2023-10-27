---
title: golang中的iota
date: 2022-02-11T10:21:55+08:00
lastmod: 2022-02-11T10:21:55+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/golang中的iota.jpg
# images:
#   - /img/cover.jpg
categories:
  - golang
tags:
  - iota
# nolastmod: true
draft: false
---

记录一下golang中的iota

<!--more-->

```go
package main

import "fmt"

type Kind uint

// 这样声明一下可以认为是声明了一个const
// 数组，然后iota就是数组的下标
const (
	// 这里可以指定类型Kind
	// 如果不指定Kind，则默认是int
	Invalid Kind = iota // 0
	Bool // 1
	Int // 2
	Int8 // 3
	// 这里重制了Int16的类型
	// 后面直到下一个iota
	// 都跟随Int16
	Int16 string = "aaa" // aaa iota=4
	Int32 // aaa iota=5
	Int64 // aaa iota=6
	// 下面的Uint开始为int
	// 因为未声明类型
	// 然后由于使用了iota
	// 所以从7开始
	// 可以验证出iota是记录了
	// 常量的个数, 下标从0开始
	// 到这里Uint是第八个常量
	Uint = iota // 7
	Uint8 // 8
	Uint16 // 9
	Uint32 // 10
	Uint64 // 11
	Uintptr // 12
	Float32 // 13
	Float64 // 14
	Complex64 // 15
	Complex128 // 16
	Array // 17
	Chan // 18
	Func // 19
	Interface // 20
	Map // 21
	Pointer // 22
	Slice // 23
	String // 24
	Struct // 25
	UnsafePointer // 26
)

// 从新声明了另一个数组，所以iota从0开始了
const (
	Test = iota // 0
    // 只要中断从新声明了
	// 后面如果没有从新声明=iota
	// 那么就会继承这个
	Test1 = iota + 2 // 3
	_ // iota=2
	Test2 // Test2=iota+2 iota=3
)

func main() {
	fmt.Println(Invalid)
	fmt.Println(Bool)
	fmt.Printf("%T\n", Bool)
	fmt.Println(Int)
	fmt.Println(Int8)
	fmt.Println(Int16)
	fmt.Println(Int32)
	fmt.Println(Int64)
	fmt.Println(Uint)
	fmt.Println(Uint8)
	fmt.Println(Uint16)
	fmt.Println(Uint32)
	fmt.Println(Uint64)

	fmt.Println(Test)
	fmt.Println(Test1)
	fmt.Println(Test2)
}
```

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
