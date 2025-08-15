---
title: RAGFlow OCR实现机制
date: 2025-08-14T16:18:01+08:00
lastmod: 2025-08-14T16:18:01+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/%E5%93%94%E5%93%A9%E5%93%94%E5%93%A9%E4%B8%8A%E6%90%9C%E9%9B%86%E7%9A%84%E7%BE%8E%E5%9B%BE%E8%89%B2%E5%9B%BE_1-1000/24.jpg
categories:
  - RAGFlow
tags:
  - RAGFlow
  - OCR
  - 文本识别
  - 布局识别
---

# RAGFlow OCR实现机制

## 概述

RAGFlow 的 OCR（光学字符识别）系统是其文档理解的核心组件，基于深度学习模型实现了高精度的文本检测和识别。该系统位于 `deepdoc/vision` 模块中，采用了分离式的文本检测和文本识别架构。

## 系统架构

### 核心组件

RAGFlow 的 OCR 系统主要由以下几个核心模块组成：

1. **OCR 主类** (`deepdoc/vision/ocr.py`)
   - `TextDetector`: 负责文本区域检测
   - `TextRecognizer`: 负责文本内容识别  
   - `OCR`: 统一接口类，整合检测和识别功能

2. **布局识别器** (`deepdoc/vision/layout_recognizer.py`)
   - `LayoutRecognizer`: 识别文档布局结构
   - 支持 10 种基本布局类型：文本、标题、图像、图像标题、表格、表格标题、页眉、页脚、参考文献、公式

3. **图像处理操作符** (`deepdoc/vision/operators.py`)
   - 提供各种图像预处理和后处理操作

4. **后处理模块** (`deepdoc/vision/postprocess.py`)
   - `DBPostProcess`: DB 文本检测后处理
   - `CTCLabelDecode`: CTC 文本识别解码

### 模型架构

```
输入图像
    ↓
文本检测模型 (TextDetector)
    ↓
检测框筛选与排序
    ↓
文本区域裁剪
    ↓
文本识别模型 (TextRecognizer)
    ↓
置信度过滤
    ↓
输出文本结果
```

## 技术实现细节

### 1. 文本检测 (TextDetector)

**模型基础**: 基于 DB (Differentiable Binarization) 算法的文本检测模型

**关键参数**:
```python
pre_process_list = [{
    'DetResizeForTest': {
        'limit_side_len': 960,
        'limit_type': "max",
    }
}, {
    'NormalizeImage': {
        'std': [0.229, 0.224, 0.225],
        'mean': [0.485, 0.456, 0.406],
        'scale': '1./255.',
        'order': 'hwc'
    }
}]

postprocess_params = {
    "name": "DBPostProcess", 
    "thresh": 0.3, 
    "box_thresh": 0.5, 
    "max_candidates": 1000,
    "unclip_ratio": 1.5, 
    "use_dilation": False, 
    "score_mode": "fast", 
    "box_type": "quad"
}
```

**处理流程**:
1. 图像预处理：缩放、归一化、通道转换
2. 模型推理：ONNX Runtime 执行推理
3. 后处理：阈值处理、轮廓提取、框过滤
4. 检测框排序：从上到下、从左到右的阅读顺序

### 2. 文本识别 (TextRecognizer)

**模型基础**: 基于 CTC (Connectionist Temporal Classification) 的文本识别模型

**关键参数**:
```python
rec_image_shape = [3, 48, 320]  # C, H, W
rec_batch_num = 16
drop_score = 0.5  # 置信度阈值
```

**处理流程**:
1. 文本区域裁剪和透视变换矫正
2. 图像缩放和归一化处理
3. 批量推理提升效率
4. CTC 解码获得文本结果
5. 置信度过滤

### 3. 布局识别 (LayoutRecognizer)

**支持的布局类型**:
```python
labels = [
    "_background_", "Text", "Title", "Figure", 
    "Figure caption", "Table", "Table caption", 
    "Header", "Footer", "Reference", "Equation"
]
```

**垃圾内容过滤**: 系统能够自动识别和过滤页眉、页脚、版权信息等垃圾内容

## 模型管理

### 模型获取方式

RAGFlow 采用了灵活的模型管理策略：

1. **本地模型**: 优先使用本地 `rag/res/deepdoc` 目录下的模型
2. **自动下载**: 如果本地模型不存在，自动从 HuggingFace 下载
3. **镜像支持**: 支持 HuggingFace 镜像站点加速下载

```python
if not model_dir:
    try:
        model_dir = os.path.join(get_project_base_directory(), "rag/res/deepdoc")
        self.text_detector = TextDetector(model_dir)
        self.text_recognizer = TextRecognizer(model_dir)
    except Exception:
        model_dir = snapshot_download(
            repo_id="InfiniFlow/deepdoc",
            local_dir=os.path.join(get_project_base_directory(), "rag/res/deepdoc"),
            local_dir_use_symlinks=False
        )
```

### 运行时优化

1. **ONNX Runtime**: 使用 ONNX Runtime 进行模型推理，支持 CPU 和 GPU 加速
2. **批量处理**: 文本识别支持批量处理，提升处理效率
3. **内存优化**: 关闭 CPU 内存池，优化内存使用
4. **重试机制**: 内置推理失败重试机制，提升系统稳定性

## 接口使用

### 基本使用方式

```python
from deepdoc.vision import OCR
import numpy as np
import cv2

# 初始化 OCR
ocr = OCR()

# 加载图像
image = cv2.imread("path/to/image.jpg")

# 执行 OCR
results = ocr(image)

# 结果格式: [(bbox, (text, confidence))]
for bbox, (text, confidence) in results:
    print(f"文本: {text}, 置信度: {confidence}")
    print(f"位置: {bbox}")
```

### 高级用法

```python
# 仅检测文本位置
detection_results = ocr.detect(image)

# 识别特定区域文本
text = ocr.recognize(image, bbox)

# 自定义参数
ocr.drop_score = 0.7  # 调整置信度阈值
results = ocr(image, cls=False)  # 禁用文本方向分类
```

## 性能特性

1. **高精度**: 针对多种文档类型优化，识别准确率高
2. **高效率**: 批量处理和 ONNX 推理优化，处理速度快
3. **鲁棒性**: 内置重试机制和异常处理，系统稳定性强
4. **灵活性**: 支持参数调整和模块化使用

## 测试工具

RAGFlow 提供了便捷的测试工具：

```bash
# OCR 测试
python deepdoc/vision/t_ocr.py --inputs=path_to_images_or_pdfs --output_dir=./ocr_outputs

# 布局识别测试  
python deepdoc/vision/t_recognizer.py --inputs=path_to_images_or_pdfs --threshold=0.2 --mode=layout --output_dir=./layout_outputs
```

## 总结

RAGFlow 的 OCR 系统通过深度集成检测和识别模型，结合布局分析和智能后处理，为文档理解提供了强大的文本提取能力。其模块化设计和丰富的配置选项，使其能够适应各种应用场景的需求。

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】 