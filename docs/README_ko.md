<div align="center">

```
 ▄▀▀▀ █▀▀▄ ▄▀▀▄ █▀▀█ █▀▀▀ █▀▀▄ ▄▀▀▄ ▄▀▀▄ ▀█▀
 █ ▀▄ █▄▄▀ █▄▄█ █▄▄█ █▀▀  █▄▄▀ █  █ █  █  █
 ▀▀▀▀ ▀ ▀▀ ▀  ▀ █    ▀▀▀▀ ▀ ▀▀ ▀▀▀▀ ▀▀▀▀  ▀
```

### AI 코딩 어시스턴트를 위한 누적형 컨텍스트 엔진

**[graperoot.dev](https://graperoot.dev)** · [문서](https://graperoot.dev/docs) · [벤치마크](https://graperoot.dev/benchmarks) · [Pro](https://graperoot.dev/graperoot-pro) · [Discord](https://discord.com/invite/YwKdQATY2d)

[![PyPI](https://img.shields.io/pypi/v/graperoot?label=version&color=brightgreen)](https://pypi.org/project/graperoot/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](../LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](#설치)
[![Discord](https://img.shields.io/badge/Discord-community-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/YwKdQATY2d)
[![Stars](https://img.shields.io/github/stars/kunal12203/Codex-CLI-Compact?style=social)](https://github.com/kunal12203/Codex-CLI-Compact/stargazers)

---

🌐 **다른 언어로 읽기:**
[English](../README.md) · [中文](./README_zh-CN.md) · [Español](./README_es.md) · [हिंदी](./README_hi.md) · [Français](./README_fr.md) · [Deutsch](./README_de.md) · [日本語](./README_ja.md) · [한국어](./README_ko.md) · [Português](./README_pt-BR.md) · [Русский](./README_ru.md) · [العربية](./README_ar.md) · [Türkçe](./README_tr.md) · [Bahasa Indonesia](./README_id.md)

</div>

---

## GrapeRoot란?

GrapeRoot는 당신과 AI 코딩 어시스턴트 사이에 위치하는 오픈소스 **컨텍스트 엔진**입니다. 코드베이스의 시맨틱 그래프 — 파일, 심볼, 임포트, 호출 체인 — 를 구축하고, AI가 프롬프트를 받기 전에 정확히 필요한 코드를 미리 로드합니다.

그 결과: AI가 탐색이 아닌 **추론**에 토큰을 사용합니다.

```
실행: dgc /path/to/project
              ↓
1. 프로젝트 스캔 → 시맨틱 그래프 생성 (파일, 심볼, 임포트)
2. 질문 입력
3. 그래프가 관련 파일 식별 → 컨텍스트에 패킹
4. AI가 질문 + 올바른 코드를 미리 받아 처리
5. 더 적은 턴, 더 적은 토큰, 더 나은 답변
```

토큰 절감 효과는 세션 전체에 걸쳐 **복리로 누적**됩니다. 그래프는 어떤 파일이 읽히고, 편집되고, 조회되었는지 기억하여 — 매 턴이 더 저렴해집니다.

---

## 성능 결과

여러 실제 코드베이스(파일 7,700개 이상)와 50개 이상의 엔지니어링 프롬프트로 벤치마크:

| 지표 | GrapeRoot 미사용 | GrapeRoot 사용 |
|------|:----------------:|:--------------:|
| 프롬프트당 비용 | $0.49 | **$0.27** |
| 작업당 평균 턴 수 | 11.7 | **3.5** |
| 평균 응답 시간 | 172s | **124s** |
| 품질 (점수) | 76.6 / 100 | **86.6 / 100** |
| 비용 승률 | — | **10개 프롬프트 중 10개** |

### 작업 유형별 비용 절감

| 작업 유형 | 비용 절감 |
|----------|:--------:|
| 마이그레이션 및 아키텍처 설계 | **최대 81%** |
| 성능 분석 | **최대 80%** |
| 테스트 및 테스트 생성 | **최대 76%** |
| 풀스택 디버깅 | **최대 73%** |
| 기능 개발 | **최대 71%** |
| 코드 설명 및 감사 | **최대 55%** |
| 대규모 코드베이스 (7k+ 파일, 평균) | **평균 43%** |

> 절감 효과는 세션 전반에 걸쳐 **복리로 누적**됩니다 — 3턴에서 절약한 토큰은 이후 모든 턴의 캐시 재청구도 방지합니다. 위의 모든 작업 유형에서 품질은 동등하거나 향상됩니다.

전체 벤치마크 방법론 및 결과: [graperoot.dev/benchmarks](https://graperoot.dev/benchmarks)

---

## 지원되는 AI 도구

| 도구 | 명령어 | 지원 상태 |
|------|--------|----------|
| Claude Code | `dgc` | ✅ 전체 지원 |
| OpenAI Codex CLI | `dg` | ✅ 전체 지원 |
| Cursor | `graperoot . --cursor` | ✅ 전체 지원 |
| Gemini CLI | `graperoot . --gemini` | ✅ 전체 지원 |
| OpenCode | `graperoot . --opencode` / `dgo` | ✅ 전체 지원 |
| GitHub Copilot | `graperoot . --copilot` | ✅ 전체 지원 |
| OpenClaw | `graperoot . --openclaw` | ✅ 전체 지원 |
| Kilocode | `graperoot . --kilocode` | ✅ 전체 지원 |
| MiMo Code | `graperoot . --mimocode` | ✅ 전체 지원 |
| Antigravity | `graperoot . --antigravity` | ✅ 전체 지원 |

---

## 지원 프로그래밍 언어

TypeScript · JavaScript · Python · Go · Swift · Rust · Java · Kotlin · Scala · C# · Ruby · PHP

---

## 설치

**macOS / Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main/install.sh | bash
source ~/.zshrc   # 또는 ~/.bashrc / ~/.profile
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

> **사전 요구사항:** Python 3.10+, Node.js 18+, 그리고 지원되는 AI 도구 중 하나. 인스톨러가 누락된 도구를 감지하고 자동 설치를 제안합니다.

---

## 사용법

> **중요:** MCP 서버가 올바르게 실행되도록 항상 `claude` 대신 `dgc`를 사용하세요.

### Claude Code

```bash
dgc                                      # 현재 디렉터리 스캔, Claude 실행
dgc /path/to/project                     # 특정 프로젝트 스캔
dgc /path/to/project "fix the login bug" # 프롬프트와 함께 시작
```

### OpenAI Codex CLI

```bash
dg                              # 현재 디렉터리 스캔
dg /path/to/project             # 특정 프로젝트 스캔
dg /path/to/project "add tests" # 프롬프트와 함께 시작
```

### 인터랙티브 선택기 (v3.9.99 신기능)

```bash
graperoot          # 디렉터리 확인 + 방향키 도구 선택기 표시
graperoot .        # 동일, 현재 디렉터리에서 선택
graperoot --version   # 현재 버전 출력
graperoot --update    # 강제 자가 업데이트
```

### `graperoot`로 모든 도구 사용

```bash
graperoot . --cursor          # Cursor
graperoot . --gemini          # Gemini CLI
graperoot . --opencode        # OpenCode
graperoot . --copilot         # GitHub Copilot
graperoot . --openclaw        # OpenClaw
graperoot . --kilocode        # Kilocode
graperoot . --mimocode        # MiMo Code
graperoot /path --gemini "add tests"   # 특정 프로젝트 + 프롬프트
```

### Windows

```powershell
dgc .                          # 프로젝트 디렉터리 내부에서 실행
dgc "D:\projects\my-app"       # 임의의 드라이브, 임의의 경로
dg "C:\work\backend"           # Codex CLI
dgc --gemini "D:\projects\app" # Windows에서 Gemini CLI
```

---

## 작동 원리

1. **그래프 스캔** — 최초 실행 시, GrapeRoot가 파일, 함수, 클래스, 임포트 관계를 추출하여 `.dual-graph/`에 로컬 그래프로 저장합니다.
2. **컨텍스트 검색** — 질문할 때마다 그래프가 가장 관련성 높은 파일의 순위를 매기고 AI에게 전달되기 전 프롬프트에 패킹합니다.
3. **세션 메모리** — 읽히거나 편집되거나 조회된 파일은 이후 턴에서 더 높은 가중치를 받습니다. 컨텍스트가 누적됩니다.
4. **MCP 도구** — AI가 더 깊이 탐색해야 할 때 그래프 인식 도구(`graph_read`, `graph_retrieve`, `graph_neighbors`)를 통해 추가 탐색이 가능합니다.

모든 처리는 **로컬**에서 이루어집니다. 코드는 외부로 전송되지 않습니다.

---

## 데이터 및 파일

모든 데이터는 `<project>/.dual-graph/`에 저장됩니다 (`.gitignore`에 자동 추가):

| 파일 | 설명 |
|------|------|
| `info_graph.json` | 시맨틱 그래프: 파일, 심볼, 엣지 |
| `chat_action_graph.json` | 세션 메모리: 읽기, 편집, 조회 기록 |
| `context-store.json` | 세션 간 지속되는 결정/작업/사실 저장소 |

글로벌 설치 위치 `~/.dual-graph/`:

| 파일 | 설명 |
|------|------|
| `dgc.ps1` / `dg.ps1` | 런처 스크립트 (자동 업데이트) |
| `venv/` | Python 가상 환경 |
| `version.txt` | 설치된 버전 |

---

## 설정

모두 선택 사항이며, 환경 변수로 지정합니다:

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `DG_HARD_MAX_READ_CHARS` | `4000` | 파일 읽기당 최대 문자 수 |
| `DG_TURN_READ_BUDGET_CHARS` | `18000` | 턴당 총 읽기 예산 문자 수 |
| `DG_FALLBACK_MAX_CALLS_PER_TURN` | `1` | 턴당 최대 폴백 grep 호출 횟수 |
| `DG_RETRIEVE_CACHE_TTL_SEC` | `900` | 검색 캐시 TTL (15분) |
| `DG_MCP_PORT` | 자동 (8080–8099) | 특정 MCP 서버 포트 강제 지정 |

---

## 자가 업데이트

런처는 매 실행 시 업데이트를 확인하고 자동으로 자동 업데이트됩니다. 강제 업데이트하려면:
```bash
graperoot --update
```

자동 업데이트를 비활성화하려면:
```bash
graperoot --no-auto-update
```

다시 활성화하려면:
```bash
graperoot --auto-update
```

현재 버전: **3.10.16**

---

## 텔레메트리

GrapeRoot는 버그 수정을 돕기 위해 익명의 충돌 보고서를 수집합니다. 전송되는 정보: 오류 유형, 실패한 단계, OS/Python 버전, GrapeRoot 버전. 절대 전송되지 않는 정보: 코드, 파일 경로, 프로젝트 이름, 개인 데이터.

```bash
graperoot --no-telemetry    # disable
graperoot --telemetry       # re-enable
```

---

## GrapeRoot Pro

[GrapeRoot Pro](https://graperoot.dev/graperoot-pro)는 파워 유저를 위한 고급 기능을 제공합니다:

- **완전 탐색 작업 모드** — 복잡한 리팩터링을 위한 심층 다중 파일 분석
- **사용되지 않는 내보내기 감지** — 코드베이스 전체에서 미사용 export 탐지
- **의존성 순환 탐지기** — 순환 임포트 체인 검출
- **크로스 코드베이스 검색** — 여러 저장소에 걸친 시맨틱 검색
- **실행 취소 보호막** — 파괴적 작업을 보호하는 도구 실행 전 훅

---

## 문제 해결

### "MCP Server Connection Failed"

항상 `claude` 대신 `dgc`를 사용하세요. `dgc`가 MCP 서버를 자동으로 시작합니다.

```bash
# 해결 방법:
claude mcp remove dual-graph
dgc   # 모든 것을 재등록
```

### 전체 문제 해결 가이드

[TROUBLESHOOTING.md](../TROUBLESHOOTING.md) 또는 [graperoot.dev/docs](https://graperoot.dev/docs)를 참조하세요.

---

## 기여하기

런처 스크립트(`bin/`)는 Apache 2.0 라이선스의 오픈 소스입니다. PR 환영 — 버그 수정, 새로운 AI 어시스턴트 지원, 설치 개선, 문서화.

**참고:** 그래프 엔진(`graperoot` pip 패키지)은 독점 소유입니다. 이 저장소의 런처와 도구는 완전한 오픈 소스입니다.

---

## 커뮤니티

질문이 있거나 버그를 발견했거나 피드백을 공유하고 싶으신가요?

**[Discord 참여하기 →](https://discord.com/invite/YwKdQATY2d)**

---

## Star 기록

<a href="https://www.star-history.com/?repos=kunal12203%2FCodex-CLI-Compact&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
 </picture>
</a>

---

## 라이선스

이 저장소의 런처 스크립트 및 도구: [Apache License 2.0](../LICENSE)

`graperoot` 그래프 엔진 (PyPI): 독점 소유. [graperoot.dev/graperoot-pro](https://graperoot.dev/graperoot-pro) 참조.

---

<div align="center">

Made with ❤️ · [graperoot.dev](https://graperoot.dev) · [Discord](https://discord.com/invite/YwKdQATY2d)

</div>
