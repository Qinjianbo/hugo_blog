---
title: "Claude 0 元支付脚本传闻复盘：油猴如何篡改接口响应，以及为什么不能信前端"
date: 2026-07-26T13:55:46+08:00
lastmod: 2026-07-26T14:18:00+08:00
author: 胡巴
avatar: /img/avatar.jpeg
categories:
  - 安全
  - 前端
tags:
  - Tampermonkey
  - Userscript
  - Fetch
  - XMLHttpRequest
  - 支付安全
draft: false
description: "围绕 Claude 0 元支付脚本传闻，用一份脱敏的本地演示版油猴脚本讲清接口响应篡改的实现思路、风险边界，以及支付系统该如何做服务端防护。"
---

最近看到一类和“Claude 0 元支付”传闻绑定在一起的油猴脚本：它会在网页加载早期接管 `fetch` 和 `XMLHttpRequest`，把某个接口返回值改成脚本作者想要的内容。这个现象很适合拿来复盘：前端响应能不能被改？改了以后为什么有时看起来“页面状态变了”？支付、订阅、权益这类关键业务为什么不能相信前端返回值？

<!--more-->

先声明：本文仅供学习交流和安全防护讨论。下面保留的是一份**脱敏后的本地演示版完整脚本**，用于解释技术原理，不指向任何真实网站、真实支付接口或第三方服务；也不会提供绕过支付、伪造订阅、薅羊毛、滥用服务的操作步骤。请只在自建测试页、沙箱环境或明确授权的安全测试范围内使用。

## 本地演示版完整脚本

这份脚本保留了原始思路：匹配一个接口路径，拦截 `fetch` 和 `XMLHttpRequest`，把返回给页面业务代码的 JSON 改成 mock 数据。为了避免被用于真实服务滥用，域名、路径和字段都改成了本地演示值。

```javascript
// ==UserScript==
// @name         Local Demo Response Mock
// @namespace    local.demo.response.mock
// @version      1.0.0
// @description  演示如何在本地测试页中改写指定接口响应，仅供学习交流
// @match        http://localhost/*
// @match        http://127.0.0.1/*
// @run-at       document-start
// @grant        none
// @sandbox      raw
// ==/UserScript==

(function () {
  "use strict";

  const TARGET_HOSTS = new Set(["localhost", "127.0.0.1"]);

  const TARGET_PATH =
    /^\/api\/demo\/capabilities\/?$/;

  const MOCK_DATA = {
    experiment_flow: "local_mock"
  };

  const MOCK_BODY = JSON.stringify(MOCK_DATA);
  const MOCK_LENGTH =
    new TextEncoder().encode(MOCK_BODY).byteLength;

  function getTargetUrl(input, method = "GET") {
    try {
      let rawUrl;

      if (typeof input === "string" || input instanceof URL) {
        rawUrl = String(input);
      } else if (input && typeof input.url === "string") {
        rawUrl = input.url;
      } else {
        return null;
      }

      const url = new URL(rawUrl, location.href);

      if (String(method).toUpperCase() !== "GET") {
        return null;
      }

      if (!TARGET_HOSTS.has(url.hostname)) {
        return null;
      }

      if (!TARGET_PATH.test(url.pathname)) {
        return null;
      }

      return url;
    } catch (error) {
      console.error("[Local Mock] URL 解析失败：", error);
      return null;
    }
  }

  function createMockResponse(originalResponse) {
    const headers = new Headers(originalResponse.headers);

    headers.delete("content-length");
    headers.delete("content-encoding");
    headers.delete("etag");
    headers.delete("content-md5");

    headers.set(
      "content-type",
      "application/json; charset=utf-8"
    );
    headers.set("content-length", String(MOCK_LENGTH));
    headers.set("cache-control", "no-store");

    const response = new Response(MOCK_BODY, {
      status: 200,
      statusText: "OK",
      headers
    });

    try {
      Object.defineProperties(response, {
        url: {
          value: originalResponse.url,
          configurable: true
        },
        redirected: {
          value: originalResponse.redirected,
          configurable: true
        },
        type: {
          value: originalResponse.type,
          configurable: true
        }
      });
    } catch (_) {
      // 不影响主体改写
    }

    return response;
  }

  const nativeFetch = window.fetch;

  window.fetch = async function (input, init) {
    const method =
      init?.method ||
      (input instanceof Request ? input.method : "GET");

    const targetUrl = getTargetUrl(input, method);

    const originalResponse =
      await nativeFetch.apply(this, arguments);

    if (!targetUrl) {
      return originalResponse;
    }

    console.warn(
      "[Local Mock] Fetch 响应已改写：",
      targetUrl.href,
      MOCK_DATA
    );

    return createMockResponse(originalResponse);
  };

  const XhrPrototype = XMLHttpRequest.prototype;
  const xhrInfo = new WeakMap();
  const loggedXhrs = new WeakSet();

  const nativeOpen = XhrPrototype.open;
  const nativeSend = XhrPrototype.send;
  const nativeGetResponseHeader =
    XhrPrototype.getResponseHeader;
  const nativeGetAllResponseHeaders =
    XhrPrototype.getAllResponseHeaders;

  XhrPrototype.open = function (method, url) {
    let absoluteUrl;

    try {
      absoluteUrl = new URL(
        String(url),
        location.href
      ).href;
    } catch (_) {
      absoluteUrl = String(url);
    }

    xhrInfo.set(this, {
      method: String(method || "GET").toUpperCase(),
      url: absoluteUrl
    });

    return nativeOpen.apply(this, arguments);
  };

  function getMatchedXhr(xhr) {
    const info = xhrInfo.get(xhr);

    if (
      !info ||
      xhr.readyState !== XMLHttpRequest.DONE
    ) {
      return null;
    }

    return getTargetUrl(info.url, info.method);
  }

  function replaceXhrGetter(propertyName, replacement) {
    const descriptor =
      Object.getOwnPropertyDescriptor(
        XhrPrototype,
        propertyName
      );

    if (
      !descriptor ||
      typeof descriptor.get !== "function" ||
      descriptor.configurable === false
    ) {
      console.warn(
        `[Local Mock] 无法接管 XHR.${propertyName}`
      );
      return;
    }

    const nativeGetter = descriptor.get;

    Object.defineProperty(XhrPrototype, propertyName, {
      ...descriptor,

      get: function () {
        if (!getMatchedXhr(this)) {
          return nativeGetter.call(this);
        }

        return replacement.call(this, nativeGetter);
      }
    });
  }

  replaceXhrGetter(
    "responseText",
    function (nativeGetter) {
      if (
        this.responseType !== "" &&
        this.responseType !== "text"
      ) {
        return nativeGetter.call(this);
      }

      return MOCK_BODY;
    }
  );

  replaceXhrGetter(
    "response",
    function (nativeGetter) {
      if (this.responseType === "json") {
        return {
          experiment_flow: "local_mock"
        };
      }

      if (
        this.responseType === "" ||
        this.responseType === "text"
      ) {
        return MOCK_BODY;
      }

      return nativeGetter.call(this);
    }
  );

  replaceXhrGetter("status", function () {
    return 200;
  });

  replaceXhrGetter("statusText", function () {
    return "OK";
  });

  XhrPrototype.getResponseHeader = function (name) {
    if (!getMatchedXhr(this)) {
      return nativeGetResponseHeader.apply(
        this,
        arguments
      );
    }

    switch (String(name).toLowerCase()) {
      case "content-type":
        return "application/json; charset=utf-8";

      case "content-length":
        return String(MOCK_LENGTH);

      case "cache-control":
        return "no-store";

      case "content-encoding":
      case "etag":
      case "content-md5":
        return null;

      default:
        return nativeGetResponseHeader.apply(
          this,
          arguments
        );
    }
  };

  XhrPrototype.getAllResponseHeaders = function () {
    const originalHeaders =
      nativeGetAllResponseHeaders.apply(this, arguments);

    if (!getMatchedXhr(this)) {
      return originalHeaders;
    }

    const headers = String(originalHeaders || "")
      .split(/\r?\n/)
      .filter(Boolean)
      .filter(function (line) {
        const name = line
          .split(":", 1)[0]
          .trim()
          .toLowerCase();

        return ![
          "content-type",
          "content-length",
          "content-encoding",
          "cache-control",
          "etag",
          "content-md5"
        ].includes(name);
      });

    headers.push(
      "content-type: application/json; charset=utf-8",
      `content-length: ${MOCK_LENGTH}`,
      "cache-control: no-store"
    );

    return headers.join("\r\n") + "\r\n";
  };

  XhrPrototype.send = function () {
    this.addEventListener(
      "readystatechange",
      function () {
        const targetUrl = getMatchedXhr(this);

        if (targetUrl && !loggedXhrs.has(this)) {
          loggedXhrs.add(this);

          console.warn(
            "[Local Mock] XHR 响应已改写：",
            targetUrl.href,
            MOCK_DATA
          );
        }
      }
    );

    return nativeSend.apply(this, arguments);
  };

  function showStatusBadge() {
    if (!document.documentElement) {
      document.addEventListener(
        "DOMContentLoaded",
        showStatusBadge,
        { once: true }
      );
      return;
    }

    if (document.getElementById("local-mock-badge")) {
      return;
    }

    const badge = document.createElement("div");
    badge.id = "local-mock-badge";
    badge.textContent = "Local Mock ON";
    badge.style.cssText = [
      "position:fixed",
      "right:12px",
      "bottom:12px",
      "z-index:2147483647",
      "padding:6px 10px",
      "font:12px/1.4 system-ui, sans-serif",
      "color:#fff",
      "background:#1f6feb",
      "border-radius:6px",
      "box-shadow:0 2px 8px rgba(0,0,0,.2)"
    ].join(";");

    document.documentElement.appendChild(badge);
  }

  showStatusBadge();
})();
```

## 执行步骤：脚本如何一步步生效

这类脚本的运行路径可以拆成 7 步。

1. 浏览器打开匹配页面，例如 `http://localhost/`。
2. Tampermonkey 根据 `@match` 判断脚本应该注入。
3. 因为设置了 `@run-at document-start`，脚本会尽量在页面业务代码执行前运行。
4. 脚本保存原生的 `window.fetch`、`XMLHttpRequest.prototype.open`、`send`、`getResponseHeader` 等方法。
5. 脚本用自己的包装函数替换这些入口。
6. 页面业务代码正常发起接口请求时，包装函数检查请求是否命中目标路径。
7. 命中目标后，真实请求仍然可以发出，但返回给页面业务代码的响应对象会被替换成 `MOCK_DATA`。

关键点在第 7 步：脚本改的是“页面 JavaScript 拿到的响应”，不是服务端数据库里的真实状态，也不是支付服务商里的真实交易。

## 元数据区域解释

脚本开头的注释块是 Userscript 元数据。

```javascript
// @match        http://localhost/*
// @match        http://127.0.0.1/*
// @run-at       document-start
// @grant        none
// @sandbox      raw
```

`@match` 决定脚本在哪些页面运行。演示版只允许本机地址，避免影响真实网站。

`@run-at document-start` 决定注入时机。越早运行，越有机会在页面业务代码保存 `fetch` 或 XHR 引用之前完成接管。

`@grant none` 表示脚本不使用 Tampermonkey 的特殊扩展 API，直接在页面环境里处理普通 Web API。

`@sandbox raw` 的目的是尽量让脚本贴近页面原始运行环境。不同浏览器和脚本管理器版本对 sandbox 的处理会有差异，真实调试时要以当前环境为准。

## URL 匹配逻辑解释

`getTargetUrl()` 是整段脚本的过滤器。

它主要做四件事：

- 从 `fetch(input, init)` 或 XHR 的 `open(method, url)` 中取出 URL。
- 用 `new URL(rawUrl, location.href)` 把相对路径转成绝对路径。
- 只允许 `GET` 请求命中，避免误改写提交类请求。
- 只允许指定 host 和指定 path 命中。

演示版目标路径是：

```javascript
const TARGET_PATH =
  /^\/api\/demo\/capabilities\/?$/;
```

这意味着只有下面这种请求会被改写：

```text
GET http://localhost/api/demo/capabilities
```

其他接口、其他方法、其他域名都会原样返回。

## Fetch 拦截解释

Fetch 部分的核心是保存原函数，再替换成包装函数。

```javascript
const nativeFetch = window.fetch;

window.fetch = async function (input, init) {
  const targetUrl = getTargetUrl(input, method);
  const originalResponse =
    await nativeFetch.apply(this, arguments);

  if (!targetUrl) {
    return originalResponse;
  }

  return createMockResponse(originalResponse);
};
```

这里有两个容易忽略的细节。

第一，脚本不是阻止真实请求，而是先调用 `nativeFetch`。所以服务端仍然会收到请求，网络面板里也可能看到真实响应。

第二，页面业务代码最终拿到的不是 `originalResponse`，而是 `createMockResponse()` 创建的新 `Response`。这就是为什么页面里 `await response.json()` 读到的是 mock 后的数据。

## 为什么要改 Header

`createMockResponse()` 里删除并重设了一些 Header：

- 删除 `content-length`
- 删除 `content-encoding`
- 删除 `etag`
- 删除 `content-md5`
- 设置新的 `content-type`
- 设置新的 `content-length`
- 设置 `cache-control: no-store`

原因很直接：响应体被替换后，旧的长度、压缩方式、校验值和缓存标识可能已经不匹配。为了让页面读取响应时更一致，就需要把这些和 body 强相关的 Header 一起处理。

## XHR 拦截解释

XHR 比 Fetch 麻烦，因为很多字段是只读 getter。脚本采用的策略是：

- 重写 `open()`，记录 method 和 URL。
- 在 `send()` 中监听 `readystatechange`，等请求完成后再判断是否命中。
- 用 `Object.defineProperty()` 替换 `responseText`、`response`、`status`、`statusText` 的 getter。
- 重写 `getResponseHeader()` 和 `getAllResponseHeaders()`，让 Header 与 mock body 保持一致。

`WeakMap` 用来保存每个 XHR 实例对应的请求信息：

```javascript
const xhrInfo = new WeakMap();
```

这样不会把 XHR 对象强行留在内存里，实例释放时相关记录也可以被垃圾回收。

`WeakSet` 用来避免同一个 XHR 多次打印日志：

```javascript
const loggedXhrs = new WeakSet();
```

因为 `readystatechange` 会触发多次，如果不去重，控制台会重复输出。

## 为什么这种脚本看起来能改变页面状态

很多前端应用会把接口响应直接映射成 UI 状态。比如接口返回 `flow: "a"`，页面进入 A 流程；接口返回 `flow: "b"`，页面进入 B 流程。

这类脚本正是利用了这个机制：它让页面业务代码以为接口返回了另一个值，于是页面展示、按钮、表单或流程状态发生变化。

但这只说明前端状态被影响了，不代表后端业务事实发生了变化。支付、订阅、会员权益、订单完成这类关键状态，必须以服务端可信数据为准。

## 支付场景里真正应该防什么

如果你是业务方或开发者，看到这类脚本，重点不是和脚本在前端斗智斗勇，而是确认关键链路有没有把信任边界放对。

需要重点检查：

- 订单金额、币种、地区、税费、优惠、支付方式是否只由服务端计算
- 前端传入的 plan、checkout flow、country、payment method 是否都被服务端重新校验
- 支付成功是否只认支付渠道的服务端回调或服务端主动查询结果
- 权益发放是否绑定已支付订单，而不是绑定浏览器返回的某个字段
- 回调处理是否有签名校验、幂等控制、金额核对和状态机约束
- 异常订单是否进入风控、人工审核或延迟发放流程

OWASP 的输入校验原则也适用于这里：所有来自客户端的数据都应该被视为不可信输入。即使它看起来来自你自己的网页，也可能已经被浏览器扩展、代理、脚本或自动化工具改写过。

## 怎么做防护更实际

前端可以做一些检测，比如检查关键函数是否被 monkey patch、记录异常网络行为、识别自动化痕迹。但这些只能作为风控信号，不能作为唯一防线。

更可靠的做法是把关键判断放在服务端：

1. 结账会话由服务端创建，服务端保存不可由前端覆盖的订单快照。
2. 支付方式、地区、币种、金额、折扣都在服务端做白名单和一致性校验。
3. 支付完成只接受支付服务商的可信回调，或由服务端调用支付服务商 API 查询。
4. 权益发放走订单状态机，只允许从 `paid`、`settled` 等可信状态进入。
5. 对高风险组合做风控，例如地区异常、支付方式异常、短时间批量尝试、失败后快速切换参数等。
6. 日志里保留 checkout session、payment intent、用户、设备、IP、风控结果之间的关联，方便追溯。

这套思路的核心是：不要试图让前端变得不可篡改，而是让前端篡改无法改变最终账务和权益结果。

## 适用场景

这篇文章适合下面几类人阅读：

- 想理解 Userscript 为什么能影响页面接口响应
- 想排查前端状态和服务端状态不一致的问题
- 正在做订阅、支付、会员权益、优惠券系统的开发者
- 想从安全角度复盘“客户端不可信”这条原则

## 注意事项

- 不要在真实网站上使用脚本尝试绕过支付或订阅限制。
- 不要传播可直接用于滥用第三方服务的脚本和操作步骤。
- 本地研究应使用自建测试环境、沙箱支付环境或明确授权的安全测试范围。
- 如果发现真实服务存在支付校验问题，应通过负责任披露渠道反馈。

## 参考资料

- Tampermonkey Documentation：Userscript 元数据、运行时机和脚本 API
- MDN Web Docs：Fetch API
- MDN Web Docs：XMLHttpRequest
- OWASP Cheat Sheet Series：Input Validation Cheat Sheet

## 一句话总结

油猴脚本可以改变浏览器里“页面看到的响应”，但不应该改变服务端的真实订单、支付和权益状态。支付系统的安全边界必须建立在服务端校验、支付渠道可信回调和完整风控链路上，而不是建立在前端页面没有被改写这个假设上。
