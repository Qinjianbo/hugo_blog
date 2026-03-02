---
title: 一次搞定：Caddy + Xray Reality + Clash 订阅共存方案（避坑完整版）
date: 2026-01-04T16:21:41+08:00
lastmod: 2026-03-02T12:00:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/posts/11.jpg
# images:
#   - /img/cover.jpg
categories:
  - clash
tags:
  - clash
  - xray
  - caddy
# nolastmod: true
draft: false
aiSummary: "服务器仅开放 443 端口时，如何让 Caddy 前端、Xray Reality 与 Clash 订阅在同一域名下共存，并规避端口冲突与 systemd 403 问题。"
aiKeyPoints:
  - "Xray 仅监听 127.0.0.1:4430，避免与 Caddy 争抢 443"
  - "Caddy 路由顺序：精准路径在前，SPA 兜底在后"
  - "订阅目录必须放在 /var/www/subs，避免 systemd 权限 403"
faq:
  - q: "这篇文章讲什么？"
    a: "讲解 Caddy、Xray Reality、Clash 订阅在单 443 端口下的共存部署与避坑。"
  - q: "核心难点是什么？"
    a: "端口复用、Caddy 配置顺序，以及 systemd 环境下订阅目录权限。"
---

本文从实战出发，记录服务器仅开放 443 端口时，如何用 Caddy 同时承载前端业务、反向代理 Xray、暴露 Clash 订阅链接，并解决端口冲突、403 权限、systemd 服务差异等问题。

<!--more-->

## 一、背景与目标

已知条件：

- 服务器只开放 `443` 端口，安全组不允许额外对外端口（如 `4430`）
- Caddy 已承载前端业务（`oms.test.to0.site`）
- 需要部署 Xray Reality
- 需要生成 Clash Meta 订阅 YAML，并通过 HTTPS 暴露

目标：

- 在同一域名 `443` 端口下，实现前端业务、Xray、订阅链接共存且互不冲突

## 二、环境信息

- 系统：Linux
- Web 服务：Caddy `2.6.2`
- 代理：Xray `26.2.6`（Reality + VLESS + `xtls-rprx-vision`）
- 客户端：Clash Meta

## 三、第一步：Xray 配置（本地监听，不占 443）

让 Xray 只监听本地 `127.0.0.1:4430`，不对外暴露。

配置文件：`/usr/local/etc/xray/config.json`

```json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 4430,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "c9c21c66-f544-43e3-9547-5b58b0828f23",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "dest": "oms.test.to0.site:443",
          "serverNames": ["oms.test.to0.site"],
          "privateKey": "KJF5tCcZ7CwdJv0CmtrxpXupQ6WbqYzAS_I7EsSTcUs",
          "shortIds": ["abcd"]
        }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom" }
  ]
}
```

重启并开机自启：

```bash
systemctl restart xray
systemctl enable xray
```

## 四、第二步：Caddy 配置（核心是顺序 + 路径）

Caddy 监听 `443`，同时处理三类流量：

- 前端业务
- `/xray*` 反向代理到 `127.0.0.1:4430`
- `/subs/*` 暴露订阅文件

关键规则：

- 精准路径在前，兜底路由在后
- `/subs/*` 和 `/xray*` 必须放在 SPA 兜底之前
- 订阅文件不要放 `/root`（systemd 权限限制）

可用 `Caddyfile`：

```caddyfile
oms.test.to0.site {
  root * /opt/each_hwd/oms-fe/dist

  # API 代理
  handle_path /api/* {
      reverse_proxy 127.0.0.1:9511 {
          header_up Host hyperf-admin.com
          header_up X-Real-IP {remote_host}
      }
  }

  # 静态文件
  handle_path /static/* {
      file_server
  }

  # Clash 订阅
  handle_path /subs/* {
      root * /var/www/subs
      file_server
  }

  # Xray 反向代理
  handle /xray* {
      reverse_proxy 127.0.0.1:4430 {
          header_up Host {host}
          header_up X-Real-IP {remote_host}
      }
  }

  # 根重定向
  redir / /default 302

  # SPA 兜底（必须放最后）
  handle /* {
      @notfound {
          not file
      }
      rewrite @notfound {path}/index.html
      file_server
  }
}
```

## 五、第三步：Clash Meta 订阅 YAML

文件路径：`/var/www/subs/hanoi.yaml`

```yaml
mixed-port: 7890
allow-lan: true
mode: rule
log-level: info

proxies:
  - name: Hanoi-Reality
    type: vless
    server: oms.test.to0.site
    port: 443
    uuid: c9c21c66-f544-43e3-9547-5b58b0828f23
    network: tcp
    tls: true
    udp: true
    flow: xtls-rprx-vision
    servername: oms.test.to0.site
    client-fingerprint: chrome
    reality-opts:
      public-key: iZqNX-v5OnYJIKHHeAWbDcrkTp5wDGGeTtTrLQzxEHg
      short-id: abcd

proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - Hanoi-Reality
      - DIRECT

rules:
  - MATCH,PROXY
```

## 六、第四步：权限与 systemd 403 避坑（重点）

### 1）订阅目录不要放 `/root`

Caddy 以 systemd 运行时，常见 `ProtectSystem=full` 会导致对 `/root` 访问受限，出现 `403 Forbidden`。

建议目录与权限：

```bash
mkdir -p /var/www/subs
mv /root/subs/hanoi.yaml /var/www/subs/
chown -R root:caddy /var/www/subs
chmod -R 755 /var/www/subs
```

### 2）重启 Caddy

```bash
systemctl daemon-reload
systemctl restart caddy
systemctl status caddy
```

## 七、最终可用链接

- 前端业务：`https://oms.test.to0.site`
- Clash 订阅：`https://oms.test.to0.site/subs/hanoi.yaml`
- Xray 流量：同域名 `443` 端口，由 Caddy 按路径转发

## 八、常见问题速查

- Xray 启动失败，提示 443 被占用
  - 原因：与 Caddy 抢占 `443`
  - 解决：Xray 改为监听 `127.0.0.1:4430`

- Caddy 手动启动正常，`systemctl` 下访问订阅 403
  - 原因：systemd 安全限制，无法访问 `/root`
  - 解决：订阅文件迁移到 `/var/www/subs`

- 访问 `/subs` 403
  - 原因：目录权限、路径位置、Caddy 路由顺序问题
  - 解决：目录放 `/var/www`，权限正确，确保 `/subs/*` 在 SPA 兜底前

- Caddy 报错 `transport tcp`
  - 原因：版本或配置语法不匹配
  - 解决：移除该配置，使用兼容写法

## 九、一句话总结

单 443 端口场景下，最稳妥的做法是：`Caddy 对外接入 + Xray 本地监听 + /var/www/subs 静态订阅`，并严格控制 Caddy 路由顺序。

<!--qr_code
