# AGENTS.md · 项目级指引（财务大写转换 App）

> 本文件是 **项目级** 指引，仅对本项目生效。opencode 会自动加载。
> 最后更新：2026-06-21

## 项目工作目录
- **项目根目录**：`/Users/yizhiwang/Desktop/opencode/第一个ios项目`
- 项目名：财务大写转换 App（阿拉伯数字 → 中文大写金额）
- **双端**：
  - iOS 项目子目录：`./FinanceNumberConverter/`（阶段 1 后出现）
  - Android 项目子目录：`./android/`（阶段 1 后出现）

## 项目标准文件指引
开始任何任务前，先阅读以下文件（按需）：

### 通用（iOS + Android 共享）
| 文件 | 何时读 |
| --- | --- |
| `./docs/README.md` | 任何时候，作为入口 |
| `./docs/01-需求文档.md` | 任何开发前 |

### iOS 专属
| 文件 | 何时读 |
| --- | --- |
| `./docs/02-技术规范.md` | iOS 代码前 |
| `./docs/03-设计规范.md` | iOS UI 前 |
| `./docs/04-开发执行步骤.md` | **iOS 下一步做什么（重要）** |
| `./docs/05-测试用例.md` | iOS 写测试 & 验收时 |

### Android 专属
| 文件 | 何时读 |
| --- | --- |
| `./android/docs/02-技术规范.md` | Android 代码前 |
| `./android/docs/03-设计规范.md` | Android UI 前 |

## 开发日志工作流
- 路径：
  - iOS 日志：`./dev-logs/YYYY-MM-DD.md`
  - Android 日志：`./android/dev-logs/YYYY-MM-DD.md`
- **每次开发会话结束前**，必须更新对应平台的当日日志
- 模板：`./dev-logs/_template.md` 或 `./android/dev-logs/_template.md`
- 必填 5 段：今日完成 / 进行中 / 明日待办 / 问题与解决 / 想法备注

## Git 工作流
- **远程仓库**：仅本地，不主动 push
- **分支策略**：默认 `main` 单线，暂不用 feature 分支
- **Commit 语言**：**中文**
- **Commit 时机**：每个阶段通过验收后**立即 commit**
- **Commit 格式**：`<类型>(<范围>): <简述>`
- **允许类型**：`docs` / `chore` / `feat` / `test` / `ui` / `fix` / `refactor`
- **严禁**：
  - `--force` / `--no-verify`（除非用户明确要求）
  - 提交 `xcuserdata/` / `DerivedData/` / `.gradle/` / `build/` 等（已通过 `.gitignore` 屏蔽）
  - 在未通过验收时 commit 探索性代码
- **提交前必做**：`git status` + `git diff` 自检

## 工作原则（**最重要**）
1. **严格按 `./docs/04-开发执行步骤.md`（iOS）/ `./android/docs/04-开发执行步骤.md`（Android）推进** — 每阶段通过验收才进入下一阶段
2. **一次只做 1 个原子任务** — 完成并验证后再进下一项
3. **先文档后动手** — 动手前先确认相关文档已读且最新
4. **不越界** — 不在用户未确认的情况下跨阶段或扩大范围
5. **每步停下让用户确认** — 节奏要慢，零基础用户需要看到每一步的成果
6. **优先 AI 生成代码，但关键架构/命名要先 review 再落地**

## ⚠️ 不要做的事
- **不要修改 `~/.config/opencode/AGENTS.md`**（全局文件）
- 所有项目相关指引只放在本文件（项目级 AGENTS.md）
- 任何"顺手"修改其他项目或全局配置的行为，先停下来问用户

## 当前阶段

### iOS
- **阶段 0~7 · 全部完成**（2026-06-20 ~ 2026-06-21）

### Android
- **阶段 0 · 文档先行** — ✅ 已完成（2026-06-21）
- **阶段 1 · Android Studio 工程初始化** — ⏳ 当前进行中
- 下一步动作：按 `./android/docs/04-开发执行步骤.md` 阶段 1 配置（手写所有项目文件）
