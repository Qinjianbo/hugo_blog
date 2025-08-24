---
title: "使用 PowerShell 批量重命名文件"
date: 2025-05-02T12:35:18+08:00
lastmod: 2025-05-02T12:35:18+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/posts/1.jpg
categories:
  - Windows
tags:
  - PowerShell
  - 批处理
  - 文件管理
---

在日常工作中，我们经常需要批量重命名文件，特别是当我们有大量图片或文档需要按照特定格式重命名时。本文将介绍如何使用 PowerShell 来实现文件的批量重命名。

<!--more-->

## 需求背景

假设我们有一个文件夹，里面包含了大量图片文件，文件名可能是各种各样的格式。我们想要将这些文件按照数字顺序重命名，比如：1.jpg、2.png、3.jpg 等等。

## PowerShell 解决方案

以下是一个简单但强大的 PowerShell 命令，可以帮助我们实现这个需求：

```powershell
$i=1; Get-ChildItem "D:\your_folder\*" -File | ForEach-Object { 
    Rename-Item -Path $_.FullName -NewName "$i$($_.Extension)"
    $i++ 
}
```

让我们来分解这个命令，看看它是如何工作的：

1. `$i=1` - 初始化一个计数器变量，从1开始
2. `Get-ChildItem "D:\your_folder\*" -File` - 获取指定文件夹中的所有文件
3. `ForEach-Object` - 对每个文件执行重命名操作
4. `Rename-Item -Path $_.FullName -NewName "$i$($_.Extension)"` - 重命名文件，保持原始扩展名
5. `$i++` - 计数器加1，准备处理下一个文件

## 使用说明

1. 打开 PowerShell
2. 将命令中的路径 `"D:\your_folder\*"` 替换为你实际的文件夹路径
3. 复制并粘贴修改后的命令
4. 按回车执行

## 注意事项

1. 执行命令前请确保已备份重要文件
2. 该命令会保持原始文件的扩展名不变
3. 新的文件名将按照文件系统读取顺序依次编号
4. 建议先在测试文件夹中试验，确认效果后再在实际文件上使用

## 扩展应用

这个命令还可以根据需求进行扩展，例如：

1. 添加前缀或后缀：
```powershell
$i=1; Get-ChildItem "D:\your_folder\*" -File | ForEach-Object { 
    Rename-Item -Path $_.FullName -NewName "prefix_$i$($_.Extension)"
    $i++ 
}
```

2. 使用固定位数的数字（如001、002等）：
```powershell
$i=1; Get-ChildItem "D:\your_folder\*" -File | ForEach-Object { 
    Rename-Item -Path $_.FullName -NewName "$($i.ToString('000'))$($_.Extension)"
    $i++ 
}
```

## 总结

PowerShell 提供了强大的文件处理功能，通过简单的命令就能实现批量文件重命名。这不仅提高了工作效率，也让文件管理变得更加规范和有序。希望这篇文章能帮助你更好地管理文件。

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