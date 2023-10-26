---
title: golang中结构体嵌套时需要注意的点
date: 2022-02-11T11:05:49+08:00
lastmod: 2022-02-11T11:05:49+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/golang中结构体嵌套时需要注意的点.jpg
# images:
#   - /img/cover.jpg
categories:
  - golang
tags:
  - struct
# nolastmod: true
draft: false
---

golang中结构体嵌套时，如果使用了指针类型的嵌套，则需要注意在拿内部结构体属性时，内部结构体一定时要被实例化后的，不能是nil，否则会导致空指针异常。

<!--more-->

```go
package main

import "fmt"

type Swimming struct {
	Name string
}
func (s *Swimming) swim() {
	fmt.Println("swimming is my ability!")
}

type Flying struct {
}
func (f *Flying) fly() {
	fmt.Println("flying is my ability!")
}

type WildDuck struct {
	// 如果这个地方是一个指针
	// 则下面main中的fmt.Println(wild.Name)
	// 会报空指针异常
	*Swimming
	// 如果这个地方是这个Swimming不是指针
	// 则下面main中的fmt.Println(wild.Name)
	// 不会报错
	//Swimming
	Flying
}

type DomesticDuck struct {
	Swimming
}

func main() {
	// (*Swimming).swim(nil)
	wild := new(WildDuck)
	wild.fly()
	// 但无论上面是*Swimming还是Swimming
	// 这里的wild.swim()都不会报错
	wild.swim()
	// 如果上面是*Swimming
	// 则这里会报错
	fmt.Println(wild.Name)

	domestic := DomesticDuck{}
	domestic.swim()
}
```

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
