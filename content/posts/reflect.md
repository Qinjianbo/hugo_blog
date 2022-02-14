---
title: golang中reflect的使用
date: 2022-02-14T14:47:46+08:00
lastmod: 2022-02-14T14:47:46+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: /img/posts/hzw86.jpeg
# images:
#   - /img/cover.jpg
categories:
  - golang
tags:
  - reflect
# nolastmod: true
draft: false
---

本篇文章记录golang中reflect的使用

<!--more-->

```go
package main

import (
	"fmt"
	"reflect"
)

type Animal interface {
	Run()
}

type Swimming struct{}
func(s *Swimming) swim() {
	fmt.Println("can swim!")
}

type Dog struct {
	Name    string
	Species string
	*Swimming
	age int
}

func (d *Dog) Bark() {
	fmt.Println("Wang Wang Wang ~~~")
}

func (d *Dog) Run() {
	fmt.Println(d.Name, " is running!")
}

// reflect.ValueOf 可以获取一个变量的类型
// 类型Type包含type和kind
// type例如main.Dog
// kind例如struct(golang中的那些数据类型)

// Type里有个rtype struct，rtype实现了Type接口中的
// 不同方法, 不同方法内部又根据实际Kind做了判断，
// 即不是所有方法都适用于任何Kind
// 例如 NumField方法，这个方法只有Kind == struct时才可以适用

// xxxType struct又都组合了rtype,因此也都实现了Type接口的方法
func main() {
	dog := Dog{
		Name:    "七宝",
		Species: "土狗",
	}
	typeOfDog := reflect.TypeOf(dog)
	fmt.Printf("typeOfDog is %s kindOfDog is %s\n", typeOfDog, typeOfDog.Kind())

	dogPtr := &dog
	typeOfDogPtr := reflect.TypeOf(dogPtr)
	fmt.Printf("typeOfDogPtr is %s kindOfDogPtr is %s\n", typeOfDogPtr, typeOfDogPtr.Kind())
	fmt.Println()

	// 这里主要使用NumField()方法获取struct中的字段数量
	// 然后通过Field(i)来获取具体的Field
	for i := 0; i < typeOfDog.NumField(); i++ {
		field := typeOfDog.Field(i)
		fmt.Println(field.Name, " ", field.Type, " ", field.Type.Kind())
	}
	fmt.Println()
	// 通过FieldByName可以获取指定名字的Field
	field, ok := typeOfDog.FieldByName("Name")
	if !ok {
		fmt.Println("no field:Name")
	} else {
		fmt.Println(field.Name, " ", field.Type, " ", field.Type.Kind())
	}
	fmt.Println()

	// 这里主要适用NumMethod()方法获取struct中的方法数量
	// 然后通过Method(i)获取具体的Method
	for i := 0; i < typeOfDogPtr.NumMethod(); i++ {
		method := typeOfDogPtr.Method(i)
		fmt.Println(method.Name, " ", method.Type, " ", method.Type.Kind())
	}
	fmt.Println()
	// 通过MethodByName可以判断struct是否拥有Run方法
	method, ok := typeOfDogPtr.MethodByName("Run")
	if !ok {
		fmt.Println("no method:Run")
	} else {
		fmt.Println(method.Name, " ", method.Type, " ", method.Type.Kind())
	}
	fmt.Println()

	// 这里验证了一下swim这个不可导出的方法是否可以通过reflect
	// 反射出来，结果是：不可以
	typeOfSwimming := reflect.TypeOf(Swimming{})
	for i := 0; i < typeOfSwimming.NumMethod(); i++ {
		method := typeOfSwimming.Method(i)
		fmt.Println(method.Name, " ", method.Type, " ", method.Type.Kind())
	}

	// ---------------------------valueOf----------------------------
	fmt.Println()
	name := "xiaoming"
	namePtr := reflect.ValueOf(&name).Elem()
	namePtrType := reflect.TypeOf(namePtr)
	fmt.Println(namePtrType.Name, " ", namePtrType, " ", namePtrType.Kind())
	namePtr.Set(reflect.ValueOf("xiaohong"))
	fmt.Println(name)
	fmt.Println(namePtr)
	fmt.Println()

	// 需要使用Elem()拿到dog的地址
	// 也就是需要拿到可寻址的地址后
	// 才能对它的属性进行修改
	valueOfDog := reflect.ValueOf(&dog)
	valueOfDogElem := valueOfDog.Elem()
	dogNameValue := valueOfDogElem.FieldByName("Name")
	dogNameValue.Set(reflect.ValueOf("大黄"))
	fmt.Println(dog)

	// 通过Call方法进行方法调用
	runMethod := valueOfDog.MethodByName("Run")
	returns := runMethod.Call([]reflect.Value{})
}
```

<!--qr_code-->

### 公众号: 无限递归

![alt 搜索公众号:无限递归](/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】
