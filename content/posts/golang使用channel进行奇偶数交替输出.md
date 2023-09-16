---
title: Golang使用channel进行奇偶数交替输出
date: 2022-02-17T16:14:39+08:00
lastmod: 2022-02-17T16:14:39+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/hzw83.jpeg
# images:
#   - /img/cover.jpg
categories:
  - golang
tags:
  - channel
# nolastmod: true
draft: false
---

golang中使用channel相关知识控制协程交替输出奇偶数。

<!--more-->

### 使用两个channel实现
```go
package main

import (
	"fmt"
)

func main() {
	ch1 := make(chan int)
	ch2 := make(chan int)
	ch3 := make(chan struct{}) // 用于主协程阻塞，等待子协程执行完毕

	go func() {
		for i := 0; i < 10; i++ {
			<-ch1 // 阻塞，等待告知执行
			if i % 2 == 0 {
				fmt.Println("goroutine1:", i)
			}
			ch2<-i // 通知goroutine2执行
		}
		fmt.Println("goroutine1 done")
	}()

	go func() {
		for i := 0; i < 10; i++ {
			final := <-ch2 // 阻塞等待通知执行
			if i % 2 != 0 {
				fmt.Println("goroutine2:", i)
			}
			if final == 9 { // 如果final == 9 了，说明已经改结束了
				close(ch1)
				close(ch2)
				break
			}
			ch1<-i // 通知goroutine1执行
		}
		fmt.Println("goroutine2 done")
		ch3<-struct{}{} // 结束后通知主协程结束
	}()

	ch1<-0

	<-ch3
	fmt.Println("main done")
}
```
### 使用一个channel实现
```go
package main

import "fmt"

func main() {
	c := make(chan int)
	completeCh := make(chan int) // 用来阻塞主协程等待子协程执行完毕
	go func() {
		for i := 0; i < 10; i++ {
			if i % 2 == 0 {
				fmt.Println("goroutine1:", i)
			}
			c<-i // 通知goroutine2
			<-c // 等待通知
		}
		close(c) // 关闭通道
		fmt.Println("goroutine1: done")
	}()

	go func() {
		defer func() {
			fmt.Println("goroutine2: done")
			completeCh<-10 // 通知主协程结束
		}()
		for {
			select { // 使用for-select来监听channel_c
			case i, ok := <-c: // 如果c被关闭，ok为false，标识结束
				if !ok {
					return
				}
				if i % 2 != 0 {
					fmt.Println("goroutine2:", i)
				}
				c<-i // 通知goroutine1继续执行
			}
		}
	}()

	<-completeCh
	fmt.Println("main:done")
}
```

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
