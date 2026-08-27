# 全局记忆 — <你的名字/代号> 与 <品牌>

> 本文件是跨工具记忆的唯一事实源（Claude Code / Cursor / Codex CLI / Gemini CLI 通用）。
> 与任何工具的自动记忆冲突时，以本文件为准。
> 记忆总库根目录：<填写总库路径>。
> 注意：入口文件保持瘦身（建议 ≤150 行），深层内容放 projects/ 与 topics/ 按需读取。

## 用户身份
- <填写：姓名/代号、角色、品牌（私有信息仅保留在本文件，公开仓库勿写入）>

## 技术偏好（跨项目通用）
- 语言：<填写>
- 前端/框架：<填写>
- 代码风格：<填写>
- 数据库：<填写>
- 构建要求：<填写>
- 部署形态：<填写>

## 协作原则
- 分析风格：<填写>
- 输出偏好：<填写>
- 迭代节奏：<填写>

## 禁止事项（全局）
- <填写自己的红线，例如：不生成 mock 数据、不自动群发、版本号纪律>

## 记忆总库使用规则
1. 涉及具体项目的背景时，先读 `projects/<项目>.md`
2. 跨项目决策查 `topics/decisions.md`；可复用打法查 `topics/patterns.md`
3. 新项目建档：复制 `templates/project.template.md` 填写，然后运行同步脚本
4. 项目档案的权威版 = `projects/<项目>.md`；各项目根目录的 AGENTS.md 是自动同步的副本，勿手改
5. 工具自动记忆与本总库冲突时，以总库为准；发现总库过时则更新总库
6. 多会话协作：开始先读项目根 HANDOFF.md、结束前更新（模板：templates/HANDOFF.template.md）
7. 需求与立项：对话中产出 spec（模板：templates/spec.template.md），批准后执行者才动工

## 总库目录
- projects/<项目>.md — <一句话描述>
- topics/decisions.md — 跨项目关键决策日志
- topics/patterns.md — 可复用打法
- templates/ — 建档/交接/spec 模板
