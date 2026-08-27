# 可复用打法

> 每条格式：何时用 + 怎么做 + 出处。只收录实际验证过的做法。

## PDF 单页生成（企业介绍 / 交付单页）
- 何时用：需要单页 A4 企业介绍 PDF，中文排版、深色或浅色主题、要求像素级控制版式的交付物
- 怎么做：手写 HTML 模板（body 固定 794×1123px、overflow:hidden）+ Playwright `page.pdf()`（210×297mm、printBackground:true、margin 全 0）；字体走在线字体加载；图片全部用内联 SVG；背景装饰用绝对定位 + 低透明度 + z-index 分层；渲染后校验 `body.scrollHeight === body.clientHeight` 防溢出
- 已知坑：Playwright 全局安装需 `NODE_PATH` 指向全局 node_modules；装饰元素 top/bottom 负值会撑大 scrollHeight 导致溢出
- 出处：forge-ai 系列项目实战验证
