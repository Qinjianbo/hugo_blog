# wechat-mp-article-manager 使用说明

本文档说明如何使用 Codex skill：`wechat-mp-article-manager` 将文章（Markdown/HTML）上传到微信公众号草稿箱，并自动处理图片。

## 0. 功能概览

- 上传指定文章到公众号草稿箱（draft）
- 自动上传文章内图片到公众号图片接口并替换为微信图片地址
  - 本地图片：必定上传并替换
  - 远程图片（http/https）：默认会下载后上传并替换（可关闭）
- 读取公众号 `AppId/AppSecret`（环境变量或本地 secrets 文件）
- 自动封面：默认使用文章第一张图作为封面（可关闭/可手动指定）

## 1. 前置准备

需要准备：

- 公众号 `AppId`、`AppSecret`
- 文章文件：`.md` 或 `.html`

推荐：

- 文章至少包含 1 张图片（这样可以自动选封面；否则需要手动提供 `--cover` 或 `--thumb-media-id`）

## 2. 配置 AppId / AppSecret（任选其一）

### 方案 A：环境变量（推荐）

```bash
export WECHAT_MP_APPID='xxx'
export WECHAT_MP_APPSECRET='yyy'
```

### 方案 B：本地 secrets 文件

创建文件：`~/.codex/wechat-mp.env`

```bash
WECHAT_MP_APPID=xxx
WECHAT_MP_APPSECRET=yyy
```

## 3. 安装依赖（只需一次）

Homebrew Python 默认启用 PEP 668，建议使用 venv：

```bash
/Users/qinjianbo/.codex/skills/wechat-mp-article-manager/scripts/bootstrap_venv.sh
```

## 4. 上传文章到草稿箱

脚本入口：

```bash
/Users/qinjianbo/.codex/skills/wechat-mp-article-manager/.venv/bin/python \
  /Users/qinjianbo/.codex/skills/wechat-mp-article-manager/scripts/wechat_mp_draft_upload.py --help
```

### 4.1 Hugo Markdown（手动封面）

```bash
/Users/qinjianbo/.codex/skills/wechat-mp-article-manager/.venv/bin/python \
  /Users/qinjianbo/.codex/skills/wechat-mp-article-manager/scripts/wechat_mp_draft_upload.py \
  --input content/posts/xxx.md \
  --cover static/img/cover.png
```

### 4.2 Hugo Markdown（自动封面，默认开启）

如果不传 `--cover/--thumb-media-id`，默认使用文章里的第一张图片作为封面：

```bash
/Users/qinjianbo/.codex/skills/wechat-mp-article-manager/.venv/bin/python \
  /Users/qinjianbo/.codex/skills/wechat-mp-article-manager/scripts/wechat_mp_draft_upload.py \
  --input content/posts/xxx.md
```

### 4.3 HTML 文件

```bash
/Users/qinjianbo/.codex/skills/wechat-mp-article-manager/.venv/bin/python \
  /Users/qinjianbo/.codex/skills/wechat-mp-article-manager/scripts/wechat_mp_draft_upload.py \
  --input /path/to/article.html \
  --title '自定义标题'
```

## 5. 图片处理开关

### 5.1 远程图片（http/https）

默认：会下载远程图片 → 上传到微信 → 替换为微信图片地址。

如需保留远程图片原链接（不下载不替换）：

```bash
... wechat_mp_draft_upload.py --input ... --no-fetch-remote-images
```

### 5.2 自动封面

默认：开启（第一张图当封面）。

如需强制要求手动封面（必须传 `--cover` 或 `--thumb-media-id`）：

```bash
... wechat_mp_draft_upload.py --input ... --no-auto-cover
```

## 6. 先演练（不真正创建草稿）

```bash
... wechat_mp_draft_upload.py --input ... --dry-run
```

## 7. 输出结果

脚本会输出 JSON，包含：

- `result`：微信 API 返回（成功时通常包含 `media_id`）
- `replaced_images`：原始图片 URL → 微信图片 URL 的映射

