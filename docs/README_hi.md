<div align="center">

```
 ▄▀▀▀ █▀▀▄ ▄▀▀▄ █▀▀█ █▀▀▀ █▀▀▄ ▄▀▀▄ ▄▀▀▄ ▀█▀
 █ ▀▄ █▄▄▀ █▄▄█ █▄▄█ █▀▀  █▄▄▀ █  █ █  █  █
 ▀▀▀▀ ▀ ▀▀ ▀  ▀ █    ▀▀▀▀ ▀ ▀▀ ▀▀▀▀ ▀▀▀▀  ▀
```

### AI Coding Assistants के लिए Compounding Context

**[graperoot.dev](https://graperoot.dev)** · [Docs](https://graperoot.dev/docs) · [Benchmarks](https://graperoot.dev/benchmarks) · [Pro](https://graperoot.dev/graperoot-pro) · [Discord](https://discord.com/invite/YwKdQATY2d)

[![PyPI](https://img.shields.io/pypi/v/graperoot?label=version&color=brightgreen)](https://pypi.org/project/graperoot/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](#install)
[![Discord](https://img.shields.io/badge/Discord-community-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/YwKdQATY2d)
[![Stars](https://img.shields.io/github/stars/kunal12203/Codex-CLI-Compact?style=social)](https://github.com/kunal12203/Codex-CLI-Compact/stargazers)

---

🌐 **इस भाषा में पढ़ें:**
[English](../README.md) · [中文](./README_zh-CN.md) · [Español](./README_es.md) · [हिंदी](./README_hi.md) · [Français](./README_fr.md) · [Deutsch](./README_de.md) · [日本語](./README_ja.md) · [한국어](./README_ko.md) · [Português](./README_pt-BR.md) · [Русский](./README_ru.md) · [العربية](./README_ar.md) · [Türkçe](./README_tr.md) · [Bahasa Indonesia](./README_id.md)

</div>

---

## GrapeRoot क्या है?

GrapeRoot एक open-source **context engine** है जो आपके और आपके AI coding assistant के बीच काम करता है। यह आपके codebase का एक semantic graph बनाता है — files, symbols, imports, call chains — और हर prompt में सही code AI को पहले से दे देता है।

नतीजा: आपका AI tokens **reasoning** में खर्च करता है, खोजबीन में नहीं।

```
आप चलाते हैं: dgc /path/to/project
              ↓
1. Project scan हुआ → semantic graph बना (files, symbols, imports)
2. आप सवाल पूछते हैं
3. Graph सबसे जरूरी files पहचानता है → उन्हें context में भर देता है
4. AI को आपका सवाल + सही code पहले से मिला हुआ मिलता है
5. कम turns, कम tokens, बेहतर जवाब
```

Token की बचत पूरे session में **compound** होती रहती है। Graph याद रखता है कि कौन सी files पढ़ी गईं, edit की गईं, और query की गईं — हर बार का खर्च कम होता जाता है।

---

## परिणाम

कई वास्तविक codebases (7,700+ फाइलें) और 50+ engineering prompts पर benchmark किया गया:

| मापदंड | GrapeRoot के बिना | GrapeRoot के साथ |
|--------|:-----------------:|:--------------:|
| प्रति prompt लागत | $0.49 | **$0.27** |
| प्रति task औसत turns | 11.7 | **3.5** |
| औसत response time | 172s | **124s** |
| गुणवत्ता (scored) | 76.6 / 100 | **86.6 / 100** |
| लागत जीत दर | — | **10 में से 10 prompts** |

### Task के प्रकार के अनुसार लागत में कमी

| Task का प्रकार | लागत में कमी |
|--------------|:-----------:|
| Migration और architecture design | **81% तक** |
| Performance analysis | **80% तक** |
| Testing और test generation | **76% तक** |
| Full-stack debugging | **73% तक** |
| Feature development | **71% तक** |
| Code explanation और audit | **55% तक** |
| बड़ा codebase (7k+ files, औसत) | **औसत 43%** |

> बचत पूरे session में **compound** होती रहती है — turn 3 पर बचाया गया token, हर बाद के turn में cache re-billing से भी बचाता है। ऊपर दिए गए हर task type में गुणवत्ता बराबर रहती है या सुधरती है।

पूरी benchmark methodology और results: [graperoot.dev/benchmarks](https://graperoot.dev/benchmarks)

---

## समर्थित AI Tools

| Tool | Command | स्थिति |
|------|---------|--------|
| Claude Code | `dgc` | ✅ पूर्ण समर्थन |
| OpenAI Codex CLI | `dg` | ✅ पूर्ण समर्थन |
| Cursor | `graperoot . --cursor` | ✅ पूर्ण समर्थन |
| Gemini CLI | `graperoot . --gemini` | ✅ पूर्ण समर्थन |
| OpenCode | `graperoot . --opencode` / `dgo` | ✅ पूर्ण समर्थन |
| GitHub Copilot | `graperoot . --copilot` | ✅ पूर्ण समर्थन |
| OpenClaw | `graperoot . --openclaw` | ✅ पूर्ण समर्थन |
| Kilocode | `graperoot . --kilocode` | ✅ पूर्ण समर्थन |
| MiMo Code | `graperoot . --mimocode` | ✅ पूर्ण समर्थन |
| Antigravity | `graperoot . --antigravity` | ✅ पूर्ण समर्थन |

---

## समर्थित भाषाएं

TypeScript · JavaScript · Python · Go · Swift · Rust · Java · Kotlin · Scala · C# · Ruby · PHP

---

## इंस्टॉल करें

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

> **आवश्यकताएं:** Python 3.10+, Node.js 18+, और कोई एक समर्थित AI tool। Installer खुद-ब-खुद गायब tools का पता लगाता है और उन्हें install करने का विकल्प देता है।

---

## उपयोग

> **ज़रूरी बात:** MCP server चालू रहे, इसके लिए हमेशा `dgc` इस्तेमाल करें — सीधे `claude` नहीं।

### Claude Code

```bash
dgc                                      # मौजूदा directory scan करें, Claude चालू करें
dgc /path/to/project                     # किसी खास project को scan करें
dgc /path/to/project "fix the login bug" # prompt के साथ शुरू करें
```

### OpenAI Codex CLI

```bash
dg                              # मौजूदा directory scan करें
dg /path/to/project             # किसी खास project को scan करें
dg /path/to/project "add tests" # prompt के साथ शुरू करें
```

### Interactive Picker (v3.9.99 में नया)

```bash
graperoot          # directory confirm + arrow-key tool picker दिखाता है
graperoot .        # वही, मौजूदा directory से
graperoot --version   # मौजूदा version प्रिंट करें
graperoot --update    # जबरदस्ती self-update करें
```

### `graperoot` से सभी Tools

```bash
graperoot . --cursor          # Cursor
graperoot . --gemini          # Gemini CLI
graperoot . --opencode        # OpenCode
graperoot . --copilot         # GitHub Copilot
graperoot . --openclaw        # OpenClaw
graperoot . --kilocode        # Kilocode
graperoot . --mimocode        # MiMo Code
graperoot /path --gemini "add tests"   # खास project + prompt
```

### Windows

```powershell
dgc .                          # project directory के अंदर से
dgc "D:\projects\my-app"       # कोई भी drive, कोई भी path
dg "C:\work\backend"           # Codex CLI
dgc --gemini "D:\projects\app" # Windows पर Gemini CLI
```

---

## यह कैसे काम करता है

1. **Graph scan** — पहली बार चलाने पर, GrapeRoot files, functions, classes, और import relationships को निकालकर `.dual-graph/` में एक local graph बनाता है।
2. **Context retrieval** — हर बार जब आप कोई सवाल पूछते हैं, graph सबसे relevant files को rank करता है और AI तक पहुंचने से पहले उन्हें prompt में भर देता है।
3. **Session memory** — जो files आपने पढ़ी हैं, edit की हैं, या query की हैं, वे अगली बार ज़्यादा weight पाती हैं। Context बढ़ता रहता है।
4. **MCP tools** — जब ज़रूरत हो, आपका AI graph-aware tools (`graph_read`, `graph_retrieve`, `graph_neighbors`) से और गहराई में जा सकता है।

सारी processing **local** है। आपका कोई भी code आपकी machine से बाहर नहीं जाता।

---

## डेटा और फ़ाइलें

सारा डेटा `<project>/.dual-graph/` में रहता है (`.gitignore` में अपने आप जुड़ जाता है):

| फ़ाइल | विवरण |
|------|-------------|
| `info_graph.json` | Semantic graph: files, symbols, edges |
| `chat_action_graph.json` | Session memory: reads, edits, queries |
| `context-store.json` | Sessions के पार persistent decisions/tasks/facts |

Global install `~/.dual-graph/` में:

| फ़ाइल | विवरण |
|------|-------------|
| `dgc.ps1` / `dg.ps1` | Launcher scripts (अपने आप update होते हैं) |
| `venv/` | Python virtual environment |
| `version.txt` | Install किया गया version |

---

## कॉन्फ़िगरेशन

सब कुछ वैकल्पिक है, environment variables के ज़रिए:

| Variable | Default | विवरण |
|----------|---------|-------------|
| `DG_HARD_MAX_READ_CHARS` | `4000` | प्रति file read में अधिकतम characters |
| `DG_TURN_READ_BUDGET_CHARS` | `18000` | प्रति turn कुल read budget |
| `DG_FALLBACK_MAX_CALLS_PER_TURN` | `1` | प्रति turn अधिकतम fallback grep calls |
| `DG_RETRIEVE_CACHE_TTL_SEC` | `900` | Retrieval cache TTL (15 मिनट) |
| `DG_MCP_PORT` | auto (8080–8099) | किसी खास MCP server port को force करें |

---

## स्व-अपडेट

Launcher हर बार चलाने पर updates की जांच करता है और चुपचाप अपने आप update हो जाता है। जबरदस्ती update के लिए:
```bash
graperoot --update
```

Auto-update बंद करने के लिए:
```bash
graperoot --no-auto-update
```

फिर से चालू करने के लिए:
```bash
graperoot --auto-update
```

मौजूदा version: **3.10.16**

---

## टेलीमेट्री

GrapeRoot bugs ठीक करने में मदद के लिए गुमनाम crash reports इकट्ठा करता है। क्या भेजा जाता है: error का प्रकार, कौन सा step fail हुआ, OS/Python version, GrapeRoot version। कभी नहीं भेजा जाता: आपका code, file paths, project names, या व्यक्तिगत डेटा।

```bash
graperoot --no-telemetry    # disable
graperoot --telemetry       # re-enable
```

---

## GrapeRoot Pro

[GrapeRoot Pro](https://graperoot.dev/graperoot-pro) power users के लिए advanced features जोड़ता है:

- **Exhaustive task mode** — जटिल refactors के लिए गहरा multi-file analysis
- **Dead export detection** — पूरे codebase में unused exports खोजें
- **Dependency cycle finder** — circular import chains का पता लगाएं
- **Cross-codebase search** — कई repos में semantic search
- **Undo shield** — destructive operations को बचाने वाले pre-tool-use hooks

---

## समस्या निवारण

### "MCP Server Connection Failed"

`claude` सीधे इस्तेमाल करने की बजाय हमेशा `dgc` का उपयोग करें। `dgc` MCP server को अपने आप शुरू कर देता है।

```bash
# हल:
claude mcp remove dual-graph
dgc   # सब कुछ फिर से register हो जाएगा
```

### पूरी troubleshooting guide

[TROUBLESHOOTING.md](./TROUBLESHOOTING.md) देखें या [graperoot.dev/docs](https://graperoot.dev/docs) पर जाएं।

---

## योगदान

Launcher scripts (`bin/`) Apache 2.0 के तहत open source हैं। Bug fixes, नए AI assistant support, install सुधार, और docs के लिए PRs का स्वागत है।

**नोट:** Graph engine (`graperoot` pip package) proprietary है। इस repo में launchers और tooling पूरी तरह open source हैं।

---

## समुदाय

कोई सवाल है, कोई bug मिला, या feedback देना चाहते हैं?

**[Discord से जुड़ें →](https://discord.com/invite/YwKdQATY2d)**

---

## Star History

<a href="https://star-history.dera.page/#kunal12203/GrapeRoot&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://star-history.dera.page/svg?repos=kunal12203/GrapeRoot&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://star-history.dera.page/svg?repos=kunal12203/GrapeRoot&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://star-history.dera.page/svg?repos=kunal12203/GrapeRoot&type=date&legend=top-left" />
 </picture>
</a>

---

## लाइसेंस

इस repository में launcher scripts और tooling: [Apache License 2.0](./LICENSE)

`graperoot` graph engine (PyPI): proprietary। देखें [graperoot.dev/graperoot-pro](https://graperoot.dev/graperoot-pro)।

---

<div align="center">

Made with ❤️ · [graperoot.dev](https://graperoot.dev) · [Discord](https://discord.com/invite/YwKdQATY2d)

</div>
