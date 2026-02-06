# 网站优化流程规范（性能 + GEO + 统计）

面向 Hugo 静态站的可复用流程。目标：性能指标合格 + 统计不丢 + AI 推荐友好。

## 1. 现状盘点
1. 用 Lighthouse / PageSpeed 记录首页与关键页问题清单。
2. 确认 LCP 元素是谁（图片/文本）。
3. 列出第三方脚本（统计、广告、搜索、推送）。
4. 记录构建与部署方式（如 `./deploy.sh`）。

## 2. LCP 优化（首屏）
1. 如果是首屏大图：
   - 禁止延迟加载：`loading="eager"`
   - 提升优先级：`fetchpriority="high"`
   - 使用响应式：`srcset` + `sizes` + `width/height`
   - 在 `<head>` 加 `preload`（仅首页）
2. 图片尺寸必须匹配展示尺寸，避免“过大图”。
3. 若 LCP 为文字，排查阻塞 CSS/JS。

## 3. 关键请求链优化
1. 所有非关键脚本：`defer` 或 `async`。
2. 统计/广告脚本建议延迟到 `load` 或 `requestIdleCallback`。
3. 只在生产环境注入第三方脚本。

## 4. 缓存生命周期（第三方）
1. 外部脚本（如 Google/Doubleclick）TTL 由对方控制。
2. 优化策略：延迟加载、按需加载、避免阻塞首屏。

## 5. 统计代码策略
1. GA/统计代码必须全站统一注入（避免某些页面缺失）。
2. 避免重复加载（动态注入的脚本会出现在 DOM 中属正常现象）。
3. 若延迟加载，说明可能丢失极短停留用户。

## 6. 图片优化（全站）
1. 将首屏图放入 `assets/`，用 Hugo Pipes 输出多尺寸。
2. 通用封面图启用响应式（`srcset`）。
3. 维持 `webp` 优先。

## 7. GEO（面向 AI 推荐）基础
1. 添加：
   - `llms.txt`
   - `ai.txt`
2. 在文档中列出：
   - 站点说明
   - 栏目入口
   - 最新文章
   - 重点文章

## 8. GEO 结构化内容
1. 文章页增加：
   - `aiSummary`
   - `aiKeyPoints`
   - `faq`（FAQPage JSON-LD）
2. `<head>` 加：
   - `meta name="ai:summary"`
   - `meta name="ai:keypoints"`

## 9. 批量生成（可选）
1. 从 `description` 或首段生成 `aiSummary`。
2. 从 `##/###` 标题生成 `aiKeyPoints`。
3. FAQ 固定 2 条（“讲什么 / 适合谁”）。

## 10. 部署与校验
1. 本地构建 `hugo` 无报错。
2. `./deploy.sh` 部署。
3. `curl` 校验：
   - GA/统计脚本存在
   - `llms.txt` / `ai.txt`
   - `ai:summary`/`ai:keypoints`

## 11. 常见问题处理
1. “页面没统计代码”：检查缓存 + 是否走正确模板。
2. “重复 GA”：确认是否同时存在模板注入 + 动态注入。
3. “LCP 仍高”：再次确认 LCP 元素（可能不是 banner）。

---

这份流程可直接迁移到任意 Hugo 站点，只需替换：
- 站点 URL、主题路径、部署方式
- 统计脚本与图片资源路径
