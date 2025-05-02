---
title: "使用PowerShell批量重命名文件"
date: 2025-05-02T12:29:23+08:00
lastmod: 2025-05-02T12:29:23+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/哔哩哔哩上搜集的美图色图_1-1000/43.jpg
categories:
  - Windows技巧
tags:
  - PowerShell
  - Windows
  - 文件管理
  - 批量重命名
---

在Windows系统中，当我们需要批量重命名大量文件时，使用PowerShell可以帮我们快速完成这项工作。本文将介绍如何使用PowerShell命令来实现文件的批量重命名。

<!--more-->

## 问题背景

在日常工作中，我们经常会遇到需要批量重命名文件的情况：

1. 整理下载的图片文件
2. 规范化文件命名
3. 为文件添加序号
4. 批量修改文件扩展名

手动一个个重命名既耗时又容易出错，这时我们就可以使用PowerShell来帮助我们完成这项工作。

## 解决方案

### 基本命令

以下是一个基本的PowerShell批量重命名命令：

```powershell
$i=1; Get-ChildItem "D:\your_folder\*" -File | ForEach-Object { Rename-Item -Path $_.FullName -NewName "$i$($_.Extension)"; $i++ }
```

### 命令解析

让我们来看看这个命令的各个组成部分：

1. `$i=1` - 初始化计数器
2. `Get-ChildItem "D:\your_folder\*" -File` - 获取指定目录下的所有文件
3. `ForEach-Object` - 遍历每个文件
4. `Rename-Item` - 执行重命名操作
5. `$i++` - 递增计数器

### 使用步骤

1. 打开PowerShell
2. 将命令中的路径改为你的目标文件夹路径
3. 复制并执行命令
4. 等待命令执行完成

## 进阶用法

### 1. 添加前缀或后缀

```powershell
$i=1; Get-ChildItem "D:\Pictures\*" -File | ForEach-Object { 
    Rename-Item -Path $_.FullName -NewName "pic_$i$($_.Extension)"
    $i++ 
}
```

### 2. 使用固定位数

```powershell
$i=1; Get-ChildItem "D:\Pictures\*" -File | ForEach-Object { 
    Rename-Item -Path $_.FullName -NewName "$($i.ToString('000'))$($_.Extension)"
    $i++ 
}
```

### 3. 按时间排序

```powershell
$i=1; Get-ChildItem "D:\Pictures\*" -File | Sort-Object CreationTime | ForEach-Object { 
    Rename-Item -Path $_.FullName -NewName "$i$($_.Extension)"
    $i++ 
}
```

## 注意事项

1. 执行命令前请先备份重要文件
2. 确保有足够的权限访问目标文件夹
3. 建议先在测试文件夹中试验
4. 注意检查文件数量，避免重名冲突

## 小结

PowerShell的批量重命名功能可以大大提高我们的工作效率。通过本文介绍的方法，你可以轻松实现文件的批量重命名，并根据实际需求调整命令参数。

## 参考链接

1. [PowerShell官方文档](https://docs.microsoft.com/en-us/powershell/)
2. [Windows命令行工具](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands)

---

> 关注微信公众号 **[无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/wechat/qrcode_for_gh_e7dd6b8a5b38_430.jpg)** ，了解更多有趣的技术知识。
> 
> 本文作者: 胡巴
> 
> 本文链接: https://boboidea.com/posts/powershell-batch-rename-files/
> 
> 版权声明: 本博客所有文章除特别声明外，均采用 [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) 许可协议。转载请注明来源！ 