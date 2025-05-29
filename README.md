# 胡巴的博客

## 博客地址

https://www.boboidea.com

## 博客简介

胡巴的博客，记录胡巴的学习历程。

## 维护方式

使用hugo搭建，使用阿里云oss存储图片，使用私有服务器部署。

## 新文章生成命令

```bash
hugo new content posts/文章标题.md
```

## 文章模板路径

```
archetypes/posts.md
```

## Git 操作命令

```bash
# 添加新文章到暂存区
git add content/posts/文章标题.md

# 提交更改
git commit -m "添加新文章：文章标题"

# 推送到远程仓库
git push origin master
```

# n8n 启动命令

docker network create n8n-net

docker volume create n8n_data

docker run -it --rm --name n8n --network n8n-net -p 5678:5678 -e N8N_RUNNERS_ENABLED=true -e  N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true -e TZ=Asia/Shanghai -v n8n_data:/home/node/.n8n -v I:/working:/home/working docker.n8n.io/n8nio/n8n

n8n user-management:reset

密码: Localhost5678

## n8n 内 git 设置安全目录
git config --global --add safe.directory /home/working/hugo_blog

# git 自动处理换行符

git config --global core.autocrlf input


# browserless

docker run -it --rm --name browserless --network n8n-net -p 3000:3000 -e "TOKEN=6R0W53R135510" ghcr.io/browserless/chromium