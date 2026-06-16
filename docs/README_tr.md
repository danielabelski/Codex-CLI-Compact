<div align="center">

# GrapeRoot

### Yapay Zeka Kodlama Asistanları için Birikimli Bağlam Motoru

**[graperoot.dev](https://graperoot.dev)** · [Docs](https://graperoot.dev/docs) · [Benchmarks](https://graperoot.dev/benchmarks) · [Pro](https://graperoot.dev/graperoot-pro) · [Discord](https://discord.com/invite/YwKdQATY2d)

[![PyPI](https://img.shields.io/pypi/v/graperoot?label=version&color=brightgreen)](https://pypi.org/project/graperoot/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)](#install)
[![Discord](https://img.shields.io/badge/Discord-community-5865F2?logo=discord&logoColor=white)](https://discord.com/invite/YwKdQATY2d)
[![Stars](https://img.shields.io/github/stars/kunal12203/Codex-CLI-Compact?style=social)](https://github.com/kunal12203/Codex-CLI-Compact/stargazers)

---

🌐 **Kendi dilinizde okuyun:**
[English](../README.md) · [中文](./README_zh-CN.md) · [Español](./README_es.md) · [हिंदी](./README_hi.md) · [Français](./README_fr.md) · [Deutsch](./README_de.md) · [日本語](./README_ja.md) · [한국어](./README_ko.md) · [Português](./README_pt-BR.md) · [Русский](./README_ru.md) · [العربية](./README_ar.md) · [Türkçe](./README_tr.md) · [Bahasa Indonesia](./README_id.md)

</div>

---

## GrapeRoot Nedir?

GrapeRoot, siz ve yapay zeka kodlama asistanınız arasında konumlanan açık kaynaklı bir **bağlam motorudur**. Kod tabanınızın — dosyalar, semboller, içe aktarmalar, çağrı zincirleri — anlamsal bir grafiğini oluşturur ve yapay zekanın görmeden önce her isteme tam olarak doğru kodu önceden yükler.

Sonuç olarak: yapay zekanız tokenlarını **keşfetmeye** değil, **akıl yürütmeye** harcar.

```
Çalıştırırsınız: dgc /path/to/project
              ↓
1. Proje taranır → anlamsal grafik oluşturulur (dosyalar, semboller, içe aktarmalar)
2. Bir soru sorarsınız
3. Grafik ilgili dosyaları belirler → bunları bağlama paketler
4. Yapay zeka sorunuzu + doğru kodu önceden yüklenmiş olarak alır
5. Daha az tur, daha az token, daha iyi yanıtlar
```

Token tasarrufu bir oturum boyunca **birikerek** artar. Grafik hangi dosyaların okunduğunu, düzenlendiğini ve sorgulandığını hatırlar — her tur daha ucuza gelir.

---

## Sonuçlar

Birden fazla gerçek kod tabanında (7.700'den fazla dosya) ve 50'den fazla mühendislik istemiyle kıyaslandı:

| Ölçüt | GrapeRoot Olmadan | GrapeRoot ile |
|-------|:-----------------:|:-------------:|
| İstem başına maliyet | $0.49 | **$0.27** |
| Görev başına ortalama tur sayısı | 11.7 | **3.5** |
| Ortalama yanıt süresi | 172s | **124s** |
| Kalite (puanlanmış) | 76.6 / 100 | **86.6 / 100** |
| Maliyet kazanma oranı | — | **10 istemden 10'u** |

### Görev türüne göre maliyet azalması

| Görev türü | Maliyet azalması |
|------------|:----------------:|
| Geçiş ve mimari tasarım | **%81'e kadar** |
| Performans analizi | **%80'e kadar** |
| Test ve test oluşturma | **%76'ya kadar** |
| Full-stack hata ayıklama | **%73'e kadar** |
| Özellik geliştirme | **%71'e kadar** |
| Kod açıklama ve denetim | **%55'e kadar** |
| Büyük kod tabanı (7k+ dosya, ort.) | **ortalama %43** |

> Tasarruflar bir oturum boyunca **birikerek** artar — 3. turda önlenen bir token, sonraki her turda önbellek yeniden faturalandırmasını da engeller. Kalite, yukarıdaki tüm görev türlerinde eşit kalır ya da iyileşir.

Tam kıyaslama metodolojisi ve sonuçları: [graperoot.dev/benchmarks](https://graperoot.dev/benchmarks)

---

## Desteklenen Yapay Zeka Araçları

| Araç | Komut | Durum |
|------|-------|-------|
| Claude Code | `dgc` | ✅ Tam destek |
| OpenAI Codex CLI | `dg` | ✅ Tam destek |
| Cursor | `graperoot . --cursor` | ✅ Tam destek |
| Gemini CLI | `graperoot . --gemini` | ✅ Tam destek |
| OpenCode | `graperoot . --opencode` / `dgo` | ✅ Tam destek |
| GitHub Copilot | `graperoot . --copilot` | ✅ Tam destek |
| OpenClaw | `graperoot . --openclaw` | ✅ Tam destek |
| Antigravity | `graperoot . --antigravity` | ✅ Tam destek |

---

## Desteklenen Programlama Dilleri

TypeScript · JavaScript · Python · Go · Swift · Rust · Java · Kotlin · Scala · C# · Ruby · PHP

---

## Kurulum

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

> **Ön koşullar:** Python 3.10+, Node.js 18+ ve desteklenen yapay zeka araçlarından biri. Yükleyici eksik araçları otomatik olarak algılar ve bunları yüklemeyi teklif eder.

---

## Kullanım

> **Önemli:** MCP sunucusunun çalıştığından emin olmak için her zaman `claude` yerine `dgc` kullanın.

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

### Etkileşimli Seçici (v3.9.99'da yeni)

```bash
graperoot          # shows directory confirm + arrow-key tool picker
graperoot .        # same, picks from current directory
graperoot --version   # print current version
graperoot --update    # force self-update
```

### `graperoot` ile Tüm Araçlar

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

## Nasıl Çalışır

1. **Grafik taraması** — İlk çalıştırmada GrapeRoot, dosyaları, fonksiyonları, sınıfları ve içe aktarma ilişkilerini `.dual-graph/` içinde saklanan yerel bir grafiğe çıkarır.
2. **Bağlam alımı** — Her soru sorduğunuzda grafik en ilgili dosyaları sıralar ve yapay zekanız görmeden önce bunları isteme paketler.
3. **Oturum belleği** — Okuduğunuz, düzenlediğiniz veya sorguladığınız dosyalar gelecekteki turlarda daha yüksek ağırlık alır. Bağlam birikerek büyür.
4. **MCP araçları** — Yapay zekanız daha derine inmeye ihtiyaç duyduğunda grafik-bilinçli araçlar (`graph_read`, `graph_retrieve`, `graph_neighbors`) aracılığıyla yine de daha fazla araştırabilir.

Tüm işlemler **yereldir**. Hiçbir kod makinenizden çıkmaz.

---

## Veri ve Dosyalar

Tüm veriler `<proje>/.dual-graph/` dizininde saklanır (`.gitignore` dosyasına otomatik olarak eklenir):

| Dosya | Açıklama |
|-------|----------|
| `info_graph.json` | Anlamsal grafik: dosyalar, semboller, kenarlar |
| `chat_action_graph.json` | Oturum belleği: okumalar, düzenlemeler, sorgular |
| `context-store.json` | Oturumlar arası kalıcı kararlar/görevler/olgular |

`~/.dual-graph/` dizinindeki genel kurulum:

| Dosya | Açıklama |
|-------|----------|
| `dgc.ps1` / `dg.ps1` | Başlatıcı betikler (otomatik güncellenir) |
| `venv/` | Python sanal ortamı |
| `version.txt` | Kurulu sürüm |

---

## Yapılandırma

Tümü isteğe bağlıdır; ortam değişkenleri aracılığıyla ayarlanır:

| Değişken | Varsayılan | Açıklama |
|----------|------------|----------|
| `DG_HARD_MAX_READ_CHARS` | `4000` | Dosya okuma başına maksimum karakter sayısı |
| `DG_TURN_READ_BUDGET_CHARS` | `18000` | Tur başına toplam okuma bütçesi |
| `DG_FALLBACK_MAX_CALLS_PER_TURN` | `1` | Tur başına maksimum yedek grep çağrısı |
| `DG_RETRIEVE_CACHE_TTL_SEC` | `900` | Alım önbelleği TTL'si (15 dakika) |
| `DG_MCP_PORT` | otomatik (8080–8099) | Belirli bir MCP sunucusu portunu zorla |

---

## Otomatik Güncelleme

Başlatıcı her çalıştırmada güncellemeleri kontrol eder ve sessizce otomatik olarak güncellenir. Güncellemeyi zorlamak için:
```bash
graperoot --update
```

Mevcut sürüm: **3.10.0**

---

## GrapeRoot Pro

[GrapeRoot Pro](https://graperoot.dev/graperoot-pro), ileri düzey kullanıcılar için gelişmiş özellikler sunar:

- **Kapsamlı görev modu** — karmaşık yeniden yapılandırmalar için derin çok dosyalı analiz
- **Kullanılmayan dışa aktarma tespiti** — kod tabanı genelinde kullanılmayan dışa aktarmaları bulma
- **Bağımlılık döngüsü bulucu** — döngüsel içe aktarma zincirlerini tespit etme
- **Kod tabanları arası arama** — birden fazla depo genelinde anlamsal arama
- **Geri alma kalkanı** — yıkıcı işlemleri koruyan araç-öncesi kancalar

---

## Sorun Giderme

### "MCP Server Connection Failed"

Her zaman `claude` yerine `dgc` kullanın. `dgc`, MCP sunucusunu otomatik olarak başlatır.

```bash
# Fix:
claude mcp remove dual-graph
dgc   # re-registers everything
```

### Tam sorun giderme kılavuzu

[TROUBLESHOOTING.md](./TROUBLESHOOTING.md) veya [graperoot.dev/docs](https://graperoot.dev/docs) adresine bakın.

---

## Katkıda Bulunma

Başlatıcı betikler (`bin/`), Apache 2.0 lisansı altında açık kaynaktır. PR'lar kabul edilir — hata düzeltmeleri, yeni yapay zeka asistan desteği, kurulum iyileştirmeleri, belgeler.

**Not:** Grafik motoru (`graperoot` pip paketi) tescilli bir yazılımdır. Bu depodaki başlatıcılar ve araçlar tamamen açık kaynaktır.

---

## Topluluk

Bir sorunuz mu var, hata mı buldunuz ya da geri bildirim paylaşmak mı istiyorsunuz?

**[Discord'a Katılın →](https://discord.com/invite/YwKdQATY2d)**

---

## Yıldız Geçmişi

<a href="https://www.star-history.com/?repos=kunal12203%2FCodex-CLI-Compact&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=kunal12203/Codex-CLI-Compact&type=date&legend=top-left" />
 </picture>
</a>

---

## Lisans

Bu depodaki başlatıcı betikler ve araçlar: [Apache License 2.0](./LICENSE)

`graperoot` grafik motoru (PyPI): tescilli yazılım. Bkz. [graperoot.dev/graperoot-pro](https://graperoot.dev/graperoot-pro).

---

<div align="center">

❤️ ile yapıldı · [graperoot.dev](https://graperoot.dev) · [Discord](https://discord.com/invite/YwKdQATY2d)

</div>
