<div align="center">

# GrapeRoot

### Contexto Composto para Assistentes de Codificação com IA

**[graperoot.dev](https://graperoot.dev)** · [Docs](https://graperoot.dev/docs) · [Benchmarks](https://graperoot.dev/benchmarks) · [Pro](https://graperoot.dev/graperoot-pro) · [Discord](https://discord.com/invite/YwKdQATY2d)

[![PyPI](https://img.shields.io/pypi/v/graperoot?label=version&color=brightgreen)](https://pypi.org/project/graperoot/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](#instalacao)
[![Discord](https://img.shields.io/badge/Discord-community-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/YwKdQATY2d)
[![Stars](https://img.shields.io/github/stars/kunal12203/Codex-CLI-Compact?style=social)](https://github.com/kunal12203/Codex-CLI-Compact/stargazers)

---

🌐 **Leia neste idioma:**
[English](../README.md) · [中文](./README_zh-CN.md) · [Español](./README_es.md) · [हिंदी](./README_hi.md) · [Français](./README_fr.md) · [Deutsch](./README_de.md) · [日本語](./README_ja.md) · [한국어](./README_ko.md) · [Português](./README_pt-BR.md) · [Русский](./README_ru.md) · [العربية](./README_ar.md) · [Türkçe](./README_tr.md) · [Bahasa Indonesia](./README_id.md)

</div>

---

## O que é GrapeRoot?

GrapeRoot é um **motor de contexto** open-source que fica entre você e seu assistente de codificação com IA. Ele constrói um grafo semântico do seu projeto — arquivos, símbolos, importações, cadeias de chamada — e carrega exatamente o código certo em cada prompt antes que sua IA o veja.

O resultado: sua IA gasta tokens **raciocínando**, não explorando.

```
Você executa: dgc /caminho/do/projeto
              ↓
1. Projeto escaneado → grafo semântico construído (arquivos, símbolos, importações)
2. Você faz uma pergunta
3. O grafo identifica os arquivos relevantes → os inclui no contexto
4. A IA recebe sua pergunta + o código certo já carregado
5. Menos turnos, menos tokens, respostas melhores
```

A economia de tokens **se acumula** ao longo de uma sessão. O grafo lembra quais arquivos foram lidos, editados e consultados — cada turno fica mais barato.

---

## Resultados

Avaliado em mais de 80 prompts em um aplicativo full-stack real:

| Métrica | Sem GrapeRoot | Com GrapeRoot |
|---------|:-------------:|:-------------:|
| Custo médio por prompt | $0,46 | **$0,27** |
| Turnos médios | 16,8 | **10,3** |
| Tempo médio de resposta | 186s | **134s** |
| Qualidade (pontuada) | 82,7/100 | **87,1/100** |

> Vantagem de custo em **16 de 20** prompts. Qualidade igual ou melhor em todos os níveis de complexidade.

Metodologia completa e resultados do benchmark: [graperoot.dev/benchmarks](https://graperoot.dev/benchmarks)

---

## Ferramentas de IA Suportadas

| Ferramenta | Comando | Status |
|------------|---------|--------|
| Claude Code | `dgc` | ✅ Suporte completo |
| OpenAI Codex CLI | `dg` | ✅ Suporte completo |
| Cursor | `graperoot . --cursor` | ✅ Suporte completo |
| Gemini CLI | `graperoot . --gemini` | ✅ Suporte completo |
| OpenCode | `graperoot . --opencode` / `dgo` | ✅ Suporte completo |
| GitHub Copilot | `graperoot . --copilot` | ✅ Suporte completo |
| OpenClaw | `graperoot . --openclaw` | ✅ Suporte completo |
| Antigravity | `graperoot . --antigravity` | ✅ Suporte completo |

---

## Linguagens Suportadas

TypeScript · JavaScript · Python · Go · Swift · Rust · Java · Kotlin · Scala · C# · Ruby · PHP

---

## Instalação

**macOS / Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main/install.sh | bash
source ~/.zshrc   # ou ~/.bashrc / ~/.profile
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

> **Pré-requisitos:** Python 3.10+, Node.js 18+ e uma das ferramentas de IA suportadas. O instalador detecta ferramentas ausentes e oferece instalá-las automaticamente.

---

## Uso

> **Importante:** Sempre use `dgc` (não `claude` diretamente) para garantir que o servidor MCP esteja em execução.

### Claude Code

```bash
dgc                                      # escaneia o diretório atual, inicia o Claude
dgc /path/to/project                     # escaneia um projeto específico
dgc /path/to/project "fix the login bug" # inicia com um prompt
```

### OpenAI Codex CLI

```bash
dg                              # escaneia o diretório atual
dg /path/to/project             # escaneia um projeto específico
dg /path/to/project "add tests" # inicia com um prompt
```

### Seletor Interativo (novo na v3.9.99)

```bash
graperoot          # exibe confirmação de diretório + seletor de ferramenta por teclas de seta
graperoot .        # igual ao anterior, usa o diretório atual
graperoot --version   # exibe a versão atual
graperoot --update    # força atualização automática
```

### Todas as Ferramentas via `graperoot`

```bash
graperoot . --cursor          # Cursor
graperoot . --gemini          # Gemini CLI
graperoot . --opencode        # OpenCode
graperoot . --copilot         # GitHub Copilot
graperoot . --openclaw        # OpenClaw
graperoot /path --gemini "add tests"   # projeto específico + prompt
```

### Windows

```powershell
dgc .                          # de dentro do diretório do projeto
dgc "D:\projects\my-app"       # qualquer unidade, qualquer caminho
dg "C:\work\backend"           # Codex CLI
dgc --gemini "D:\projects\app" # Gemini CLI no Windows
```

---

## Como Funciona

1. **Escaneamento do grafo** — na primeira execução, o GrapeRoot extrai arquivos, funções, classes e relacionamentos de importação em um grafo local armazenado em `.dual-graph/`.
2. **Recuperação de contexto** — cada vez que você faz uma pergunta, o grafo classifica os arquivos mais relevantes e os inclui no prompt antes que sua IA os veja.
3. **Memória de sessão** — arquivos que você leu, editou ou consultou recebem peso maior nos turnos futuros. O contexto se acumula.
4. **Ferramentas MCP** — sua IA ainda pode explorar mais fundo por meio de ferramentas com consciência de grafo (`graph_read`, `graph_retrieve`, `graph_neighbors`) quando precisar investigar algo.

Todo o processamento é **local**. Nenhum código sai da sua máquina.

---

## Dados e Arquivos

Todos os dados ficam em `<projeto>/.dual-graph/` (adicionado automaticamente ao `.gitignore`):

| Arquivo | Descrição |
|---------|-----------|
| `info_graph.json` | Grafo semântico: arquivos, símbolos, arestas |
| `chat_action_graph.json` | Memória de sessão: leituras, edições, consultas |
| `context-store.json` | Decisões/tarefas/fatos persistentes entre sessões |

Instalação global em `~/.dual-graph/`:

| Arquivo | Descrição |
|---------|-----------|
| `dgc.ps1` / `dg.ps1` | Scripts de lançamento (atualizados automaticamente) |
| `venv/` | Ambiente virtual Python |
| `version.txt` | Versão instalada |

---

## Configuração

Todas opcionais, via variáveis de ambiente:

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `DG_HARD_MAX_READ_CHARS` | `4000` | Máximo de caracteres por leitura de arquivo |
| `DG_TURN_READ_BUDGET_CHARS` | `18000` | Orçamento total de leitura por turno |
| `DG_FALLBACK_MAX_CALLS_PER_TURN` | `1` | Máximo de chamadas de grep fallback por turno |
| `DG_RETRIEVE_CACHE_TTL_SEC` | `900` | TTL do cache de recuperação (15 min) |
| `DG_MCP_PORT` | auto (8080–8099) | Força uma porta específica para o servidor MCP |

---

## Atualização Automática

O launcher verifica atualizações a cada execução e se atualiza silenciosamente. Para forçar uma atualização:
```bash
graperoot --update
```

Versão atual: **3.10.0**

---

## GrapeRoot Pro

O [GrapeRoot Pro](https://graperoot.dev/graperoot-pro) adiciona funcionalidades avançadas para usuários experientes:

- **Modo de tarefa exaustivo** — análise profunda de múltiplos arquivos para refatorações complexas
- **Detecção de exportações mortas** — encontre exportações não utilizadas em todo o projeto
- **Localizador de ciclos de dependência** — detecta cadeias de importação circulares
- **Busca entre projetos** — busca semântica em múltiplos repositórios
- **Escudo de desfazer** — hooks pré-uso de ferramentas que protegem operações destrutivas

---

## Solução de Problemas

### "MCP Server Connection Failed"

Sempre use `dgc` em vez de `claude` diretamente. O `dgc` inicia o servidor MCP automaticamente.

```bash
# Solução:
claude mcp remove dual-graph
dgc   # registra tudo novamente
```

### Guia completo de solução de problemas

Consulte [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) ou [graperoot.dev/docs](https://graperoot.dev/docs).

---

## Contribuição

Os scripts de lançamento (`bin/`) são open source sob Apache 2.0. PRs são bem-vindos — correções de bugs, suporte a novos assistentes de IA, melhorias de instalação, documentação.

**Observação:** O motor de grafo (`graperoot` pip package) é proprietário. Os launchers e ferramentas neste repositório são totalmente open source.

---

## Comunidade

Tem alguma dúvida, encontrou um bug ou quer compartilhar feedback?

**[Entre no Discord →](https://discord.com/invite/YwKdQATY2d)**

---

## Histórico de Estrelas

<a href="https://www.star-history.com/?repos=kunal12203%2FCodex-CLI-Compact&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
 </picture>
</a>

---

## Licença

Scripts de lançamento e ferramentas neste repositório: [Apache License 2.0](./LICENSE)

O motor de grafo `graperoot` (PyPI): proprietário. Consulte [graperoot.dev/graperoot-pro](https://graperoot.dev/graperoot-pro).

---

<div align="center">

Feito com ❤️ · [graperoot.dev](https://graperoot.dev) · [Discord](https://discord.com/invite/YwKdQATY2d)

</div>
