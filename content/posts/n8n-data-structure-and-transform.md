---
title: "n8n官方教程：数据结构与数据转换实战"
date: 2025-05-06T16:40:51+08:00
lastmod: 2025-05-06T16:40:51+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/posts/11.jpg
categories:
  - 自动化工具
  - n8n教程
tags:
  - n8n
  - 数据结构
  - 数据转换
  - 教程
---

本文基于 n8n 官方 Level Two 教程，系统讲解 n8n 的数据结构、Code 节点的用法，以及常见的数据转换技巧。适合希望深入理解 n8n 数据流和自动化处理的用户。

<!--more-->

## n8n 数据结构基础

n8n 节点间传递的数据本质上是"JSON对象数组"，每个元素称为 item。每个 item 通常结构如下：

```json
{
  "json": {
    "key1": "value1",
    "key2": "value2"
  }
}
```

- 多个 item 组成数组传递给下一个节点
- 可以嵌套对象、数组，实现复杂结构

## Code 节点创建数据集

你可以用 Code 节点（JavaScript）自定义数据集。例如：

```javascript
return [
  {
    json: {
      name: 'Alice',
      email: {
        personal: 'alice@home.com',
        work: 'alice@wonderland.org'
      }
    }
  },
  {
    json: {
      name: 'Bob',
      email: {
        personal: 'bob@mail.com',
        work: 'contact@thebuilder.com'
      }
    }
  }
];
```

## Code 节点引用上游数据

可以通过 `$input.all()` 获取上游所有 item。例如：

```javascript
let items = $input.all();
items[0].json.workEmail = items[0].json.email['work'];
return items;
```

这样可以灵活处理和扩展数据字段。

## 数据转换实战

n8n 常见的数据转换需求有：
- 一个 item 拆分为多个 item
- 多个 item 合并为一个 item

### 1. 拆分数组为多个 item

假设 HTTP 请求节点返回如下结构：

```json
{
  "results": [
    {"name": "A"},
    {"name": "B"}
  ]
}
```

可以用 Split Out 节点或 Code 节点拆分：

#### Split Out 节点
- Field To Split Out: results
- Include: No Other Fields

#### Code 节点
```javascript
let items = $input.all();
return items[0].json.results.map(item => ({ json: item }));
```

### 2. 合并多个 item 为一个 item

```javascript
return [
  {
    json: {
      data_object: $input.all().map(item => item.json)
    }
  }
];
```

## 小结

- n8n 的数据流以 JSON 对象数组为核心
- Code 节点极大提升了数据处理灵活性
- 拆分与聚合是自动化场景中最常用的数据转换方式

> 参考官方教程：[n8n官方Level Two教程-数据结构与数据转换](https://docs.n8n.io/courses/level-two/chapter-1/#transforming-data)

<!--qr_code-->

## 捐赠

感谢老板请我喝杯咖啡！Thank you for buying me a coffee!

| WeChat | AliPay | PayPal |
| --- | --- | --- |
| ![wechatpay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/wechat_%E6%94%B6%E6%AC%BE%E7%A0%81.jpg) | ![alipay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/alipay.jpg) | [PayPal](https://paypal.me/JianboQin?country.x=C2&locale.x=zh_XC) |

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】 