---
title: "使用PowerShell批量重命名文件"
date: 2025-05-02T12:27:51+08:00
lastmod: 2025-05-02T12:27:51+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto/article43.jpg
categories:
  - 技术分享
tags:
  - PowerShell
  - Windows
  - 文件管理
---

在日常工作中，我们经常需要批量重命名文件，特别是当我们有大量图片或其他文件需要按照特定格式重命名时。本文将介绍如何使用PowerShell来快速实现文件批量重命名。

<!--more-->

## 需求场景

假设我们有一个文件夹，里面包含了大量图片文件，我们想要将这些文件按照数字顺序重命名，比如：1.jpg、2.png、3.jpg 等。这种情况下，手动重命名显然效率太低，而使用PowerShell可以帮我们快速完成这项工作。

## PowerShell命令详解

以下是完整的PowerShell命令：

```powershell
$i=1; Get-ChildItem "D:\your_folder\*" -File | ForEach-Object { Rename-Item -Path $_.FullName -NewName "$i$($_.Extension)"; $i++ }
```

让我们逐步解析这个命令：

1. `$i=1` - 初始化计数器变量，从1开始
2. `Get-ChildItem "D:\your_folder\*" -File` - 获取指定文件夹中的所有文件
   - `-File` 参数确保只获取文件，不包括子文件夹
3. `ForEach-Object` - 对每个文件执行重命名操作
4. `Rename-Item -Path $_.FullName -NewName "$i$($_.Extension)"` - 重命名文件
   - `$_.FullName` 是当前文件的完整路径
   - `$i` 是当前的计数器值
   - `$($_.Extension)` 保留原始文件的扩展名
5. `$i++` - 计数器加1，准备处理下一个文件

## 使用示例

假设我们要重命名 `D:\Pictures` 文件夹中的所有图片，只需要修改路径即可：

```powershell
$i=1; Get-ChildItem "D:\Pictures\*" -File | ForEach-Object { Rename-Item -Path $_.FullName -NewName "$i$($_.Extension)"; $i++ }
```

## 注意事项

1. 执行命令前请确保已备份重要文件，因为重命名操作是不可逆的
2. 命令会保留原始文件的扩展名，确保文件类型不会改变
3. 如果文件夹中文件数量很多，建议先在小批量文件上测试
4. 确保对目标文件夹有写入权限

## 扩展应用

这个命令还可以根据需求进行修改，实现更多功能：

1. 添加前缀或后缀：
```powershell
$i=1; Get-ChildItem "D:\Pictures\*" -File | ForEach-Object { Rename-Item -Path $_.FullName -NewName "pic_$i$($_.Extension)"; $i++ }
```

2. 使用固定位数（例如：001.jpg 而不是 1.jpg）：
```powershell
$i=1; Get-ChildItem "D:\Pictures\*" -File | ForEach-Object { Rename-Item -Path $_.FullName -NewName "$($i.ToString('000'))$($_.Extension)"; $i++ }
```

3. 按文件创建时间排序后重命名：
```powershell
$i=1; Get-ChildItem "D:\Pictures\*" -File | Sort-Object CreationTime | ForEach-Object { Rename-Item -Path $_.FullName -NewName "$i$($_.Extension)"; $i++ }
```

## 总结

PowerShell提供了强大的文件管理功能，通过简单的命令就能实现批量文件重命名。这不仅提高了工作效率，也减少了手动操作可能带来的错误。掌握这个技巧后，您就能轻松处理各种文件重命名需求了。 