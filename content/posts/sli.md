---
title: slice使用时需要注意的点
date: 2022-02-09T14:45:56+08:00
lastmod: 2022-02-09T14:45:56+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/slice使用时需要注意的点.jpg
# images:
#   - /img/cover.jpg
categories:
  - golang
tags:
  - slice
# nolastmod: true
draft: false
---

关于golang中slice使用时需要注意的问题，未扩容前底层数组未变，修改任意一个slice都有可能导致另一个指向同一个底层数组的slice的值的修改，所以使用过程中需要特别注意。

<!--more-->

```go
package main

import "fmt"

func main() {
	arr1 := [...]int{1,2,3,4}
	fmt.Printf("arr1自身地址: %p value: %v\n", &arr1, arr1)

	sli1 := arr1[0:2]
	fmt.Printf("sli1自身地址: %p sli1底层数组指针地址: %p value: %v\n", &sli1, sli1, sli1)

	newSli1 := append(sli1, 5)
	fmt.Printf("newSli1自身地址: %p, newSli1底层数组地址: %p value: %v\n", &newSli1, newSli1, newSli1)
	fmt.Printf("当前arr1的value: %v\n", arr1)
	fmt.Printf("当前sli1的value: %v\n", sli1)

	sli1 = append(sli1, 7)
	fmt.Printf("sli1自身地址: %p sli1底层数组指针地址: %p value: %v\n", &sli1, sli1, sli1)
	fmt.Printf("当前arr1的value: %v\n", arr1)
	fmt.Printf("newSli1自身地址: %p, newSli1底层数组地址: %p value: %v\n", &newSli1, newSli1, newSli1)

	// arr1自身地址: 0xc00012e000 value: [1 2 3 4]
	// sli1自身地址: 0xc00011c018 sli1底层数组指针地址: 0xc00012e000 value: [1 2]
	// newSli1自身地址: 0xc00011c060, newSli1底层数组地址: 0xc00012e000 value: [1 2 5]
	// 当前arr1的value: [1 2 5 4]
	// 当前sli1的value: [1 2]
	// sli1自身地址: 0xc00011c018 sli1底层数组指针地址: 0xc00012e000 value: [1 2 7]
	// 当前arr1的value: [1 2 7 4]
	// newSli1自身地址: 0xc00011c060, newSli1底层数组地址: 0xc00012e000 value: [1 2 7]

	// ------------------上面是发生扩容之前--------------------

	// ------------------下面是发生扩容之后------------------------
	sli1 = append(sli1, 8, 9)
	fmt.Printf("sli1自身地址: %p sli1底层数组指针地址: %p value: %v\n", &sli1, sli1, sli1)
	fmt.Printf("当前arr1的value: %v\n", arr1)
	fmt.Printf("newSli1自身地址: %p, newSli1底层数组地址: %p value: %v\n", &newSli1, newSli1, newSli1)

	// 发生扩容后，底层数组从新非配内存，导致数组地址变化
	// sli1自身地址: 0xc00000c030 sli1底层数组指针地址: 0xc0000140c0 value: [1 2 7 8 9]
	// 当前arr1的value: [1 2 7 4]
	// newSli1自身地址: 0xc00000c078, newSli1底层数组地址: 0xc0000180c0 value: [1 2 7]

	temp := changeSli(sli1)
	fmt.Printf("sli1自身地址: %p sli1底层数组指针地址: %p value: %v\n", &sli1, sli1, sli1)
	fmt.Printf("temp自身地址: %p temp底层数组指针地址: %p value: %v\n", &temp, temp, temp)

	sli1[3] = 999
	fmt.Printf("temp自身地址: %p temp底层数组指针地址: %p value: %v\n", &temp, temp, temp)

	// sli2 := arr1[0:2:2]
	// fmt.Printf("sli2自身地址: %p sli2底层数组指针地址: %p value: %v\n", &sli2, sli2, sli2)
}

func changeSli(temp []int) []int {
	fmt.Printf("temp自身地址: %p temp底层数组指针地址: %p value: %v\n", &temp, temp, temp)
	// temp = append(temp, 10, 11, 12, 13, 14, 15)
	// 这里如果上面的append注释了，会改变外面的sli1底层的数组的值
	// 如果上面的append没有注释，则temp会发生扩容，下面就不会改变外面的sli1
	// temp[3] = 123

	temp = append(temp, 10)

	return temp
}
```

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
