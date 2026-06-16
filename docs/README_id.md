<div align="center">

# GrapeRoot

### Konteks Berlipat untuk Asisten Pengkodean AI

**[graperoot.dev](https://graperoot.dev)** · [Docs](https://graperoot.dev/docs) · [Benchmarks](https://graperoot.dev/benchmarks) · [Pro](https://graperoot.dev/graperoot-pro) · [Discord](https://discord.com/invite/YwKdQATY2d)

[![PyPI](https://img.shields.io/pypi/v/graperoot?label=version&color=brightgreen)](https://pypi.org/project/graperoot/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](#install)
[![Discord](https://img.shields.io/badge/Discord-community-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/YwKdQATY2d)
[![Stars](https://img.shields.io/github/stars/kunal12203/Codex-CLI-Compact?style=social)](https://github.com/kunal12203/Codex-CLI-Compact/stargazers)

---

🌐 **Baca dalam bahasa Anda:**
[English](../README.md) · [中文](./README_zh-CN.md) · [Español](./README_es.md) · [हिंदी](./README_hi.md) · [Français](./README_fr.md) · [Deutsch](./README_de.md) · [日本語](./README_ja.md) · [한국어](./README_ko.md) · [Português](./README_pt-BR.md) · [Русский](./README_ru.md) · [العربية](./README_ar.md) · [Türkçe](./README_tr.md) · [Bahasa Indonesia](./README_id.md)

</div>

---

## Apa itu GrapeRoot?

GrapeRoot adalah **mesin konteks** sumber terbuka yang berada di antara Anda dan asisten pengkodean AI Anda. GrapeRoot membangun graf semantik dari basis kode Anda — file, simbol, impor, rantai pemanggilan — lalu memuat tepat kode yang relevan ke setiap prompt sebelum AI Anda menerimanya.

Hasilnya: AI Anda menggunakan token untuk **berpikir**, bukan menjelajahi.

```
Anda menjalankan: dgc /path/to/project
              ↓
1. Proyek dipindai → graf semantik dibangun (file, simbol, impor)
2. Anda mengajukan pertanyaan
3. Graf mengidentifikasi file yang relevan → memuatnya ke dalam konteks
4. AI menerima pertanyaan Anda + kode yang tepat sudah siap
5. Lebih sedikit giliran, lebih sedikit token, jawaban lebih baik
```

Penghematan token **berlipat ganda** sepanjang sesi. Graf mengingat file mana yang telah dibaca, diedit, dan dikueri — setiap giliran semakin hemat.

---

## Hasil

Diuji pada basis kode Python dengan 7.762 file (Sentry), 30 prompt dari tugas rekayasa nyata:

| Metrik | Tanpa GrapeRoot | Dengan GrapeRoot | Penghematan |
|--------|:---------------:|:----------------:|:-----------:|
| Biaya per prompt | $0.77 | **$0.44** | **43% lebih hemat** |
| Token yang dibaca per giliran | ~307K | **~76K** | **75% lebih hemat** |
| Rata-rata giliran per tugas | 16.8 | **10.3** | **39% lebih sedikit** |
| Kualitas (skor) | 78.6 / 100 | **78.7–79.4 / 100** | setara atau lebih baik |
| Nilai (kualitas per dolar) | 1.0× | **1.75×** | **75% lebih tinggi** |

### Penghematan berdasarkan jenis tugas

Graf hanya membaca bagian yang relevan dari setiap file — bukan seluruhnya. Penghematan berlipat ganda sepanjang sesi: token yang dihindari pada giliran 3 dari sesi 20 giliran juga menghindari penagihan ulang cache di setiap giliran berikutnya.

| Jenis tugas | Token yang dibaca dihemat | Pengurangan biaya |
|-------------|:-------------------------:|:-----------------:|
| Pencarian sederhana / satu file | 50–60% | 5–10% |
| Perbaikan bug & debugging | 65–75% | 15–25% |
| Refaktor (multi-file) | 75–80% | 25–35% |
| Navigasi basis kode besar (7k+ file) | **80%+** | **hingga 47%** |

> Pada basis kode besar, pembacaan token turun **68–75% per sesi**. Kualitas tetap setara atau meningkat — AI mendapatkan file yang tepat alih-alih menebak.

Metodologi dan hasil benchmark lengkap: [graperoot.dev/benchmarks](https://graperoot.dev/benchmarks)

---

## Alat AI yang Didukung

| Alat | Perintah | Status |
|------|----------|--------|
| Claude Code | `dgc` | ✅ Dukungan penuh |
| OpenAI Codex CLI | `dg` | ✅ Dukungan penuh |
| Cursor | `graperoot . --cursor` | ✅ Dukungan penuh |
| Gemini CLI | `graperoot . --gemini` | ✅ Dukungan penuh |
| OpenCode | `graperoot . --opencode` / `dgo` | ✅ Dukungan penuh |
| GitHub Copilot | `graperoot . --copilot` | ✅ Dukungan penuh |
| OpenClaw | `graperoot . --openclaw` | ✅ Dukungan penuh |
| Antigravity | `graperoot . --antigravity` | ✅ Dukungan penuh |

---

## Bahasa Pemrograman yang Didukung

TypeScript · JavaScript · Python · Go · Swift · Rust · Java · Kotlin · Scala · C# · Ruby · PHP

---

## Instalasi

**macOS / Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main/install.sh | bash
source ~/.zshrc   # atau ~/.bashrc / ~/.profile
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

> **Prasyarat:** Python 3.10+, Node.js 18+, dan salah satu alat AI yang didukung. Penginstal mendeteksi alat yang belum terpasang dan menawarkan untuk menginstalnya secara otomatis.

---

## Penggunaan

> **Penting:** Selalu gunakan `dgc` (bukan `claude` secara langsung) untuk memastikan server MCP berjalan.

### Claude Code

```bash
dgc                                      # pindai direktori saat ini, jalankan Claude
dgc /path/to/project                     # pindai proyek tertentu
dgc /path/to/project "fix the login bug" # mulai dengan prompt
```

### OpenAI Codex CLI

```bash
dg                              # pindai direktori saat ini
dg /path/to/project             # pindai proyek tertentu
dg /path/to/project "add tests" # mulai dengan prompt
```

### Pemilih Interaktif (baru di v3.9.99)

```bash
graperoot          # tampilkan konfirmasi direktori + pemilih alat dengan tombol panah
graperoot .        # sama, mulai dari direktori saat ini
graperoot --version   # tampilkan versi saat ini
graperoot --update    # paksa pembaruan sendiri
```

### Semua Alat via `graperoot`

```bash
graperoot . --cursor          # Cursor
graperoot . --gemini          # Gemini CLI
graperoot . --opencode        # OpenCode
graperoot . --copilot         # GitHub Copilot
graperoot . --openclaw        # OpenClaw
graperoot /path --gemini "add tests"   # proyek tertentu + prompt
```

### Windows

```powershell
dgc .                          # dari dalam direktori proyek
dgc "D:\projects\my-app"       # drive apa pun, path apa pun
dg "C:\work\backend"           # Codex CLI
dgc --gemini "D:\projects\app" # Gemini CLI di Windows
```

---

## Cara Kerjanya

1. **Pemindaian graf** — pada jalankan pertama, GrapeRoot mengekstrak file, fungsi, kelas, dan hubungan impor ke dalam graf lokal yang tersimpan di `.dual-graph/`.
2. **Pengambilan konteks** — setiap kali Anda mengajukan pertanyaan, graf menentukan peringkat file yang paling relevan dan memuatnya ke dalam prompt sebelum AI Anda menerimanya.
3. **Memori sesi** — file yang telah Anda baca, edit, atau kueri diberi bobot lebih tinggi pada giliran berikutnya. Konteks berlipat ganda.
4. **Alat MCP** — AI Anda tetap dapat menggali lebih dalam melalui alat berbasis graf (`graph_read`, `graph_retrieve`, `graph_neighbors`) bila perlu melakukan eksplorasi lebih lanjut.

Semua pemrosesan dilakukan **secara lokal**. Tidak ada kode yang meninggalkan mesin Anda.

---

## Data & File

Semua data tersimpan di `<project>/.dual-graph/` (ditambahkan otomatis ke `.gitignore`):

| File | Deskripsi |
|------|-----------|
| `info_graph.json` | Graf semantik: file, simbol, tepi |
| `chat_action_graph.json` | Memori sesi: pembacaan, pengeditan, kueri |
| `context-store.json` | Keputusan/tugas/fakta yang tersimpan lintas sesi |

Instalasi global di `~/.dual-graph/`:

| File | Deskripsi |
|------|-----------|
| `dgc.ps1` / `dg.ps1` | Skrip peluncur (diperbarui otomatis) |
| `venv/` | Lingkungan virtual Python |
| `version.txt` | Versi yang terpasang |

---

## Konfigurasi

Semua bersifat opsional, melalui variabel lingkungan:

| Variabel | Default | Deskripsi |
|----------|---------|-----------|
| `DG_HARD_MAX_READ_CHARS` | `4000` | Jumlah karakter maksimum per pembacaan file |
| `DG_TURN_READ_BUDGET_CHARS` | `18000` | Total anggaran pembacaan per giliran |
| `DG_FALLBACK_MAX_CALLS_PER_TURN` | `1` | Jumlah maksimum panggilan grep fallback per giliran |
| `DG_RETRIEVE_CACHE_TTL_SEC` | `900` | TTL cache pengambilan (15 menit) |
| `DG_MCP_PORT` | otomatis (8080–8099) | Paksa port server MCP tertentu |

---

## Pembaruan Otomatis

Peluncur memeriksa pembaruan setiap kali dijalankan dan memperbarui dirinya sendiri secara diam-diam. Untuk memaksa pembaruan:
```bash
graperoot --update
```

Versi saat ini: **3.10.0**

---

## GrapeRoot Pro

[GrapeRoot Pro](https://graperoot.dev/graperoot-pro) menambahkan fitur canggih untuk pengguna tingkat lanjut:

- **Mode tugas menyeluruh** — analisis multi-file mendalam untuk refaktor yang kompleks
- **Deteksi ekspor tak terpakai** — temukan ekspor yang tidak digunakan di seluruh basis kode
- **Pencari siklus dependensi** — deteksi rantai impor melingkar
- **Pencarian lintas basis kode** — pencarian semantik di beberapa repositori sekaligus
- **Pelindung undo** — kait sebelum penggunaan alat yang melindungi operasi destruktif

---

## Pemecahan Masalah

### "MCP Server Connection Failed"

Selalu gunakan `dgc` alih-alih `claude` secara langsung. `dgc` memulai server MCP secara otomatis.

```bash
# Perbaikan:
claude mcp remove dual-graph
dgc   # mendaftarkan ulang semuanya
```

### Panduan pemecahan masalah lengkap

Lihat [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) atau [graperoot.dev/docs](https://graperoot.dev/docs).

---

## Berkontribusi

Skrip peluncur (`bin/`) bersumber terbuka di bawah lisensi Apache 2.0. PR sangat disambut — perbaikan bug, dukungan asisten AI baru, peningkatan instalasi, dokumentasi.

**Catatan:** Mesin graf (`graperoot` paket pip) bersifat proprietari. Peluncur dan perkakas di repositori ini sepenuhnya bersumber terbuka.

---

## Komunitas

Ada pertanyaan, menemukan bug, atau ingin berbagi masukan?

**[Bergabung di Discord →](https://discord.com/invite/YwKdQATY2d)**

---

## Riwayat Bintang

<a href="https://www.star-history.com/?repos=kunal12203%2FCodex-CLI-Compact&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
 </picture>
</a>

---

## Lisensi

Skrip peluncur dan perkakas dalam repositori ini: [Apache License 2.0](./LICENSE)

Mesin graf `graperoot` (PyPI): proprietari. Lihat [graperoot.dev/graperoot-pro](https://graperoot.dev/graperoot-pro).

---

<div align="center">

Made with ❤️ · [graperoot.dev](https://graperoot.dev) · [Discord](https://discord.com/invite/YwKdQATY2d)

</div>
