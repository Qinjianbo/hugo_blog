---
title: "用 Claude Code 从零开始撸一个中型全栈项目"
date: 2025-09-10T22:07:55+08:00
lastmod: 2025-09-10T22:07:55+08:00
author: 胡巴
avatar: /img/avatar.jpeg
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/auto/article (42).jpg
categories:
  - claude code
tags:
  - claude code
  - 开发
  - golang
  - 全栈
---

# 实测：能否用 Claude Code 从零开始撸一个中型全栈项目

> **摘要：** 朋友让我帮忙做中型全栈项目，我虽主攻后端，但想到AI如今强大，早闻 `Claude Code` 业内顶尖，索性借此机会实测一番，看它究竟有多强。#AI编程 #ClaudeCode #Golang #Vue #Flutter #全栈开发 #程序员转型 #未来已来

如今的时代已经“**不再是一个人的王者**”，而要学会“**与AI 合作**”，实现“**团队的荣耀**”！

我，作为一个后端打工人，
一直有一个“**全栈梦**”。

今天分享一下：
如何借助 `Claude Code` 实现这个“**梦**”！

---

## 首先考考你：全栈项目需要啥？

✅ 一个后端程序员（Go/Java/Python）  
✅ 一个前端工程师（Vue/React）  
✅ 一个客户端开发（iOS/Android）  
✅ 一个UI设计师（Figma画图）  
✅ 一个运维工程师（部署服务） 
✅ 还有一堆工资、社保、下午茶、团建……💰

 这成本... ...加起来？ 
**在北上广深，月成本轻松20万+，项目周期3个月起步。**

但如今，

`Claude Code` 说：**老板，把他们都开了吧！这些活有我就够了！**

`我`说：好的！但是一个月工资只有 **152 块**！

`Claude Code` 回答： 没问题！

`我`高兴的点了点头！准备指挥 `Claude Code` 开始干活！

## 从一句话需求开始

我给它这样一个需求：

> 我需要做一个在线授课平台，专门用于播放数学老师录制的视频课程，你需要帮我做下面这些事情：
>1. 帮我撰写一份调研文档。
2. 帮我撰写一份项目结构设计文档。
3. 帮我撰写一份项目技术设计文档[后端使用golang，框架使用gin，DB使用MySQL，前端使用Vue + Element UI，客户端使用Flutter]。
4. 帮我撰写一份任务规划文档。

**TIPS:  限定一些自己比较熟悉的技术栈，这样也好维护，当然完全让AI帮你设计也可以。**

然后……  
它就开始写了！

此处省略了 `Claude Code` 工作过程截图：实际是当时没有截图，[手动俏皮😜]！

最终我得到了这样几份文档：

![项目结构设计文档-部分截图](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757493499373-9a4bfeda-fe06-449a-9c44-78340b4ccbc2.png)

![技术架构设计文档-部分截图](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757493545656-de9b2c12-625e-4b51-9d73-009f02ec084b.png)

![技术架构设计文档-表结构-部分截图](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757493593084-6f507293-06d3-43b2-8029-40cffbb12608.png)

![任务规划文档-部分截图](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757493837900-d2f9238e-93db-41ad-8e8c-e5ed76779e3b.png)

---

## 真实开发 —— 它一个人干了三个人的活

有了上面的文档，接着就可以让 `Claude Code` 继续干活了，
我只需输入：
> 请按照项目结构文档、技术架构文档、任务规划文档开始开发！

`Claude Code` 便化身**赛博后端工程师、赛博前端工程师、赛博客户端工程师、赛博项目经理、赛博UI设计师**，开始工作！

### 项目骨架搭起来：

只需几分钟，项目结构目录全建好：

![项目骨架-起初没有这么多](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757501266326-d3c3a654-fbec-444e-9eb9-7dd677f12341.png)

### 🔧 后端：Golang + Gin，它写得比我快！

👉 **我还在查Gin文档，它已经把API写完了。**

![后端handler](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757496315852-4c90d043-7626-43af-b0fd-ee1a0f981743.png)

不但代码工整，而且注释完善：

![接口注释](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757496368558-990873ac-ce80-4813-94f9-e7b1f5ccfca5.png)

后端代码运行流畅：

![go run cmd/server/main.go](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757496466141-be0b6b54-aaeb-4c5e-8fb0-e8075fcd58dc.png)

---

### 💻 Web前端：Vue + Element UI，它比我还会“美”

👉 **我连Element UI都没装，它已经把页面结构搭好了。**

![WEB端-门户网站](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757496557019-3107c292-e1d0-43c6-b3c1-9f10f1ae3424.png)

![WEB端-管理后台](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757497266528-b844c22f-10f6-478a-9a8f-a81c3b7064c0.png)

![claude code 工作截图](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757498905965-4658c44b-6c9e-4fa3-9c86-143027265c77.png)

---

### 📱 客户端：Flutter，它连UI都“画”好了

最离谱的是Flutter部分。[我是flutter小白，完全靠 Claude Code 来做！]

它不仅写了Dart代码，  
还生成了**响应式布局**、**状态管理（Provider）**、**网络请求封装**。

👉 **我连Android Studio都没打开，它已经把App跑起来了。**

![首页](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757496817696-3607dff1-c8f3-497a-8569-2eb5a7b96ef5.jpg)

![注册页](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757496829327-d3444bb0-a771-41d6-886d-2391addca02f.jpg)

![claude code 工作截图](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757498992205-3025cb86-61bf-4a43-85a0-712da311472e.png)

---

## 当然没有这么丝滑

看到这里，小伙伴是不是觉得**太过丝滑**。
没错！当然没有这么丝滑！
这个过程也是一个**循序渐进**的过程，
也会有中断，也会有出错，
但是**大部分交互都是简单的说出你的想法即可**！

我大致做了这几件事：

1. 向 Claude Code 说明我的需求：**我要做一个xxxxxx项目，帮我调研并撰写以下文档**  。
2. 让 Claude Code 调研并撰写**项目调研文档、技术架构文档、开发规划文档、README**。
3. 让 Claude Code **按照规划文档**进行开发。
4. 开发过程中适当让 Claude Code 进行**总结，归档进度**。
5. 继续让 Claude Code 进行**开发、调试**。
6. **手动解决一些问题：如网络问题、工具问题、联调问题**。
7. 循环 3、4、5、6，直到全栈功能完成。

## 最终成果：预计30天上线，三端齐发！

目前到第15天，我手里已经有了：

✅ 后端：Gin API 服务，可本地启动调试，接口完整，测试数据完整。
✅ Web端：Vue管理后台，Vue 网站门户，所有接口已全部调通。
✅ App端：Flutter打包的APK，能在手机上进行安装并登录。

待完成部分：

❌ App端：接口联调完成、兼容性测试、出APK包和IPA包。
❌ 上线部署：后端服务部署、Web端部署

预期成本：

👉  人力成本：**1人/30工作日**
👉  Claude Code 月卡：**￥152** [AI Coding 月卡]

![图片来源于网络](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757491711100-2fabad3c-5172-4aff-90f3-0352c8081f56.jpg)

这成本...以后的牛马可怎么活啊！

![牛马今后怎么办啊](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757497701296-094ac09f-146d-4bae-a425-985fd4e33d39.gif)

---

## “牛马”们会被取代吗？

很多人问我：  
“这不就意味着很多“牛马”要失业了？”

我的答案是：  
**不会被取代，但会被“升级”。**，
就像《宗门里除了我都是卧底》里的陈宁，你也有操纵系统的机会！

`Claude Code` 确实能做**80%**的“工作”，  
但它**不会自己想产品、不会判断商业价值、不会处理复杂架构**。

它更像是——  
**一个永不疲倦、不请假、不抱怨的“赛博牛马”**。

而真正的“牛马”们，  
应该从“敲代码”、“写文档”转向“**定方向、做决策、控风险**”。
**以小投入，快速验证自己的想法**，说不定哪天你也当上了老板！

未来属于——  
**会用AI的赛博老板**，  
而不是**抗拒AI的传统牛马**。

什么？你问我国内AI行不行~
不好意思，我只能说国内的各种AI还不行！
我尝试过Deepseek、Kimi2、Qwen-coder等等国内模型，
它们还是差的有点远的！[**不是我不爱国，只是实事求是**]
我也用过 cursor，这个也还不错，
说到底，还是底层模型有差距！

## 总结

用 Claude Code 辅助一个后端程序员从零写一个全栈项目完全可行！

其他职业我不敢打保票，毕竟开发过程中还是会遇到一些技术问题需要手动解决的！

当然，这个过程中也会有很多坎坷，还是有20%的时间在处理各种问题的！不过能完成80%的工作已经很牛了🐂！

---
## 国内流畅使用 Claude Code 的方案

因为被 Claude Code 封锁，导致国内“玩家”无法尽情使用这款顶级“法宝”！
许多开发者在使用官方服务时频频遭遇账号封禁、速率限制、高昂费用和不稳定连接等问题，严重影响了开发效率与创作体验。

但现在，这一切都已成为过去。

目前我已通过 AI Coding 流畅使用 Claude Code ！

![我的订单](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757499869090-541de06e-e9d3-4a90-bc66-aa6327218d95.png)

AI Coding —— 专为极客打造的 Claude Code 专业加速服务，真正实现 100x 效率提升！

🔥 **推荐你立即注册，解锁你的超级编程伙伴**：  注册即送 3000 积分，免费体验！时效有限，早来早得！
👉 [https://aicoding.sh/i/SQfrhTnW](https://aicoding.sh/i/SQfrhTnW)

让 Claude Code 再也不只是“别人能用”的工具，而是你手中真正的 **效率神器**！

**悄悄告诉你，AI Coding 正在公测 Codex，不久也会正式上线，到时两大顶级助手辅助，不愁梦想不实现！**

通过此链接注册并购买者套餐者，可加下方微信，`另有5%红包返现`！

![](https://hubawechat.oss-cn-hangzhou.aliyuncs.com/1757500166341-ad7d1203-c008-458a-9f00-e9669b58b8b2.jpg)

---

这里是每天进步的`胡巴`，欢迎关注、点赞、转发，这里不仅有技术，还有新知！

---

## 往期推荐

1. [我的第一次挖矿历程：从 0 到成功，RTX 3060 挖矿 ETC 全攻略](https://mp.weixin.qq.com/s/8KYbWaQuzJYMZDbnVujlfA)
2. [3060 显卡挖矿实际利润总结！](https://mp.weixin.qq.com/s/BmUPy2lwmtrbTYSN7GHk1Q)
3. [n8n 实战之初出茅庐：让 AI 帮你审代码！N8N+GitLab+Deepseek 自动化智能评审全流程实战](https://mp.weixin.qq.com/s/mNlnqExtW6pKPTJMCEA01A)
4. [[APP 扫码版]告别手动签到！用 n8n 打造京东自动签到神器](https://mp.weixin.qq.com/s/qc-17vTWclmyJjSnRBUK_Q)


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