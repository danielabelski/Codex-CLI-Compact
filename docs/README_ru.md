<div align="center">

# GrapeRoot

### Накапливающийся контекст для ИИ-ассистентов разработки

**[graperoot.dev](https://graperoot.dev)** · [Docs](https://graperoot.dev/docs) · [Benchmarks](https://graperoot.dev/benchmarks) · [Pro](https://graperoot.dev/graperoot-pro) · [Discord](https://discord.com/invite/YwKdQATY2d)

[![PyPI](https://img.shields.io/pypi/v/graperoot?label=version&color=brightgreen)](https://pypi.org/project/graperoot/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](#install)
[![Discord](https://img.shields.io/badge/Discord-community-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/YwKdQATY2d)
[![Stars](https://img.shields.io/github/stars/kunal12203/Codex-CLI-Compact?style=social)](https://github.com/kunal12203/Codex-CLI-Compact/stargazers)

---

🌐 **Читать на своём языке:**
[English](../README.md) · [中文](./README_zh-CN.md) · [Español](./README_es.md) · [हिंदी](./README_hi.md) · [Français](./README_fr.md) · [Deutsch](./README_de.md) · [日本語](./README_ja.md) · [한국어](./README_ko.md) · [Português](./README_pt-BR.md) · [Русский](./README_ru.md) · [العربية](./README_ar.md) · [Türkçe](./README_tr.md) · [Bahasa Indonesia](./README_id.md)

</div>

---

## Что такое GrapeRoot?

GrapeRoot — это open-source **контекстный движок**, который встаёт между вами и вашим ИИ-ассистентом по разработке. Он строит семантический граф вашей кодовой базы — файлы, символы, импорты, цепочки вызовов — и автоматически загружает в каждый запрос именно тот код, который нужен, ещё до того как его увидит ИИ.

Результат: ИИ тратит токены на **рассуждение**, а не на исследование.

```
Вы запускаете: dgc /path/to/project
              ↓
1. Проект сканируется → строится семантический граф (файлы, символы, импорты)
2. Вы задаёте вопрос
3. Граф определяет нужные файлы → упаковывает их в контекст
4. ИИ получает ваш вопрос + уже загруженный нужный код
5. Меньше итераций, меньше токенов, лучше ответы
```

Экономия токенов **накапливается** на протяжении сессии. Граф запоминает, какие файлы читались, редактировались и запрашивались — каждая итерация становится дешевле предыдущей.

---

## Результаты

Протестировано на Python-кодовой базе из 7 762 файлов (Sentry), 30 промптов по реальным инженерным задачам:

| Метрика | Без GrapeRoot | С GrapeRoot | Экономия |
|---------|:-------------:|:-----------:|:--------:|
| Стоимость на промпт | $0.77 | **$0.44** | **на 43% меньше** |
| Прочитано токенов за ход | ~307K | **~76K** | **на 75% меньше** |
| Среднее число ходов на задачу | 16.8 | **10.3** | **на 39% меньше** |
| Качество (оценка) | 78.6 / 100 | **78.7–79.4 / 100** | равное или выше |
| Ценность (качество за доллар) | 1.0× | **1.75×** | **на 75% больше** |

### Экономия по типам задач

Граф читает только нужный фрагмент каждого файла, а не файл целиком. Экономия накапливается на протяжении всей сессии: токен, сэкономленный на ходу 3 из 20, также исключает повторное списание за кэш на каждом следующем ходу.

| Тип задачи | Экономия на чтении токенов | Снижение стоимости |
|------------|:--------------------------:|:-----------------:|
| Простой поиск / один файл | 50–60% | 5–10% |
| Исправление ошибок и отладка | 65–75% | 15–25% |
| Рефакторинг (несколько файлов) | 75–80% | 25–35% |
| Навигация по большой кодовой базе (7k+ файлов) | **80%+** | **до 47%** |

> На больших кодовых базах количество прочитанных токенов за сессию снижается на **68–75%**. Качество остаётся на том же уровне или улучшается — ИИ получает нужные файлы, а не угадывает их.

Полная методология и результаты бенчмарков: [graperoot.dev/benchmarks](https://graperoot.dev/benchmarks)

---

## Поддерживаемые инструменты ИИ

| Инструмент | Команда | Статус |
|------------|---------|--------|
| Claude Code | `dgc` | ✅ Полная поддержка |
| OpenAI Codex CLI | `dg` | ✅ Полная поддержка |
| Cursor | `graperoot . --cursor` | ✅ Полная поддержка |
| Gemini CLI | `graperoot . --gemini` | ✅ Полная поддержка |
| OpenCode | `graperoot . --opencode` / `dgo` | ✅ Полная поддержка |
| GitHub Copilot | `graperoot . --copilot` | ✅ Полная поддержка |
| OpenClaw | `graperoot . --openclaw` | ✅ Полная поддержка |
| Antigravity | `graperoot . --antigravity` | ✅ Полная поддержка |

---

## Поддерживаемые языки программирования

TypeScript · JavaScript · Python · Go · Swift · Rust · Java · Kotlin · Scala · C# · Ruby · PHP

---

## Установка

**macOS / Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main/install.sh | bash
source ~/.zshrc   # или ~/.bashrc / ~/.profile
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

> **Требования:** Python 3.10+, Node.js 18+ и один из поддерживаемых ИИ-инструментов. Установщик определяет отсутствующие компоненты и предлагает установить их автоматически.

---

## Использование

> **Важно:** Всегда используйте `dgc` (а не `claude` напрямую), чтобы MCP-сервер запускался корректно.

### Claude Code

```bash
dgc                                      # сканировать текущую директорию, запустить Claude
dgc /path/to/project                     # сканировать конкретный проект
dgc /path/to/project "fix the login bug" # начать с готового промпта
```

### OpenAI Codex CLI

```bash
dg                              # сканировать текущую директорию
dg /path/to/project             # сканировать конкретный проект
dg /path/to/project "add tests" # начать с готового промпта
```

### Интерактивный выбор (новое в v3.9.99)

```bash
graperoot          # показывает подтверждение директории + выбор инструмента стрелками
graperoot .        # то же самое, выбор из текущей директории
graperoot --version   # вывести текущую версию
graperoot --update    # принудительное самообновление
```

### Все инструменты через `graperoot`

```bash
graperoot . --cursor          # Cursor
graperoot . --gemini          # Gemini CLI
graperoot . --opencode        # OpenCode
graperoot . --copilot         # GitHub Copilot
graperoot . --openclaw        # OpenClaw
graperoot /path --gemini "add tests"   # конкретный проект + промпт
```

### Windows

```powershell
dgc .                          # из директории проекта
dgc "D:\projects\my-app"       # любой диск, любой путь
dg "C:\work\backend"           # Codex CLI
dgc --gemini "D:\projects\app" # Gemini CLI на Windows
```

---

## Как это работает

1. **Сканирование графа** — при первом запуске GrapeRoot извлекает файлы, функции, классы и отношения импортов в локальный граф, хранящийся в `.dual-graph/`.
2. **Извлечение контекста** — при каждом вопросе граф ранжирует наиболее релевантные файлы и упаковывает их в промпт ещё до того, как его увидит ИИ.
3. **Память сессии** — файлы, которые вы читали, редактировали или запрашивали, получают более высокий вес в следующих итерациях. Контекст накапливается.
4. **MCP-инструменты** — ИИ всё ещё может углубляться с помощью граф-осведомлённых инструментов (`graph_read`, `graph_retrieve`, `graph_neighbors`), когда ему нужно исследовать подробнее.

Вся обработка выполняется **локально**. Код не покидает вашу машину.

---

## Данные и файлы

Все данные хранятся в `<project>/.dual-graph/` (автоматически добавляется в `.gitignore`):

| Файл | Описание |
|------|----------|
| `info_graph.json` | Семантический граф: файлы, символы, рёбра |
| `chat_action_graph.json` | Память сессии: чтения, правки, запросы |
| `context-store.json` | Постоянные решения/задачи/факты между сессиями |

Глобальная установка в `~/.dual-graph/`:

| Файл | Описание |
|------|----------|
| `dgc.ps1` / `dg.ps1` | Скрипты запуска (обновляются автоматически) |
| `venv/` | Виртуальное окружение Python |
| `version.txt` | Установленная версия |

---

## Конфигурация

Все параметры опциональны и задаются через переменные окружения:

| Переменная | Значение по умолчанию | Описание |
|------------|-----------------------|----------|
| `DG_HARD_MAX_READ_CHARS` | `4000` | Максимум символов при чтении одного файла |
| `DG_TURN_READ_BUDGET_CHARS` | `18000` | Общий бюджет чтения на одну итерацию |
| `DG_FALLBACK_MAX_CALLS_PER_TURN` | `1` | Максимум резервных grep-вызовов за итерацию |
| `DG_RETRIEVE_CACHE_TTL_SEC` | `900` | TTL кэша извлечения (15 мин) |
| `DG_MCP_PORT` | авто (8080–8099) | Принудительно указать порт MCP-сервера |

---

## Автообновление

Лаунчер проверяет наличие обновлений при каждом запуске и обновляется в фоне автоматически. Чтобы принудительно запустить обновление:
```bash
graperoot --update
```

Текущая версия: **3.10.0**

---

## GrapeRoot Pro

[GrapeRoot Pro](https://graperoot.dev/graperoot-pro) добавляет расширенные возможности для опытных пользователей:

- **Режим исчерпывающих задач** — глубокий многофайловый анализ для сложных рефакторингов
- **Обнаружение мёртвых экспортов** — поиск неиспользуемых экспортов по всей кодовой базе
- **Поиск циклических зависимостей** — обнаружение цепочек кругового импорта
- **Поиск по нескольким репозиториям** — семантический поиск по нескольким проектам одновременно
- **Защита от отмены** — хуки перед выполнением инструментов, защищающие от деструктивных операций

---

## Устранение неполадок

### «MCP Server Connection Failed»

Всегда используйте `dgc` вместо прямого вызова `claude`. `dgc` запускает MCP-сервер автоматически.

```bash
# Решение:
claude mcp remove dual-graph
dgc   # повторно регистрирует всё необходимое
```

### Полное руководство по устранению неполадок

См. [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) или [graperoot.dev/docs](https://graperoot.dev/docs).

---

## Вклад в разработку

Скрипты запуска (`bin/`) распространяются с открытым исходным кодом под лицензией Apache 2.0. Pull request'ы приветствуются — исправления ошибок, поддержка новых ИИ-ассистентов, улучшения установщика, документация.

**Примечание:** Графовый движок (pip-пакет `graperoot`) является проприетарным. Лаунчеры и инструменты в этом репозитории полностью open source.

---

## Сообщество

Есть вопрос, нашли баг или хотите поделиться отзывом?

**[Присоединяйтесь к Discord →](https://discord.com/invite/YwKdQATY2d)**

---

## История звёзд

<a href="https://www.star-history.com/?repos=kunal12203%2FCodex-CLI-Compact&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
 </picture>
</a>

---

## Лицензия

Скрипты запуска и инструменты в этом репозитории: [Apache License 2.0](./LICENSE)

Графовый движок `graperoot` (PyPI): проприетарный. См. [graperoot.dev/graperoot-pro](https://graperoot.dev/graperoot-pro).

---

<div align="center">

Made with ❤️ · [graperoot.dev](https://graperoot.dev) · [Discord](https://discord.com/invite/YwKdQATY2d)

</div>
