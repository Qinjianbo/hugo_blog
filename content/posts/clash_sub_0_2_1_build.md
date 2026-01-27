---
title: 从 0 到可用：CentOS 服务器搭建 VLESS + Reality，并让 Clash Verge 成功订阅[仅供学习交流，请勿用于违法行为]
date: 2026-01-04T16:21:41+08:00
lastmod: 2026-01-04T16:21:41+08:00
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
  - google
# nolastmod: true
draft: false
---

从 0 到可用：CentOS 服务器搭建 VLESS + Reality，并让 Clash Verge 成功订阅[仅供学习交流，请勿用于违法行为]

<!--more-->

---

# 从 0 到可用：CentOS 服务器搭建 VLESS + Reality，并让 Clash Verge 成功订阅

> 记录一次完整实战：
> **无域名、CentOS、海外服务器（越南）**
> 最终实现：**中国可用 + Clash Verge 成功订阅**

---

## 一、背景与目标

### 背景

* 有一台海外服务器（越南 河内）
* 系统：**CentOS**
* 没有域名
* 希望从中国稳定访问海外
* 使用 **Clash Verge / Clash Meta**

### 目标

* 服务端使用 **Xray**
* 协议：**VLESS + Reality + TCP**
* 端口：443
* 不依赖域名和证书
* 最终得到一个 **Clash 可订阅的 URL**

---

## 二、为什么选择 VLESS + Reality？

对比常见方案：

| 方案                  | 状态              |
| ------------------- | --------------- |
| VMess + WS          | ❌ 易被封           |
| Trojan              | ⚠️ 需要证书         |
| VLESS + TLS         | ⚠️ 需要域名         |
| **VLESS + Reality** | ✅ 无域名 / 抗封 / 稳定 |

Reality 的优势：

* 不需要真实证书
* 使用真实网站 SNI 伪装（如 Cloudflare）
* 在中国网络环境下成功率高

---

## 三、服务器准备（CentOS）

### 1. 防火墙说明

执行：

```bash
firewall-cmd --add-port=443/tcp --permanent
```

如果提示：

```
FirewallD is not running
```

👉 **不是错误**
说明系统未启用 firewalld，端口默认放行，可直接继续。

---

## 四、安装 Xray

使用官方脚本：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh)
```

确认安装成功：

```bash
xray version
```

---

## 五、生成 Reality 密钥（关键）

```bash
xray x25519
```

输出类似：

```text
PrivateKey: xxxxxxxxxxxxxxxxxxxxxxxxx
Password:  yyyyyyyyyyyyyyyyyyyyyyyyy
Hash32:    zzzzzzzzzzz
```

说明：

* **PrivateKey**：服务端用
* **Password**：客户端用（等价于 public key）
* Hash32：不用管

⚠️ 不同版本 Xray 命名可能不是 `PublicKey`，而是 `Password`，但它就是 **pbk**。

---

## 六、配置 Xray（VLESS + Reality）

编辑配置文件：

```bash
nano /usr/local/etc/xray/config.json
```

示例配置（可直接用）：

```json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "你的UUID",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "dest": "www.cloudflare.com:443",
          "serverNames": ["www.cloudflare.com"],
          "privateKey": "你的PrivateKey",
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

生成 UUID：

```bash
cat /proc/sys/kernel/random/uuid
```

---

## 七、验证配置并启动

### 1. 测试配置（非常重要）

```bash
xray run -test -config /usr/local/etc/xray/config.json
```

**无输出 = 配置正确**

### 2. 启动服务

```bash
systemctl restart xray
systemctl enable xray
systemctl status xray
```

### 3. 确认端口监听

```bash
ss -lntp | grep 443
```

看到 xray 在监听即成功。

---

## 八、原始 VLESS 节点（用于客户端）

```text
vless://UUID@服务器IP:443
?encryption=none
&flow=xtls-rprx-vision
&security=reality
&sni=www.cloudflare.com
&fp=chrome
&pbk=你的Password
&sid=abcd
&type=tcp
#Hanoi
```

说明：

* Shadowrocket / sing-box 可直接用
* **Clash 不支持直接导入**

---

## 九、为什么 subconverter 失败？

尝试用 subconverter 转换为 Clash 订阅时：

* 返回 `400 Bad Request`
* 原因：**subconverter 0.9.x 对 VLESS + Reality URI 支持不完整**

👉 最终解决方案：**直接写 Clash Meta（mihomo）原生 YAML**

---

## 十、手写 Clash Meta 订阅 YAML（最终方案）

### 1. 创建订阅文件

```bash
mkdir -p /root/subs
cat > /root/subs/hanoi.yaml <<'YAML'
mixed-port: 7890
allow-lan: true
mode: rule
log-level: info

proxies:
  - name: Hanoi-Reality
    type: vless
    server: 服务器IP
    port: 443
    uuid: UUID
    network: tcp
    tls: true
    udp: true
    flow: xtls-rprx-vision
    servername: www.cloudflare.com
    client-fingerprint: chrome
    reality-opts:
      public-key: 你的Password
      short-id: abcd

proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - Hanoi-Reality
      - DIRECT

rules:
  - MATCH,PROXY
YAML
```

---

## 十一、暴露为订阅链接

### 方式一：测试用（Python）

```bash
cd /root/subs
python3 -m http.server 8080
```

订阅地址：

```
http://服务器IP:8080/hanoi.yaml
```

---

### 方式二：systemd 常驻（推荐）

```bash
cat > /etc/systemd/system/subs-http.service <<'EOF'
[Unit]
Description=Clash Subscription Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/root/subs
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now subs-http
```

---

## 十二、Clash Verge 使用

1. Profiles / 订阅
2. 从 URL 导入
3. 粘贴订阅地址
4. 更新配置
5. 选择 `PROXY`
6. 开启系统代理

🎉 成功连接

---

## 十三、关键踩坑总结

### ❌ 常见错误

* `privateKey` 写成中文占位符
* `pbk` 少一个字符
* shortId 非偶数长度
* 依赖 subconverter 转 Reality
* Clash 用 `target=clash` 而不是原生支持

### ✅ 最稳方案

> **Xray + VLESS + Reality + Clash Meta 原生 YAML**

---

## 十四、结语

这套方案的特点是：

* 无域名
* 抗封锁
* 配置透明、可控
* 非机场、无依赖第三方

非常适合 **自建、学习、长期使用**。

---



<!--qr_code

