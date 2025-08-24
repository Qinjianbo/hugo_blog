---
title: RAGFlow Embedding 实现机制
date: 2025-08-15T09:09:01+08:00
lastmod: 2025-08-15T09:09:01+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/posts/25.jpg
categories:
  - RAGFlow
tags:
  - RAGFlow
  - embedding
  - 文本向量化
  - 文本向量检索
---

# RAGFlow Embedding 实现机制

## 概述

RAGFlow 的 embedding 系统采用了**多提供商统一接口**的设计模式，支持 20+ 种不同的 embedding 提供商和模型，包括本地模型和云端 API 服务。该系统为 RAG（检索增强生成）提供了高质量的文本向量化能力。

## 系统架构

### 核心组件

**主要文件位置**：
- `rag/llm/embedding_model.py` - 核心实现文件，包含所有 embedding 模型类
- `rag/llm/__init__.py` - 模型注册和工厂类定义
- `rag/svr/task_executor.py` - embedding 处理逻辑和任务执行
- `api/db/services/llm_service.py` - 模型服务和配置管理

### 设计模式

```
统一接口层 (Base ABC)
    ↓
多提供商实现层 (OpenAIEmbed, DefaultEmbedding, etc.)
    ↓
工厂注册层 (EmbeddingModel Dictionary)
    ↓
服务管理层 (LLMBundle, TenantLLMService)
    ↓
任务执行层 (TaskExecutor)
```

## 支持的 Embedding 提供商

RAGFlow 支持以下 embedding 提供商：

```python
EmbeddingModel = {
    "BAAI": DefaultEmbedding,          # 默认本地模型 (bge-large-zh-v1.5)
    "OpenAI": OpenAIEmbed,             # OpenAI text-embedding
    "Azure-OpenAI": AzureEmbed,        # Azure OpenAI
    "Tongyi-Qianwen": QWenEmbed,       # 阿里通义千问
    "ZHIPU-AI": ZhipuEmbed,           # 智谱 AI
    "Ollama": OllamaEmbed,            # Ollama 本地服务
    "LocalAI": LocalAIEmbed,          # LocalAI
    "Xinference": XinferenceEmbed,    # Xinference
    "FastEmbed": FastEmbed,           # FastEmbed 优化版本
    "Youdao": YoudaoEmbed,           # 有道 BCE embedding
    "BaiChuan": BaiChuanEmbed,       # 百川智能
    "Jina": JinaEmbed,               # Jina AI
    "Mistral": MistralEmbed,         # Mistral
    "Bedrock": BedrockEmbed,         # AWS Bedrock
    "Gemini": GeminiEmbed,           # Google Gemini
    "NVIDIA": NvidiaEmbed,           # NVIDIA
    "LM-Studio": LmStudioEmbed,      # LM Studio
    "OpenAI-API-Compatible": OpenAI_APIEmbed,  # 兼容 OpenAI API
    "Cohere": CoHereEmbed,           # Cohere
    "TogetherAI": TogetherAIEmbed,   # Together AI
    "PerfXCloud": PerfXCloudEmbed,   # PerfXCloud
    "Upstage": UpstageEmbed,         # Upstage
    "SILICONFLOW": SILICONFLOWEmbed, # 硅基流动
    "Replicate": ReplicateEmbed,     # Replicate
    "BaiduYiyan": BaiduYiyanEmbed,   # 百度文心一言
    "Voyage AI": VoyageEmbed,        # Voyage AI
    "HuggingFace": HuggingFaceEmbed, # HuggingFace
    "VolcEngine": VolcEngineEmbed,   # 火山引擎
}
```

## 核心实现

### 1. 统一接口设计

所有 embedding 模型都继承自 `Base` 抽象基类：

```python
class Base(ABC):
    def __init__(self, key, model_name):
        pass
    
    def encode(self, texts: list):
        """批量文本向量化
        Args:
            texts: 文本列表
        Returns:
            tuple: (向量数组, token数量)
        """
        raise NotImplementedError("Please implement encode method!")
    
    def encode_queries(self, text: str):
        """单个查询文本向量化
        Args:
            text: 查询文本
        Returns:
            tuple: (向量数组, token数量)
        """
        raise NotImplementedError("Please implement encode method!")
```

### 2. 默认 Embedding 模型实现

**DefaultEmbedding 类**是 RAGFlow 的默认本地 embedding 实现：

```python
class DefaultEmbedding(Base):
    _model = None
    _model_name = ""
    _model_lock = threading.Lock()
    
    def __init__(self, key, model_name, **kwargs):
        if not settings.LIGHTEN:
            with DefaultEmbedding._model_lock:
                from FlagEmbedding import FlagModel
                import torch
                if not DefaultEmbedding._model or model_name != DefaultEmbedding._model_name:
                    try:
                        # 使用本地模型
                        DefaultEmbedding._model = FlagModel(
                            model_path,
                            query_instruction_for_retrieval="为这个句子生成表示以用于检索相关文章：",
                            use_fp16=torch.cuda.is_available()
                        )
                        DefaultEmbedding._model_name = model_name
                    except Exception:
                        # 自动从 HuggingFace 下载 BAAI/bge-large-zh-v1.5
                        model_dir = snapshot_download(
                            repo_id="BAAI/bge-large-zh-v1.5",
                            local_dir=local_path,
                            local_dir_use_symlinks=False
                        )
                        DefaultEmbedding._model = FlagModel(model_dir, ...)
    
    def encode(self, texts: list):
        batch_size = 16
        texts = [truncate(t, 2048) for t in texts]  # 文本截断
        token_count = sum(num_tokens_from_string(t) for t in texts)
        
        ress = []
        for i in range(0, len(texts), batch_size):
            ress.extend(self._model.encode(texts[i:i + batch_size]).tolist())
        return np.array(ress), token_count
    
    def encode_queries(self, text: str):
        token_count = num_tokens_from_string(text)
        return self._model.encode_queries([text]).tolist()[0], token_count
```

### 3. OpenAI Embedding 实现示例

```python
class OpenAIEmbed(Base):
    def __init__(self, key, model_name="text-embedding-ada-002", base_url="https://api.openai.com/v1"):
        if not base_url:
            base_url = "https://api.openai.com/v1"
        self.client = OpenAI(api_key=key, base_url=base_url)
        self.model_name = model_name
    
    def encode(self, texts: list):
        batch_size = 16  # OpenAI 要求批量大小 ≤16
        texts = [truncate(t, 8191) for t in texts]  # 文本长度限制
        ress = []
        total_tokens = 0
        
        for i in range(0, len(texts), batch_size):
            res = self.client.embeddings.create(
                input=texts[i:i + batch_size],
                model=self.model_name
            )
            ress.extend([d.embedding for d in res.data])
            total_tokens += res.usage.total_tokens
        
        return np.array(ress), total_tokens
    
    def encode_queries(self, text):
        res = self.client.embeddings.create(
            input=[truncate(text, 8191)],
            model=self.model_name
        )
        return np.array(res.data[0].embedding), res.usage.total_tokens
```

## Embedding 处理流程

### 文档向量化流程

在文档解析和切块后，系统会对文档进行向量化处理：

```python
def embedding(docs, mdl, parser_config=None, callback=None):
    """文档 embedding 处理函数
    Args:
        docs: 文档chunks列表
        mdl: embedding模型实例  
        parser_config: 解析配置
        callback: 回调函数
    """
    if parser_config is None:
        parser_config = {}
    
    # 1. 提取标题和内容
    tts = [d["title_tks"] for d in docs if d.get("title_tks")]
    cnts = [d["content_with_weight"] for d in docs]
    
    # 2. 配置参数
    batch_size = parser_config.get("embedding_batch_size", 32)
    vctr_nm = f"q_{vector_size}_vec"
    title_vctr_nm = f"q_{vector_size}_title_vec"
    
    # 3. 批量处理标题向量化
    tts_ = np.array([])
    if tts:
        for i in range(0, len(tts), batch_size):
            vts, c = mdl.encode(tts[i: i + batch_size])  # 核心调用
            if len(tts_) == 0:
                tts_ = vts
            else:
                tts_ = np.concatenate((tts_, vts), axis=0)
            if callback:
                callback(msg="Embedding titles...")
    
    # 4. 批量处理内容向量化
    cnts_ = np.array([])
    for i in range(0, len(cnts), batch_size):
        vts, c = mdl.encode(cnts[i: i + batch_size])  # 核心调用
        if len(cnts_) == 0:
            cnts_ = vts
        else:
            cnts_ = np.concatenate((cnts_, vts), axis=0)
        if callback:
            callback(msg=f"Embedding contents({i + batch_size}/{len(cnts)})...")
    
    # 5. 向量存储到文档
    for i, d in enumerate(docs):
        if i < len(cnts_):
            d[vctr_nm] = cnts_[i].tolist()
        if i < len(tts_):
            d[title_vctr_nm] = tts_[i].tolist()
    
    return docs
```

### 模型实例化机制

**LLMBundle 获取模型实例**：

```python
@classmethod
def model_instance(cls, tenant_id, llm_type, llm_name=None, lang="Chinese"):
    """获取模型实例
    Args:
        tenant_id: 租户ID
        llm_type: 模型类型 (EMBEDDING, CHAT, etc.)
        llm_name: 模型名称
        lang: 语言设置
    Returns:
        模型实例
    """
    # 1. 获取租户配置
    e, tenant = TenantService.get_by_id(tenant_id)
    if not e:
        raise LookupError("Tenant not found")
    
    # 2. 确定模型名称
    if llm_type == LLMType.EMBEDDING.value:
        mdlnm = tenant.embd_id if not llm_name else llm_name
    elif llm_type == LLMType.SPEECH2TEXT.value:
        mdlnm = tenant.asr_id
    elif llm_type == LLMType.IMAGE2TEXT.value:
        mdlnm = tenant.img2txt_id if not llm_name else llm_name
    else:
        mdlnm = tenant.llm_id if not llm_name else llm_name
    
    # 3. 获取 API 配置
    llm = TenantLLMService.get_api_key(tenant_id, mdlnm)
    if not llm:
        raise LookupError("LLM not found")
    
    # 4. 解析模型名称和工厂
    mdl_nm, fctry = TenantLLMService.split_model_name_and_factory(mdlnm)
    if fctry:
        mdl_nm = mdlnm.replace(f"@{fctry}", "")
    else:
        fctry = llm.llm_factory
    
    # 5. 实例化具体的 embedding 模型
    if llm_type == LLMType.EMBEDDING.value:
        mdl_class = EmbeddingModel.get(fctry)
        if not mdl_class:
            raise LookupError(f"Embedding model factory {fctry} not found")
        
        return mdl_class(
            key=llm.api_key,
            model_name=mdl_nm,
            base_url=llm.api_base
        )
```

## 高级特性

### 1. 性能优化

**批量处理**：
```python
# 支持批量向量化，提升处理效率
batch_size = parser_config.get("embedding_batch_size", 32)
for i in range(0, len(texts), batch_size):
    vectors, tokens = model.encode(texts[i:i + batch_size])
```

**线程安全**：
```python
# 使用锁机制确保模型加载的线程安全
_model_lock = threading.Lock()
with DefaultEmbedding._model_lock:
    # 模型初始化代码
```

**单例模式**：
```python
# 避免重复加载模型，节省内存
class DefaultEmbedding(Base):
    _model = None  # 类级别共享模型实例
    _model_name = ""
```

### 2. 自动化特性

**模型自动下载**：
```python
try:
    # 尝试使用本地模型
    model = FlagModel(local_path)
except Exception:
    # 自动从 HuggingFace 下载
    model_dir = snapshot_download(
        repo_id="BAAI/bge-large-zh-v1.5",
        local_dir=local_path,
        local_dir_use_symlinks=False
    )
    model = FlagModel(model_dir)
```

**错误重试机制**：
```python
for i in range(100000):  # 重试机制
    try:
        outputs = self.predictor.run(None, input_dict)
        break
    except Exception as e:
        if i >= 3:
            raise e
        time.sleep(5)
```

### 3. 文本处理优化

**智能截断**：
```python
# 根据不同模型的限制进行文本截断
texts = [truncate(t, 2048) for t in texts]  # BAAI 模型
texts = [truncate(t, 8191) for t in texts]  # OpenAI 模型
```

**Token 计数**：
```python
# 精确的 token 使用量统计
token_count = sum(num_tokens_from_string(t) for t in texts)
return vectors, token_count
```

## 向量存储集成

### Elasticsearch 集成

RAGFlow 默认使用 Elasticsearch 作为向量存储引擎：

```python
# 向量字段映射配置
"q_768_vec": {
    "type": "dense_vector",
    "dims": 768,
    "index": true,
    "similarity": "cosine"
}
```

### Infinity 集成

可选的高性能向量数据库：

```python
# 切换到 Infinity
DOC_ENGINE=infinity  # 在 docker/.env 中配置
```

### 混合检索支持

支持文本检索和向量检索的融合：

```python
class FusionExpr:
    """融合检索表达式"""
    def __init__(self, text_expr, dense_expr, fusion_type="rrf"):
        self.text_expr = text_expr      # 文本检索
        self.dense_expr = dense_expr    # 向量检索  
        self.fusion_type = fusion_type  # 融合方式
```

## 使用示例

### 基本用法

```python
from rag.llm import EmbeddingModel
from api.db.services.llm_service import LLMBundle
from api.db import LLMType

# 1. 获取 embedding 模型实例
embd_mdl = LLMBundle(tenant_id, LLMType.EMBEDDING)

# 2. 批量向量化文本
texts = ["这是一段测试文本", "另一段文本", "第三段文本"]
vectors, token_count = embd_mdl.encode(texts)

print(f"向量维度: {vectors.shape}")  # (3, 1024)
print(f"使用Token: {token_count}")

# 3. 查询向量化
query = "查询文本"
query_vector, tokens = embd_mdl.encode_queries(query)
print(f"查询向量: {query_vector.shape}")  # (1024,)
```

### 自定义配置

```python
# 使用特定的 embedding 提供商
from rag.llm.embedding_model import OpenAIEmbed

# 实例化 OpenAI embedding 模型
openai_embed = OpenAIEmbed(
    key="your-api-key",
    model_name="text-embedding-3-large",
    base_url="https://api.openai.com/v1"
)

# 向量化处理
vectors, tokens = openai_embed.encode(["test text"])
```

### 在文档处理中的应用

```python
# 在文档解析流程中使用
def process_documents(docs, tenant_id):
    # 1. 获取 embedding 模型
    embd_mdl = LLMBundle(tenant_id, LLMType.EMBEDDING)
    
    # 2. 配置参数
    parser_config = {
        "embedding_batch_size": 32,
        "chunk_token_count": 128
    }
    
    # 3. 执行 embedding
    embedded_docs = embedding(docs, embd_mdl, parser_config)
    
    # 4. 存储到向量数据库
    for doc in embedded_docs:
        # doc 包含向量字段: q_1024_vec, q_1024_title_vec
        store_to_database(doc)
```

## 配置管理

### 租户级配置

每个租户可以独立配置 embedding 模型：

```python
# 租户 embedding 配置
tenant.embd_id = "text-embedding-3-large@OpenAI"
tenant.save()
```

### API 密钥管理

安全的 API 密钥存储和管理：

```python
# 配置 API 密钥
TenantLLMService.save(
    tenant_id=tenant_id,
    llm_factory="OpenAI",
    llm_name="text-embedding-3-large",
    api_key="your-api-key",
    api_base="https://api.openai.com/v1"
)
```

### 环境变量配置

支持通过环境变量配置：

```bash
# HuggingFace 镜像站点
export HF_ENDPOINT=https://hf-mirror.com

# 轻量化模式（不加载本地模型）
export LIGHTEN=1
```

## 监控和调试

### 性能监控

```python
# Token 使用统计
logger.info(f"Embedding tokens used: {token_count}")

# 处理时间监控
start_time = timer()
vectors, tokens = model.encode(texts)
elapsed = timer() - start_time
logger.info(f"Embedding time: {elapsed:.2f}s")
```

### 错误处理

```python
try:
    vectors, tokens = model.encode(texts)
except Exception as e:
    logger.error(f"Embedding failed: {str(e)}")
    # 降级处理或重试逻辑
```

## 扩展指南

### 添加新的 Embedding 提供商

1. **创建模型类**：
```python
class NewProviderEmbed(Base):
    def __init__(self, key, model_name, **kwargs):
        # 初始化逻辑
        pass
    
    def encode(self, texts: list):
        # 实现批量向量化
        return vectors, token_count
    
    def encode_queries(self, text: str):
        # 实现查询向量化
        return vector, token_count
```

2. **注册到工厂**：
```python
# 在 rag/llm/__init__.py 中添加
EmbeddingModel = {
    # ... 现有模型
    "NewProvider": NewProviderEmbed,
}
```

3. **更新配置**：
```python
# 在 conf/llm_factories.json 中添加提供商信息
```

### 自定义向量化逻辑

```python
def custom_embedding_processor(docs, model, config):
    """自定义 embedding 处理逻辑"""
    # 预处理
    processed_texts = preprocess_texts([d["content"] for d in docs])
    
    # 向量化
    vectors, tokens = model.encode(processed_texts)
    
    # 后处理
    vectors = postprocess_vectors(vectors)
    
    # 存储
    for i, doc in enumerate(docs):
        doc["custom_vector"] = vectors[i].tolist()
    
    return docs
```

## 总结

RAGFlow 的 embedding 实现机制具有以下核心优势：

1. **多提供商支持**：统一接口支持 20+ 种 embedding 服务，满足不同场景需求
2. **灵活配置**：租户级别的模型配置和 API 密钥管理
3. **性能优化**：批量处理、缓存机制、线程安全，确保高效运行
4. **易于扩展**：标准化接口设计，便于添加新的 embedding 提供商
5. **完整集成**：与文档处理、向量存储、检索等模块深度集成
6. **自动化特性**：模型自动下载、错误重试、智能降级
7. **监控支持**：完整的日志记录、性能监控、错误处理机制

这种设计使得 RAGFlow 能够灵活适应不同的部署环境和业务需求，既支持本地部署的开源模型，也支持各种云端 API 服务，为构建高质量的 RAG 系统提供了坚实的基础。

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】 