---
title: "使用Python脚本轻松整理大量文件：按数量自动分类归档"
subtitle: "一个实用的文件批量整理Python脚本"
date: 2024-03-27T10:30:00+08:00
lastmod: 2024-03-27T10:30:00+08:00
draft: false
author: "bobo"
authorLink: "https://github.com/boboidea"
description: "介绍如何使用Python脚本自动将大量文件按照指定数量分类到不同文件夹中，提高文件管理效率。"
license: "原创文章，允许转载，转载时请标明出处"
images: ["https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto/article (38).jpg"]

tags: ["Python", "文件管理", "自动化", "效率工具"]
categories: ["技术分享"]

featuredImage: "https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto/article (38).jpg"
featuredImagePreview: "https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto/article (38).jpg"

hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: true
ruby: true
fraction: true
fontawesome: true
linkToMarkdown: true
rssFullText: false
---

## 背景介绍

在日常工作和生活中，我们经常会遇到需要整理大量文件的情况。比如：

- 整理上千张照片
- 管理大量下载的文档
- 归档历史文件

手动创建文件夹并移动文件不仅耗时，而且容易出错。今天我要分享一个实用的Python脚本，它可以自动将大量文件按照指定数量（默认1000个）分类到不同文件夹中。

## 脚本实现

这是完整的Python脚本代码：

```python
import os
import shutil
from pathlib import Path

def sort_images(source_dir, batch_size=1000):
    # 获取源目录的Path对象
    source_path = Path(source_dir)
    
    # 获取所有图片文件
    image_extensions = ('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp')
    image_files = [f for f in source_path.glob('*') if f.suffix.lower() in image_extensions]
    
    # 计算需要创建的文件夹数量
    total_images = len(image_files)
    num_folders = (total_images + batch_size - 1) // batch_size
    
    print(f'处理文件夹：{source_dir}')
    print(f'找到 {total_images} 张图片，将分成 {num_folders} 个文件夹')
    
    # 创建文件夹并移动文件
    for i in range(num_folders):
        # 创建新文件夹
        folder_name = f'{i*batch_size+1}-{min((i+1)*batch_size, total_images)}'
        new_folder = source_path.parent / f'{source_path.name}_{folder_name}'
        new_folder.mkdir(exist_ok=True)
        
        # 移动这一批次的文件
        start_idx = i * batch_size
        end_idx = min((i + 1) * batch_size, total_images)
        
        for image_file in image_files[start_idx:end_idx]:
            shutil.move(str(image_file), str(new_folder / image_file.name))
            
        print(f'已完成文件夹 {folder_name} 的处理，包含 {end_idx-start_idx} 张图片')
    
    print('处理完成！\n')

if __name__ == '__main__':
    # 需要处理的文件夹列表
    folders_to_process = [
        r'D:\需要整理的文件夹1',
        r'D:\需要整理的文件夹2'
    ]
    
    # 依次处理每个文件夹
    for folder in folders_to_process:
        sort_images(folder)
```

## 脚本功能说明

1. **文件识别**：
   - 支持常见图片格式：jpg、jpeg、png、gif、bmp、webp
   - 可以通过修改`image_extensions`变量来支持其他文件类型

2. **自动分类**：
   - 默认每1000个文件一个文件夹
   - 可以通过修改`batch_size`参数自定义每个文件夹的文件数量

3. **命名规则**：
   - 新文件夹命名格式：原文件夹名_起始序号-结束序号
   - 例如：`我的照片_1-1000`、`我的照片_1001-2000`

4. **进度显示**：
   - 显示总文件数和需要创建的文件夹数量
   - 实时显示每个文件夹的处理进度
   - 显示每个文件夹实际包含的文件数量

## 使用方法

1. **准备工作**：
   - 确保已安装Python（建议Python 3.6或更高版本）
   - 将脚本保存为`sort_files.py`

2. **配置文件夹**：
   - 打开脚本
   - 修改`folders_to_process`列表中的文件夹路径
   - 可以同时添加多个需要处理的文件夹路径

3. **运行脚本**：
   - 打开命令提示符或PowerShell
   - 进入脚本所在目录
   - 运行命令：`python sort_files.py`

4. **等待完成**：
   - 脚本会显示处理进度
   - 完成后会在原文件夹同级目录下创建新的分类文件夹

## 使用示例

假设有一个文件夹`D:\我的照片`，里面有2345张照片，运行脚本后会：

1. 创建3个文件夹：
   - `我的照片_1-1000`（包含1000张照片）
   - `我的照片_1001-2000`（包含1000张照片）
   - `我的照片_2001-2345`（包含345张照片）

2. 自动将所有照片移动到对应的文件夹中

## 注意事项

1. 运行脚本前请**备份重要文件**
2. 确保目标路径有足够的存储空间
3. 确保对目标文件夹有读写权限
4. 脚本会移动而不是复制文件，请谨慎操作

## 扩展建议

1. **支持更多文件类型**：
   ```python
   # 修改或添加文件扩展名
   file_extensions = ('.jpg', '.pdf', '.doc', '.txt')
   ```

2. **自定义分组数量**：
   ```python
   # 修改每组文件数量
   sort_images(source_dir, batch_size=500)  # 每500个文件一组
   ```

3. **添加文件过滤条件**：
   ```python
   # 按文件大小过滤
   if image_file.stat().st_size > 1024 * 1024:  # 大于1MB的文件
   ```

## 总结

这个Python脚本可以大大提高文件整理的效率，特别适合需要处理大量文件的场景。通过简单的配置，就能实现文件的自动分类整理，让文件管理变得更加轻松。

希望这个脚本能帮助到需要整理大量文件的朋友们。如果您有任何改进建议，欢迎在评论区留言！ 