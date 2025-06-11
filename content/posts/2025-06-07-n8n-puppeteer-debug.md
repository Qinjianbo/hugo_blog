---
title: "n8n自动化实战：Chrome调试模式与Puppeteer节点全解析"
date: 2025-06-07T15:25:18+08:00
lastmod: 2025-06-07T15:25:18+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto1/%E5%93%94%E5%93%A9%E5%93%94%E5%93%A9%E4%B8%8A%E6%90%9C%E9%9B%86%E7%9A%84%E7%BE%8E%E5%9B%BE%E8%89%B2%E5%9B%BE_1-1000/22.jpg
categories:
  - 自动化工具
  - n8n
  - puppeteer
  
tags:
  - n8n
  - puppeteer
  - Chrome
  - 自动化
  - 浏览器调试
# nolastmod: true
draft: false
---

# n8n自动化实战：Chrome调试模式与Puppeteer节点全解析

在自动化测试、网页抓取、数据采集等场景中，Puppeteer凭借其强大的浏览器自动化能力成为开发者的利器。而n8n作为可视化自动化平台，通过Puppeteer节点可以无缝集成浏览器操作。但要让n8n的Puppeteer节点真正"驱动"本地Chrome浏览器，首先需要启动Chrome的远程调试模式。本文将手把手教你如何配置，并详细解读一个简单的n8n-puppeteer工作流。

> 本文内容需要安装社区节点 `n8n-nodes-puppeteer`，忘记怎么安装的小伙伴可以参考文章：[n8n之初识社区节点：让你的n8n会的更多](https://mp.weixin.qq.com/s/pTLjwhfUMP3MIm8EZpvP2w)

## 一、Chrome调试模式启动指南

Puppeteer默认会自动下载并使用自带的Chromium，但是由于n8n官方docker镜像中没有Puppeteer所需的环境，所以我们需要给它设置一个外部浏览器执行环境，本篇文章使用的是本地Chrome浏览器的调试模式，其他方案可以参考文档[n8n-nodes-puppeteer](https://www.npmjs.com/package/n8n-nodes-puppeteer)。只需一条命令即可开启Chrome的调试环境：

```bash
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0 --user-data-dir="C:\chrome-remote-profile"
```

- `--remote-debugging-port=9222`：指定调试端口。
- `--remote-debugging-address=0.0.0.0`：允许外部主机访问（如Docker容器内的n8n）。
- `--user-data-dir`：指定用户数据目录，避免与日常浏览器配置冲突。

> **注意**：首次运行会自动创建`C:\chrome-remote-profile`目录。

![Chrome调试模式命令行截图占位](http://mmbiz.qpic.cn/sz_mmbiz_png/WDoGSzqNjyFugXlkIpG7GfukUnibShDBV3yYvB4F3OB1ynkKv5uf65C9ktQiaGTIdhJ7AVsIyuNfoa0XqGXxaDgw/0?from=appmsg)

> **注意**：命令中chrome浏览器可执行文件的位置需要自行替换。

![执行命令后弹出可调试窗口](http://mmbiz.qpic.cn/sz_mmbiz_png/WDoGSzqNjyFugXlkIpG7GfukUnibShDBVGIso63Y4SiaiaJx7ibE5og4LkyrZbOaMrVKzMzTvQ9yoMpvPgCTndkyzQ/0?from=appmsg)

### 获取Puppeteer所需的ws地址

Chrome调试模式启动后，访问 http://localhost:9222/json/version 即可获取WebSocket调试地址（`webSocketDebuggerUrl`），如：

```
ws://localhost:9222/devtools/browser/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

n8n的Puppeteer节点只需将此地址填入`browserWSEndpoint`参数即可。

![ws地址获取页面截图占位](http://mmbiz.qpic.cn/sz_mmbiz_png/WDoGSzqNjyFugXlkIpG7GfukUnibShDBV5Jibiat0S4bakxzE9JS8I1TaUbAO4KGN8delKd67T00OlO2XjyQBUiaDg/0?from=appmsg)

> **注意**：这个调试地址在填入docker中的puppeteer节点时，需要把`localhost`替换为`host.docker.internal`

## 二、puppeteer.json工作流详解

![工作流整体截图](http://mmbiz.qpic.cn/sz_mmbiz_png/WDoGSzqNjyFugXlkIpG7GfukUnibShDBVcghibBfctjvzgBquBBr5ogbMQ03Khjfmeicg3Oe4JAdM9Bu8mpEYpceQ/0?from=appmsg)

本工作流通过n8n的Puppeteer节点，实现了对百度首页的多种自动化操作，包括内容抓取、PDF导出、截图和性能监控。下面逐一解析各节点功能：

### 1. 触发器节点
- **When clicking 'Test workflow'**：手动触发整个流程，便于调试和演示。

### 2. 获取百度首页内容
- **获取百度首页内容**：通过Puppeteer节点访问 https://www.baidu.com/，可用于后续自定义脚本或数据提取。

![获取百度首页内容](http://mmbiz.qpic.cn/sz_mmbiz_png/WDoGSzqNjyFugXlkIpG7GfukUnibShDBVOiceKmAqkRzFhYmia86QOYEglyiaAcsM6a2CKaibpV7H06jAbNgppxBZGQ/0?from=appmsg)

### 3. 导出PDF
- **获取百度首页pdf**：将百度首页渲染为PDF，结果存储在`baidu_pdf_data`属性。
- **Read/Write Files from Disk**：将PDF文件写入本地磁盘，路径为`/home/working/baidu_pdf_data.pdf`。

![](http://mmbiz.qpic.cn/sz_mmbiz_png/WDoGSzqNjyFugXlkIpG7GfukUnibShDBVLnBXfoYq7UhiaULSMUz0BPCOMD12X9nKibSlmCPD9slSb6m7aUPHF9iaA/0?from=appmsg)

![](http://mmbiz.qpic.cn/sz_mmbiz_png/WDoGSzqNjyFugXlkIpG7GfukUnibShDBVsSsTbmibyI0pKMTAxREb2nq6bAicOcqDuDDF30dWwZGdjGjh1G4qmvtw/0?from=appmsg)

![](http://mmbiz.qpic.cn/sz_mmbiz_png/WDoGSzqNjyFugXlkIpG7GfukUnibShDBVp3rHt7RMSE8SQ7VYWdNRJQvtZiajTxfFTlYwTwH2dS7aGkcRZpLSuhA/0?from=appmsg)

![](http://mmbiz.qpic.cn/sz_mmbiz_png/WDoGSzqNjyFugXlkIpG7GfukUnibShDBVsoVrJOfRN9niaXQrzyDHtahfqolpjm8IoTnDSCdq0GWo90bUknTcbJA/0?from=appmsg)

![](http://mmbiz.qpic.cn/sz_mmbiz_png/WDoGSzqNjyFugXlkIpG7GfukUnibShDBVqPynGINFLMNNF4HfWX45jQbaSpFzAvBeLxBQT9JOAgT3ySiaia9Tdx5A/0?from=appmsg)



### 4. 截图功能
- **获取百度首页快照**：对百度首页进行全页截图，结果存储在`baidu_home_screenshoot`属性。
- **Read/Write Files from Disk1**：将截图保存为`/home/working/baidu_home_screenshoot.png`。

> 截图功能与抓取PDF功能类似，这里不再赘述。

### 5. 性能监控脚本
- **一个简单的网页性能监控**：自定义Puppeteer脚本，采集页面Performance Timing指标和资源加载统计，输出关键性能数据和前5个耗时资源。

![n8n puppeteer网页性能监控指标获取](http://mmbiz.qpic.cn/sz_mmbiz_png/WDoGSzqNjyFugXlkIpG7GfukUnibShDBVnX3dZliaAYrFgA4cX1Ge7qC3wTgTBkBgXpYHF84cwvBlzeCviadWEMcw/0?from=appmsg)

> 有了这份指标数据，就可以结合其他节点来对网页性能进行监控了，例如：可以将数据信息整合到ES或Prometheus做成监控图标再增加适当告警。

### 监控脚本代码
```
await $page.goto('https://www.baidu.com', {waitUntil: 'networkidle2'})

// 获取 Performance Timing 指标
const perfTiming = await $page.evaluate(() => {
  const timing = performance.timing;
  return {
      navigationStart: timing.navigationStart,
      domContentLoaded: timing.domContentLoadedEventEnd,
      loadEventEnd: timing.loadEventEnd,
      responseEnd: timing.responseEnd,
      fetchStart: timing.fetchStart,
      domInteractive: timing.domInteractive,
      // 计算常用耗时
      domContentLoadedTime: timing.domContentLoadedEventEnd - timing.navigationStart,
      loadTime: timing.loadEventEnd - timing.navigationStart,
      responseTime: timing.responseEnd - timing.fetchStart,
      domInteractiveTime: timing.domInteractive - timing.navigationStart,
    };
})

// 获取所有资源请求信息
const resources = await $page.evaluate(() =>
  performance.getEntriesByType('resource').map(r => ({
    name: r.name,
    type: r.initiatorType,
    duration: r.duration,
    size: r.transferSize || 0,
  }))
);

// 输出性能数据
console.log('百度首页性能指标：');
console.log(perfTiming);

console.log('\n资源请求统计：');
console.log(`总资源数：${resources.length}`);
const totalSize = resources.reduce((sum, r) => sum + r.size, 0);
console.log(`总资源大小：${(totalSize / 1024).toFixed(2)} KB`);

// 可选：输出前 5 个耗时最长的资源
const top5 = resources.sort((a, b) => b.duration - a.duration).slice(0, 5);
console.log('\n耗时最长的 5 个资源：');
top5.forEach((r, i) => {
  console.log(`${i + 1}. ${r.name} - ${r.duration.toFixed(2)} ms, ${(r.size / 1024).toFixed(2)} KB`);
});

return [{"perfTiming": perfTiming, "totalSize": totalSize, "top5": top5}]
```

### 6. 节点连接关系
- 手动触发器同时启动内容抓取、PDF导出、截图和性能监控。
- PDF和截图节点分别与本地文件写入节点连接，实现自动保存。

## 三、实用建议与常见问题

- **端口冲突**：如9222端口被占用，可更换为其他端口，但需同步修改Puppeteer节点配置。
- **Docker环境**：如n8n运行在Docker中，`browserWSEndpoint`应指向宿主机（如`host.docker.internal`）。
- **权限问题**：确保Chrome和n8n有足够的文件读写权限。

## 四、总结

通过Chrome调试模式与n8n的Puppeteer节点结合，你可以轻松实现浏览器级的自动化操作，无论是网页抓取、内容导出还是性能监控，都能一站式完成。希望本文能帮助你快速上手并玩转n8n自动化！

## 五、往期推荐

1. [n8n实战之初试牛刀：第一个简单工作流](https://mp.weixin.qq.com/s/NPRjJOlL38w4U9JsBztbtw)
2. [n8n实战之初出茅庐：让AI帮你审代码！N8N+GitLab+Deepseek 自动化智能评审全流程实战](https://mp.weixin.qq.com/s/mNlnqExtW6pKPTJMCEA01A)
3. [AI不再健忘！n8n实现大模型多轮记忆力的实用技巧](https://mp.weixin.qq.com/s/p5iJ6E1RfHHw8EfMkTvjYg)
4. [n8n实战之初露锋芒: 为我打工的数据查询助手](https://mp.weixin.qq.com/s/_de4EMrOXWYc1xcfkx_XNw)
5. [初识n8n节点之 n8n Form Trigger](https://mp.weixin.qq.com/s/bEnKknVj-TumxAPcrQYfAg)

工作流下载地址：https://hubawechat.oss-cn-hangzhou.aliyuncs.com/puppeteer.json

<!--qr_code-->

## 捐赠

感谢老板请我喝杯咖啡！Thank you for buying me a coffee!

| WeChat | AliPay | PayPal |
| --- | --- | --- |
| ![wechatpay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/wechat_%E6%94%B6%E6%AC%BE%E7%A0%81.jpg) | ![alipay](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/pay/alipay.jpg) | [PayPal](https://paypal.me/JianboQin?country.x=C2&locale.x=zh_XC) |

### 公众号: 无限递归

![alt 搜索公众号:无限递归](https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/gongzhonghao.jpeg "无限递归")

<!--declare-declare-->

Copyright &copy; 2017 - 2025 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】 