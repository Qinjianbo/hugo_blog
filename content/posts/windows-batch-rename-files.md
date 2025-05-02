---
title: "Windows PowerShell 批量重命名文件教程"
date: 2025-05-02T12:01:20+08:00
draft: false
author: "Bob"
authorLink: "https://github.com/BoboidDev"
description: "使用 PowerShell 轻松实现文件批量重命名，提高文件管理效率"
tags: ["Windows技巧", "PowerShell", "文件管理", "批量重命名", "自动化"]
categories: ["Windows技巧", "技术教程"]
featuredImage: "https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto/article43.jpg"
---

## 前言

在日常工作中，我们经常需要对大量文件进行重命名操作。手动一个个重命名不仅耗时，而且容易出错。本文将介绍如何使用 PowerShell 命令快速实现文件批量重命名，大大提高工作效率。

## PowerShell 批量重命名基础命令

PowerShell 提供了强大的文件操作功能，其中 `Rename-Item` 命令是实现文件重命名的核心命令。结合其他命令，我们可以实现灵活的批量重命名功能。

基本语法如下：
```powershell
Rename-Item -Path "原文件路径" -NewName "新文件名"
```

## 实现按数字顺序重命名

以下是一个完整的批量重命名示例，将文件夹下的所有文件按数字顺序重命名：

```powershell
$i=1; Get-ChildItem "文件夹路径\*" -File | ForEach-Object { 
    Rename-Item -Path $_.FullName -NewName "$i$($_.Extension)"
    $i++ 
}
```

这个命令的工作原理：

1. `$i=1` - 初始化计数器变量
2. `Get-ChildItem "文件夹路径\*" -File` - 获取指定文件夹下的所有文件
3. `ForEach-Object` - 对每个文件执行重命名操作
4. `Rename-Item` - 重命名文件，新名称为计数器数字加原始扩展名
5. `$i++` - 计数器递增

## 更多重命名方式

除了简单的数字编号，PowerShell 还支持更多灵活的重命名方式：

### 1. 添加前缀或后缀
```powershell
Get-ChildItem *.jpg | Rename-Item -NewName { "prefix_$($_.Name)" }
```

### 2. 替换文件名中的特定文字
```powershell
Get-ChildItem *.txt | Rename-Item -NewName { $_.Name -replace "old","new" }
```

### 3. 使用日期作为文件名
```powershell
Get-ChildItem | Rename-Item -NewName { "$(Get-Date -Format 'yyyyMMdd')_$($_.Name)" }
```

## 注意事项

1. 执行重命名操作前，建议先备份重要文件
2. 使用 `-WhatIf` 参数可以预览重命名效果而不实际执行
3. 确保新文件名不包含非法字符
4. 注意文件名冲突问题

## 总结

PowerShell 的批量重命名功能可以大大提高文件管理效率。通过本文介绍的方法，你可以轻松实现各种批量重命名需求。建议在实际使用时先在测试文件夹中尝试，确认效果后再在实际文件上操作。

## 赞赏支持
如果本文对您有帮助，欢迎赞赏支持：

| 微信赞赏 | 支付宝赞赏 |
| :---: | :---: |
| ![wechatpay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/wechat/%E8%B5%9E%E8%B5%8F%E7%A0%81.jpg) | ![alipay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/alipay/%E6%94%B6%E6%AC%BE%E7%A0%81.jpg) |

> 如果您觉得文章对您有帮助，欢迎转发分享给更多的人。
>
> 关注公众号 **「无限递归」** 获取更多优质文章。
>
> ![搜索公众号](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gzh/qrcode_search.png) 