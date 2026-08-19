<div align="center">

```
 ▄▀▀▀ █▀▀▄ ▄▀▀▄ █▀▀█ █▀▀▀ █▀▀▄ ▄▀▀▄ ▄▀▀▄ ▀█▀
 █ ▀▄ █▄▄▀ █▄▄█ █▄▄█ █▀▀  █▄▄▀ █  █ █  █  █
 ▀▀▀▀ ▀ ▀▀ ▀  ▀ █    ▀▀▀▀ ▀ ▀▀ ▀▀▀▀ ▀▀▀▀  ▀
```

### AIコーディングアシスタントのためのコンテキストエンジン

**[graperoot.dev](https://graperoot.dev)** · [Docs](https://graperoot.dev/docs) · [Benchmarks](https://graperoot.dev/benchmarks) · [Pro](https://graperoot.dev/graperoot-pro) · [Discord](https://discord.com/invite/YwKdQATY2d)

[![PyPI](https://img.shields.io/pypi/v/graperoot?label=version&color=brightgreen)](https://pypi.org/project/graperoot/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](#install)
[![Discord](https://img.shields.io/badge/Discord-community-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/YwKdQATY2d)
[![Stars](https://img.shields.io/github/stars/kunal12203/Codex-CLI-Compact?style=social)](https://github.com/kunal12203/Codex-CLI-Compact/stargazers)

---

🌐 **言語を選択：**
[English](../README.md) · [中文](./README_zh-CN.md) · [Español](./README_es.md) · [हिंदी](./README_hi.md) · [Français](./README_fr.md) · [Deutsch](./README_de.md) · [日本語](./README_ja.md) · [한국어](./README_ko.md) · [Português](./README_pt-BR.md) · [Русский](./README_ru.md) · [العربية](./README_ar.md) · [Türkçe](./README_tr.md) · [Bahasa Indonesia](./README_id.md)

</div>

---

## GrapeRootとは？

GrapeRoot はオープンソースの**コンテキストエンジン**です。あなたとAIコーディングアシスタントの間に入り、コードベースのセマンティックグラフ（ファイル・シンボル・インポート・呼び出しチェーン）を構築して、AIがプロンプトを受け取る前に最適なコードを正確にプリロードします。

その結果、AIはトークンを**推論**に使えるようになり、コード探索に無駄遣いしなくなります。

```
You run: dgc /path/to/project
              ↓
1. Project scanned → semantic graph built (files, symbols, imports)
2. You ask a question
3. Graph identifies the relevant files → packs them into context
4. AI gets your question + the right code already loaded
5. Fewer turns, fewer tokens, better answers
```

トークン削減効果はセッション全体で**複利的に積み上がります**。グラフは読み込んだファイル・編集したファイル・クエリしたファイルを記憶しており、ターンを重ねるほどコストが下がっていきます。

---

## 結果

複数の実際のコードベース（7,700以上のファイル）と50以上のエンジニアリングプロンプトでベンチマーク：

| 指標 | GrapeRoot なし | GrapeRoot あり |
|------|:--------------:|:--------------:|
| プロンプトあたりのコスト | $0.49 | **$0.27** |
| タスクあたりの平均ターン数 | 11.7 | **3.5** |
| 平均応答時間 | 172s | **124s** |
| 品質（スコア） | 76.6 / 100 | **86.6 / 100** |
| コスト勝率 | — | **10プロンプト中10プロンプト** |

### タスクタイプ別のコスト削減

| タスクタイプ | コスト削減 |
|------------|:--------:|
| マイグレーション・アーキテクチャ設計 | **最大 81%** |
| パフォーマンス分析 | **最大 80%** |
| テスト・テスト生成 | **最大 76%** |
| フルスタックデバッグ | **最大 73%** |
| 機能開発 | **最大 71%** |
| コード説明・監査 | **最大 55%** |
| 大規模コードベース（7k+ファイル、平均） | **平均 43%** |

> 節約効果はセッション全体で**複利的に積み上がります**——ターン3で回避したトークンは、その後の全ターンでのキャッシュ再請求も回避できます。上記のすべてのタスクタイプで品質は同等以上を維持します。

詳細なベンチマーク方法と結果：[graperoot.dev/benchmarks](https://graperoot.dev/benchmarks)

---

## 対応AIツール

| ツール | コマンド | ステータス |
|--------|---------|--------|
| Claude Code | `dgc` | ✅ 完全サポート |
| OpenAI Codex CLI | `dg` | ✅ 完全サポート |
| Cursor | `graperoot . --cursor` | ✅ 完全サポート |
| Gemini CLI | `graperoot . --gemini` | ✅ 完全サポート |
| OpenCode | `graperoot . --opencode` / `dgo` | ✅ 完全サポート |
| GitHub Copilot | `graperoot . --copilot` | ✅ 完全サポート |
| OpenClaw | `graperoot . --openclaw` | ✅ 完全サポート |
| Kilocode | `graperoot . --kilocode` | ✅ 完全サポート |
| MiMo Code | `graperoot . --mimocode` | ✅ 完全サポート |
| Antigravity | `graperoot . --antigravity` | ✅ 完全サポート |

---

## 対応プログラミング言語

TypeScript · JavaScript · Python · Go · Swift · Rust · Java · Kotlin · Scala · C# · Ruby · PHP

---

## インストール

**macOS / Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main/install.sh | bash
source ~/.zshrc   # or ~/.bashrc / ~/.profile
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main/install.ps1 | iex
```

**Windows (Scoop):**
```powershell
scoop bucket add dual-graph https://github.com/kunal12203/scoop-dual-graph
scoop install dual-graph
```

> **前提条件：** Python 3.10+、Node.js 18+、および対応AIツールのいずれか。インストーラーが不足しているツールを検出し、自動インストールを提案します。

---

## 使い方

> **重要：** MCPサーバーを確実に起動するため、`claude` を直接使わず常に `dgc` を使用してください。

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

### インタラクティブピッカー（v3.9.99で新登場）

```bash
graperoot          # shows directory confirm + arrow-key tool picker
graperoot .        # same, picks from current directory
graperoot --version   # print current version
graperoot --update    # force self-update
```

### `graperoot` で全ツールを起動

```bash
graperoot . --cursor          # Cursor
graperoot . --gemini          # Gemini CLI
graperoot . --opencode        # OpenCode
graperoot . --copilot         # GitHub Copilot
graperoot . --openclaw        # OpenClaw
graperoot . --kilocode        # Kilocode
graperoot . --mimocode        # MiMo Code
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

## 仕組み

1. **グラフスキャン** — 初回実行時に、GrapeRoot はファイル・関数・クラス・インポート関係を `.dual-graph/` に保存されたローカルグラフとして抽出します。
2. **コンテキスト取得** — 質問のたびにグラフが最も関連性の高いファイルをランキングし、AIがプロンプトを受け取る前にそれらをコンテキストへパックします。
3. **セッションメモリ** — 読み込み・編集・クエリしたファイルは以降のターンで優先度が上がります。コンテキストが複利的に蓄積されます。
4. **MCPツール** — AIはさらに深く探索が必要な場合、グラフ対応のツール（`graph_read`、`graph_retrieve`、`graph_neighbors`）を利用できます。

処理はすべて**ローカル**で行われます。コードがマシン外に出ることはありません。

---

## データとファイル

すべてのデータは `<project>/.dual-graph/` に保存されます（`.gitignore` に自動追加）：

| ファイル | 説明 |
|----------|------|
| `info_graph.json` | セマンティックグラフ：ファイル・シンボル・エッジ |
| `chat_action_graph.json` | セッションメモリ：読み込み・編集・クエリ履歴 |
| `context-store.json` | セッション横断の決定事項・タスク・事実を永続化 |

グローバルインストール先 `~/.dual-graph/`：

| ファイル | 説明 |
|----------|------|
| `dgc.ps1` / `dg.ps1` | ランチャースクリプト（自動更新） |
| `venv/` | Python仮想環境 |
| `version.txt` | インストール済みバージョン |

---

## 設定

すべて任意の環境変数で設定できます：

| 変数 | デフォルト | 説明 |
|------|-----------|------|
| `DG_HARD_MAX_READ_CHARS` | `4000` | ファイル読み込みの最大文字数 |
| `DG_TURN_READ_BUDGET_CHARS` | `18000` | 1ターンあたりの読み込み合計上限 |
| `DG_FALLBACK_MAX_CALLS_PER_TURN` | `1` | 1ターンあたりのフォールバックgrep最大回数 |
| `DG_RETRIEVE_CACHE_TTL_SEC` | `900` | 取得キャッシュのTTL（15分） |
| `DG_MCP_PORT` | auto (8080–8099) | MCPサーバーのポートを固定指定 |

---

## 自動アップデート

ランチャーは起動のたびにアップデートを確認し、サイレントで自動更新します。手動で強制アップデートするには：
```bash
graperoot --update
```

自動アップデートを無効にするには：
```bash
graperoot --no-auto-update
```

再度有効にするには：
```bash
graperoot --auto-update
```

現在のバージョン：**3.10.16**

---

## テレメトリ

GrapeRoot はバグ修正のために匿名のクラッシュレポートを収集します。送信される情報：エラーの種類、失敗したステップ、OS/Pythonバージョン、GrapeRootバージョン。送信されない情報：コード、ファイルパス、プロジェクト名、個人データ。

```bash
graperoot --no-telemetry    # disable
graperoot --telemetry       # re-enable
```

---

## GrapeRoot Pro

[GrapeRoot Pro](https://graperoot.dev/graperoot-pro) はパワーユーザー向けの高度な機能を追加します：

- **徹底的なタスクモード** — 複雑なリファクタリングのための深いマルチファイル分析
- **デッドエクスポート検出** — コードベース全体で使われていないエクスポートを発見
- **依存関係サイクル検出** — 循環インポートチェーンを検出
- **クロスコードベース検索** — 複数のリポジトリをまたいだセマンティック検索
- **アンドゥシールド** — 破壊的な操作を防ぐプレツール実行フック

---

## トラブルシューティング

### 「MCP Server Connection Failed」（MCPサーバー接続失敗）

`claude` を直接使わず、常に `dgc` を使用してください。`dgc` はMCPサーバーを自動起動します。

```bash
# Fix:
claude mcp remove dual-graph
dgc   # re-registers everything
```

### 詳細なトラブルシューティングガイド

[TROUBLESHOOTING.md](./TROUBLESHOOTING.md) または [graperoot.dev/docs](https://graperoot.dev/docs) を参照してください。

---

## コントリビューション

ランチャースクリプト（`bin/`）はApache 2.0ライセンスのオープンソースです。バグ修正・新しいAIアシスタントサポート・インストール改善・ドキュメントなど、PRを歓迎します。

**注意：** グラフエンジン（`graperoot` pipパッケージ）はプロプライエタリです。このリポジトリのランチャーとツールは完全なオープンソースです。

---

## コミュニティ

質問がある、バグを見つけた、フィードバックを共有したい方は：

**[Discordに参加する →](https://discord.com/invite/YwKdQATY2d)**

---

## スター履歴

<a href="https://star-history.dera.page/#kunal12203/GrapeRoot&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://star-history.dera.page/svg?repos=kunal12203/GrapeRoot&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://star-history.dera.page/svg?repos=kunal12203/GrapeRoot&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://star-history.dera.page/svg?repos=kunal12203/GrapeRoot&type=date&legend=top-left" />
 </picture>
</a>

---

## ライセンス

このリポジトリのランチャースクリプトとツール：[Apache License 2.0](./LICENSE)

`graperoot` グラフエンジン（PyPI）：プロプライエタリ。[graperoot.dev/graperoot-pro](https://graperoot.dev/graperoot-pro) を参照してください。

---

<div align="center">

Made with ❤️ · [graperoot.dev](https://graperoot.dev) · [Discord](https://discord.com/invite/YwKdQATY2d)

</div>
