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

结合图片和文档撰写一篇n8n如何安装社区节点的文章，在步骤中需要插入图片的位置留出占位`![图片介绍]()`便于后续插入图片。

# chrome debugging

"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0 --user-data-dir="C:\chrome-remote-profile"

## 五、往期推荐

1. [n8n实战之初试牛刀：第一个简单工作流](https://mp.weixin.qq.com/s/NPRjJOlL38w4U9JsBztbtw)
2. [n8n实战之初出茅庐：让AI帮你审代码！N8N+GitLab+Deepseek 自动化智能评审全流程实战](https://mp.weixin.qq.com/s/mNlnqExtW6pKPTJMCEA01A)
3. [AI不再健忘！n8n实现大模型多轮记忆力的实用技巧](https://mp.weixin.qq.com/s/p5iJ6E1RfHHw8EfMkTvjYg)
4. [n8n实战之初露锋芒: 为我打工的数据查询助手](https://mp.weixin.qq.com/s/_de4EMrOXWYc1xcfkx_XNw)
5. [初识n8n节点之 n8n Form Trigger](https://mp.weixin.qq.com/s/bEnKknVj-TumxAPcrQYfAg)