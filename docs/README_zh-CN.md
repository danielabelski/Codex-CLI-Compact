<div align="center">

# GrapeRoot

### 为 AI 编程助手提供复利式上下文

**[graperoot.dev](https://graperoot.dev)** · [文档](https://graperoot.dev/docs) · [基准测试](https://graperoot.dev/benchmarks) · [Pro 版本](https://graperoot.dev/graperoot-pro) · [Discord](https://discord.com/invite/YwKdQATY2d)

[![PyPI](https://img.shields.io/pypi/v/graperoot?label=version&color=brightgreen)](https://pypi.org/project/graperoot/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](#install)
[![Discord](https://img.shields.io/badge/Discord-community-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/YwKdQATY2d)
[![Stars](https://img.shields.io/github/stars/kunal12203/Codex-CLI-Compact?style=social)](https://github.com/kunal12203/Codex-CLI-Compact/stargazers)

---

🌐 **选择你的语言：**
[English](../README.md) · [中文](./README_zh-CN.md) · [Español](./README_es.md) · [हिंदी](./README_hi.md) · [Français](./README_fr.md) · [Deutsch](./README_de.md) · [日本語](./README_ja.md) · [한국어](./README_ko.md) · [Português](./README_pt-BR.md) · [Русский](./README_ru.md) · [العربية](./README_ar.md) · [Türkçe](./README_tr.md) · [Bahasa Indonesia](./README_id.md)

</div>

---

## GrapeRoot 是什么？

GrapeRoot 是一个开源的**上下文引擎**，介于你和 AI 编程助手之间。它为你的代码库构建语义图谱——涵盖文件、符号、导入关系和调用链——并在每次提问前，将最相关的代码精准预加载到提示词中，让 AI 在看到问题时就已拥有所需上下文。

效果是：AI 把 token 用在**推理**上，而不是探索代码上。

```
You run: dgc /path/to/project
              ↓
1. Project scanned → semantic graph built (files, symbols, imports)
2. You ask a question
3. Graph identifies the relevant files → packs them into context
4. AI gets your question + the right code already loaded
5. Fewer turns, fewer tokens, better answers
```

token 节省效果会在整个会话中**持续累积**。图谱会记住哪些文件被读取、编辑和查询过——每一轮对话都会越来越高效。

---

## 测试结果

在多个真实代码库（7,700+ 个文件）和 50+ 个工程提示词上进行基准测试：

| 指标 | 不使用 GrapeRoot | 使用 GrapeRoot |
|------|:---------------:|:--------------:|
| 每条提示费用 | $0.49 | **$0.27** |
| 每个任务平均轮数 | 11.7 | **3.5** |
| 平均响应时间 | 172s | **124s** |
| 质量评分 | 76.6 / 100 | **86.6 / 100** |
| 成本胜率 | — | **10 个提示词中赢得 10 个** |

### 按任务类型划分的成本降低幅度

| 任务类型 | 成本降低 |
|---------|:-------:|
| 迁移与架构设计 | **最高 81%** |
| 性能分析 | **最高 80%** |
| 测试与测试生成 | **最高 76%** |
| 全栈调试 | **最高 73%** |
| 功能开发 | **最高 71%** |
| 代码解释与审计 | **最高 55%** |
| 大型代码库（7k+ 文件，平均） | **平均 43%** |

> 节省效果在整个会话中**持续累积**——在第 3 轮避免的 token，在后续每一轮中也同样免于缓存重计费。所有上述任务类型的质量均持平或提升。

完整基准测试方法与结果：[graperoot.dev/benchmarks](https://graperoot.dev/benchmarks)

---

## 支持的 AI 工具

| 工具 | 命令 | 状态 |
|------|------|------|
| Claude Code | `dgc` | ✅ 完整支持 |
| OpenAI Codex CLI | `dg` | ✅ 完整支持 |
| Cursor | `graperoot . --cursor` | ✅ 完整支持 |
| Gemini CLI | `graperoot . --gemini` | ✅ 完整支持 |
| OpenCode | `graperoot . --opencode` / `dgo` | ✅ 完整支持 |
| GitHub Copilot | `graperoot . --copilot` | ✅ 完整支持 |
| OpenClaw | `graperoot . --openclaw` | ✅ 完整支持 |
| Antigravity | `graperoot . --antigravity` | ✅ 完整支持 |

---

## 支持的编程语言

TypeScript · JavaScript · Python · Go · Swift · Rust · Java · Kotlin · Scala · C# · Ruby · PHP

---

## 安装

**macOS / Linux：**
```bash
curl -sSL https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main/install.sh | bash
source ~/.zshrc   # or ~/.bashrc / ~/.profile
```

**Windows（PowerShell）：**
```powershell
irm https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main/install.ps1 | iex
```

**Windows（Scoop）：**
```powershell
scoop bucket add dual-graph https://github.com/kunal12203/scoop-dual-graph
scoop install dual-graph
```

> **前置要求：** Python 3.10+、Node.js 18+，以及至少一个受支持的 AI 工具。安装程序会自动检测缺失的工具并提示安装。

---

## 使用方式

> **重要提示：** 请始终使用 `dgc`（而非直接使用 `claude`），以确保 MCP 服务器正常运行。

### Claude Code

```bash
dgc                                      # scan current directory, launch Claude
dgc /path/to/project                     # scan a specific project
dgc /path/to/project "fix the login bug" # start with a prompt
```

### OpenAI Codex CLI

```bash
dg                              # scan current directory
dg /path/to/project             # scan a specific project
dg /path/to/project "add tests" # start with a prompt
```

### 交互式选择器（v3.9.99 新增）

```bash
graperoot          # shows directory confirm + arrow-key tool picker
graperoot .        # same, picks from current directory
graperoot --version   # print current version
graperoot --update    # force self-update
```

### 通过 `graperoot` 使用所有工具

```bash
graperoot . --cursor          # Cursor
graperoot . --gemini          # Gemini CLI
graperoot . --opencode        # OpenCode
graperoot . --copilot         # GitHub Copilot
graperoot . --openclaw        # OpenClaw
graperoot /path --gemini "add tests"   # specific project + prompt
```

### Windows

```powershell
dgc .                          # from inside the project directory
dgc "D:\projects\my-app"       # any drive, any path
dg "C:\work\backend"           # Codex CLI
dgc --gemini "D:\projects\app" # Gemini CLI on Windows
```

---

## 工作原理

1. **图谱扫描** — 首次运行时，GrapeRoot 会提取文件、函数、类及导入关系，生成存储在 `.dual-graph/` 目录下的本地图谱。
2. **上下文检索** — 每次提问时，图谱会对最相关的文件进行排序，并在 AI 接收前将它们打包到提示词中。
3. **会话记忆** — 你读取、编辑或查询过的文件在后续轮次中会获得更高权重，上下文持续累积。
4. **MCP 工具** — 当需要深入探索时，AI 仍可通过图谱感知工具（`graph_read`、`graph_retrieve`、`graph_neighbors`）进一步钻取。

所有处理均在**本地**完成，代码不会离开你的机器。

---

## 数据与文件

所有数据存储在 `<project>/.dual-graph/` 目录下（自动添加至 `.gitignore`）：

| 文件 | 说明 |
|------|------|
| `info_graph.json` | 语义图谱：文件、符号、边 |
| `chat_action_graph.json` | 会话记忆：读取、编辑、查询记录 |
| `context-store.json` | 跨会话持久化的决策/任务/事实 |

全局安装位于 `~/.dual-graph/`：

| 文件 | 说明 |
|------|------|
| `dgc.ps1` / `dg.ps1` | 启动脚本（自动更新） |
| `venv/` | Python 虚拟环境 |
| `version.txt` | 已安装版本号 |

---

## 配置

所有配置均为可选，通过环境变量设置：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `DG_HARD_MAX_READ_CHARS` | `4000` | 单文件最大读取字符数 |
| `DG_TURN_READ_BUDGET_CHARS` | `18000` | 每轮总读取字符预算 |
| `DG_FALLBACK_MAX_CALLS_PER_TURN` | `1` | 每轮最大回退 grep 调用次数 |
| `DG_RETRIEVE_CACHE_TTL_SEC` | `900` | 检索缓存有效期（15 分钟） |
| `DG_MCP_PORT` | 自动（8080–8099） | 强制指定 MCP 服务器端口 |

---

## 自动更新

启动脚本每次运行时都会静默检查并自动更新。如需强制更新：
```bash
graperoot --update
```

当前版本：**3.10.0**

---

## GrapeRoot Pro

[GrapeRoot Pro](https://graperoot.dev/graperoot-pro) 为高级用户提供增强功能：

- **深度任务模式** — 针对复杂重构进行深度多文件分析
- **死代码导出检测** — 找出代码库中未被使用的导出项
- **依赖循环检测** — 识别循环导入链
- **跨代码库搜索** — 跨多个仓库进行语义搜索
- **撤销保护** — 在工具调用前通过钩子防止破坏性操作

---

## 故障排查

### "MCP Server Connection Failed"

请始终使用 `dgc` 而非直接使用 `claude`。`dgc` 会自动启动 MCP 服务器。

```bash
# Fix:
claude mcp remove dual-graph
dgc   # re-registers everything
```

### 完整故障排查指南

参见 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) 或 [graperoot.dev/docs](https://graperoot.dev/docs)。

---

## 贡献

启动脚本（`bin/`）以 Apache 2.0 协议开源，欢迎提交 PR——包括修复 bug、新增 AI 工具支持、改进安装流程及完善文档。

**注意：** 图谱引擎（`graperoot` pip 包）为专有软件。本仓库中的启动脚本和工具链完全开源。

---

## 社区

有问题、发现 bug，或想分享反馈？

**[加入 Discord →](https://discord.com/invite/YwKdQATY2d)**

---

## Star 历史

<a href="https://www.star-history.com/?repos=kunal12203%2FCodex-CLI-Compact&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
 </picture>
</a>

---

## 许可证

本仓库中的启动脚本和工具链：[Apache License 2.0](./LICENSE)

`graperoot` 图谱引擎（PyPI）：专有软件。详见 [graperoot.dev/graperoot-pro](https://graperoot.dev/graperoot-pro)。

---

<div align="center">

Made with ❤️ · [graperoot.dev](https://graperoot.dev) · [Discord](https://discord.com/invite/YwKdQATY2d)

</div>
