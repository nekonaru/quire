<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/quire-mark-dark.svg" />
    <img src="assets/quire-mark-light.svg" alt="Quire logo" width="120" />
  </picture>
  <h1>Quire: Static Site Generator</h1>
  <p><b>Ubah folder berisi file Markdown menjadi situs statis yang siap deploy,<br/>
  lengkap dengan tag, paginasi, feed, dan dua tema bawaan.</b></p>

  <a href="https://github.com/nekonaru/quire/releases"><img src="https://img.shields.io/github/v/release/nekonaru/quire?style=flat-square&color=blue" alt="Release" /></a>
  <a href="https://github.com/nekonaru/quire/actions/workflows/ci.yml"><img src="https://github.com/nekonaru/quire/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <img src="https://img.shields.io/badge/Ruby-%E2%89%A53.2-CC342D?style=flat-square&logo=ruby&logoColor=white" alt="Ruby" />
  <img src="https://img.shields.io/badge/Platform-Windows%20%C2%B7%20macOS%20%C2%B7%20Linux-333333?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square" alt="Status" />
</div>

<br />

[English](README.md) | **Bahasa Indonesia**

> [!NOTE]
> Quire membangun situs kamu dari Markdown yang sudah kamu punya. Tidak ada database, tidak ada akun, dan tidak ada JavaScript yang wajib di sisi pembaca.

---

## Daftar Isi

- [Tentang](#tentang)
- [Fitur](#fitur)
- [Kebutuhan](#kebutuhan)
- [Instalasi](#instalasi)
- [Penggunaan](#penggunaan)
- [Konfigurasi](#konfigurasi)
- [Front matter](#front-matter)
- [Struktur Proyek](#struktur-proyek)
- [Pengembangan](#pengembangan)
- [Pengujian](#pengujian)
- [Keamanan](#keamanan)
- [Integrasi Berkelanjutan](#integrasi-berkelanjutan)
- [FAQ](#faq)
- [Penulis](#penulis)
- [Lisensi](#lisensi)

---

## Tentang

**Quire** mengubah folder berisi file Markdown dengan YAML front matter menjadi situs statis (HTML dan CSS) yang bisa di-deploy ke GitHub Pages, Netlify, atau Cloudflare Pages. Quire hadir dengan dua tema bawaan, `blog` dan `portfolio`, dan seluruh pipeline build cukup kecil untuk dibaca dalam satu sore.

> _"Markdown masuk, situs keluar. Tanpa JavaScript, tanpa trik."_

Live demo: https://nekonaru.github.io/quire/ (situs `examples/demo` di repository ini, di-deploy oleh GitHub Actions pada setiap perubahan).

---

## Fitur

### Konten

| Fitur | Deskripsi |
|-------|-----------|
| **Markdown dengan GFM** | Tabel, fenced code block, footnote, dan strikethrough, dirender oleh kramdown |
| **Syntax highlighting** | Code block di-highlight oleh Rouge, tema disertakan di kedua tema bawaan |
| **YAML front matter** | `title`, `date`, `tags`, `draft`, `layout`, `slug`, dan `description` per post atau page |
| **Draft dan post terjadwal** | Tidak ikut build secara default; sertakan dengan `--drafts` atau `--future` |

### Build Situs

| Fitur | Deskripsi |
|-------|-----------|
| **Tag** | Halaman tag otomatis di `/tags/<tag>/`, plus indeks tag di `/tags/` |
| **Paginasi** | Paginasi halaman utama di `/page/2/`, `/page/3/`, dan seterusnya |
| **Atom feed** | `feed.xml` berisi 20 post terbaru |
| **Sitemap dan robots** | `sitemap.xml` dan `robots.txt` dibuat pada setiap build |
| **Meta Open Graph** | `og:title`, `og:description`, `og:url`, dan canonical link di kedua tema |
| **Build inkremental** | Input yang tidak berubah berarti tidak ada rebuild; paksa dengan `quire build --force` |

### Tema

| Fitur | Deskripsi |
|-------|-----------|
| **Dua tema bawaan** | `blog` untuk bacaan panjang dengan paginasi, `portfolio` dengan hero dan grid proyek |
| **Ganti tema satu baris** | Ubah `theme: blog` menjadi `theme: portfolio` di `quire.yml` lalu rebuild |
| **Override per file** | Timpa satu layout atau asset tema dari direktori `themes/<name>/` di situs kamu |
| **Dark mode mengikuti sistem** | Kedua tema mengikuti `prefers-color-scheme`; tanpa toggle, tanpa JavaScript |

### Tooling

| Fitur | Deskripsi |
|-------|-----------|
| **Live reload** | `quire serve` membangun ulang saat file berubah dan memuat ulang browser secara otomatis |
| **404 kustom** | Setiap build menulis `404.html` untuk host yang memakainya |
| **Data file** | `data/*.yml` tersedia di template sebagai `site.data` (tema portfolio membaca `projects.yml`) |
| **Pesan error jelas** | Front matter rusak, YAML salah, atau layout yang hilang gagal dengan menyebut file dan nomor baris |

---

## Kebutuhan

| Dependensi | Versi Minimum | Catatan |
|------------|---------------|---------|
| **Ruby** | 3.2 | Wajib untuk install dan menjalankan Quire |
| **Git** | versi terbaru | Hanya diperlukan untuk install dari GitHub |

> [!TIP]
> Kamu tidak perlu membangun apa pun. Opsi A memasang gem prebuilt dalam dua perintah.

### Belum pernah pakai terminal? Mulai di sini

<details>
<summary><b>Cara membuka terminal di Windows</b></summary>

1. Tekan tombol **Windows**, ketik `PowerShell`, lalu tekan **Enter**
2. Sebuah jendela terbuka. Di situlah kamu mengetik perintah
3. Setiap perintah di panduan ini diketik di jendela tersebut, diikuti dengan **Enter**

</details>

<details>
<summary><b>Cara membuka terminal di macOS</b></summary>

1. Tekan **Cmd + Space**, ketik `Terminal`, lalu tekan **Enter**
2. Sebuah jendela terbuka. Di situlah kamu mengetik perintah
3. Setiap perintah di panduan ini diketik di jendela tersebut, diikuti dengan **Enter**

</details>

<details>
<summary><b>Cara membuka terminal di Linux</b></summary>

1. Tekan **Ctrl + Alt + T**, atau buka app launcher dan ketik `Terminal`
2. Sebuah jendela terbuka. Di situlah kamu mengetik perintah
3. Setiap perintah di panduan ini diketik di jendela tersebut, diikuti dengan **Enter**

</details>

---

## Instalasi

### Opsi A: Download gem prebuilt (paling mudah)

1. Buka https://github.com/nekonaru/quire/releases/latest
2. Download `quire-0.1.0.gem` dari Assets
3. Install:

```bash
gem install ./quire-0.1.0.gem
quire version
```

Lalu buat situs pertamamu:

```bash
quire new site mysite
cd mysite
quire build
quire serve
```

Buka http://localhost:4000 di browser kamu.

### Opsi B: Build dari source (untuk development / untuk membaca atau mengubah kode)

#### 1. Ambil kode proyek

<details>
<summary><b>Saya sudah punya Git</b></summary>

```bash
git clone https://github.com/nekonaru/quire.git
cd quire
```

</details>

<details>
<summary><b>Saya belum punya Git</b></summary>

1. Buka halaman repository di GitHub
2. Klik tombol hijau **`Code`**, pilih **`Download ZIP`**
3. Ekstrak ZIP ke folder pilihan kamu
4. Di terminal, masuk ke folder hasil ekstrak, misalnya:

```bash
cd Downloads/quire-main
```

</details>

#### 2. Install dependency dan verifikasi

```bash
bundle install
bundle exec rspec
```

> [!IMPORTANT]
> `bundle exec rspec` harus lulus seluruh tes sebelum kamu membangun gem.

#### 3. Build dan install gem

```bash
gem build quire.gemspec
gem install ./quire-0.1.0.gem
quire version
```

---

## Penggunaan

### Build pertama

1. Buat situs dengan `quire new site mysite`
2. `cd mysite`
3. `quire serve`
4. Buka http://localhost:4000

> [!NOTE]
> `quire serve` membangun ulang secara otomatis. Edit file mana pun di `content/`, `data/`, `static/`, atau `themes/`, browser akan memuat ulang dengan sendirinya.

### Perintah sehari-hari

```bash
quire new post "My post title"    # membuat content/posts/2026-11-15-my-post-title.md
quire new page "Uses"             # membuat content/pages/uses.md
quire build                       # build ke public/
quire build --drafts --future     # sertakan draft dan post bertanggal masa depan
quire build --force               # abaikan incremental cache
quire serve                       # build, serve di :4000, live reload
quire serve --port 8080           # serve di port lain
quire clean                       # hapus public/ dan .quire-cache.json
quire version                     # cetak versi
```

### Deploy ke GitHub Pages

1. Push situs kamu ke repository GitHub
2. Di repository: **Settings > Pages > Source**, pilih **GitHub Actions**, atau publish folder `public/` dengan workflow seperti `actions/deploy-pages`
3. Set `base_url` di `quire.yml` ke URL Pages kamu (misalnya `https://<user>.github.io/<repo>`), lalu rebuild

---

## Konfigurasi

Semuanya berada di `quire.yml` di root situs:

```yaml
title: My Site
description: What this site is about
author: Your Name
base_url: https://example.com   # tanpa trailing slash; dibutuhkan feed dan sitemap
theme: blog                     # blog atau portfolio (atau tema di themes/)
posts_per_page: 10
email: me@example.com           # tombol kontak di tema portfolio
menu:
  - title: Home
    url: /
  - title: About
    url: /about/
social:
  github: yourhandle
markdown:
  allow_html: false             # true untuk meneruskan raw HTML
```

| Kunci | Default | Arti |
|-------|---------|------|
| `title` | `Quire Site` | Judul situs, dipakai di header dan `<title>` |
| `description` | `""` | Deskripsi situs, dipakai di meta tag |
| `author` | `""` | Ditampilkan di footer dan feed |
| `base_url` | `""` | Base URL absolut, tanpa trailing slash |
| `theme` | `blog` | Tema bawaan atau tema di `themes/<name>/` |
| `posts_per_page` | `10` | Jumlah post per halaman indeks |
| `menu` | `[]` | Entri nav bar dengan `title` dan `url` |
| `markdown.allow_html` | `false` | `true` meneruskan raw HTML dari Markdown |

---

## Front matter

Post berada di `content/posts/`, page di `content/pages/`. Setiap file Markdown dimulai dengan front matter:

```markdown
---
title: My post
date: 2026-11-15
tags:
  - ruby
  - meta
draft: false
slug: my-post
description: Satu baris yang tampil di feed dan meta tag
layout: post
---

Isi dalam Markdown.
```

| Kunci | Wajib | Arti |
|-------|-------|------|
| `title` | tidak | Default ke nama file; dipakai di `<title>` dan daftar |
| `date` | post: dianjurkan | `YYYY-MM-DD`; mengatur urutan. Page tidak punya tanggal |
| `tags` | tidak | Daftar nama tag; menggerakkan halaman tag |
| `draft` | tidak | `true` menyembunyikan file dari build, kecuali `--drafts` |
| `slug` | tidak | Slug URL; default ke nama file |
| `description` | tidak | Ringkasan satu baris untuk feed, meta tag, dan excerpt |
| `layout` | tidak | Nama layout; default ke `post` atau `page` |

File bernama `YYYY-MM-DD-title.md` mendapat tanggal dan slug dari nama file bila front matter tidak mengisinya.

---

## Struktur Proyek

```
quire/
├── exe/quire                   # entry point CLI
├── lib/quire/
│   ├── cli.rb                  # perintah thor
│   ├── config.rb               # pemuatan dan validasi quire.yml
│   ├── document.rb             # model post/page (front matter + body)
│   ├── front_matter.rb         # parser YAML front matter
│   ├── markdown.rb             # renderer kramdown + rouge
│   ├── site.rb                 # model situs: posts, pages, tags, data
│   ├── builder.rb              # pipeline build
│   ├── renderer.rb             # rendering ERB dengan layout dan partial
│   ├── theme.rb                # resolusi tema dan override
│   ├── paginator.rb            # paginasi halaman utama
│   ├── feed.rb                 # Atom feed
│   ├── sitemap.rb              # sitemap.xml
│   └── server.rb               # server WEBrick + live reload
├── themes/
│   ├── blog/                   # tema blog bawaan
│   └── portfolio/              # tema portfolio bawaan
├── templates/new_site/         # scaffold untuk `quire new site`
├── examples/demo/              # situs contoh yang dipakai tes integrasi
├── spec/                       # RSpec suite
├── docs/decisions.md           # keputusan desain
├── README.md                   # dokumentasi (English)
└── README.id.md                # dokumentasi (Bahasa Indonesia)
```

---

## Pengembangan

### Menambah tema baru

1. Buat `themes/<name>/theme.yml` di situs kamu, atau salin `themes/blog/` dari repository ini
2. Tambahkan layout: `base.html.erb` adalah kerangka; layout lain (`post`, `page`, `index`, `tag`, `tags`, `404`) dibungkus di dalamnya
3. Taruh CSS dan asset lain di `themes/<name>/assets/`; asset akan disalin ke `public/assets/`
4. Set `theme: <name>` di `quire.yml` lalu jalankan `quire build`

Tema bawaan tidak memakai framework dan tidak memakai JavaScript. Ikuti aturan yang sama di tema kamu.

### Menimpa satu file tema

Salin file yang ingin kamu ubah dari tema ke `themes/<name>/` di situs kamu, dengan path relatif yang sama. Hanya file itu yang ditimpa; sisanya kembali ke tema.

Contoh: menimpa hanya halaman 404 tema blog di situs kamu:

```
mysite/themes/blog/layouts/404.html.erb
```

### Menambah string yang terlihat pengguna

Pesan CLI Quire berbahasa Inggris (lihat `lib/quire/cli.rb`). Tema memakai markup Inggris biasa; tidak ada katalog string yang perlu dirawat.

---

## Pengujian

```bash
bundle exec rspec
bundle exec rubocop
```

| Pengecekan | Requirement |
|-----------|-------------|
| `bundle exec rspec` | Harus lulus seluruh suite |
| `bundle exec rubocop` | Harus melaporkan tidak ada offense |

Lint ditegakkan lewat `.rubocop.yml`. Situs demo di `examples/demo/` dipakai sebagai tes integrasi: suite membangunnya dan memeriksa struktur output, feed, dan sitemap.

---

## Keamanan

Quire membangun file statis dari Markdown kamu sendiri; Quire tidak menjalankan database atau application server di produksi. Raw HTML di Markdown di-escape secara default, jadi sebuah post tidak bisa menyuntikkan markup ke situs. Rahasia dipindai di CI, dan review dependensi dilakukan lewat checklist rilis. Untuk melaporkan kerentanan, lihat [`SECURITY.md`](SECURITY.md).

> [!NOTE]
> Laporkan kerentanan secara privat lewat GitHub security advisories, bukan sebagai issue publik.

---

## Integrasi Berkelanjutan

| Workflow | Tujuan |
|----------|--------|
| `ci.yml` | RuboCop, RSpec (Ruby 3.2 dan 3.4 di Linux, Windows, macOS), build gem, build situs contoh, secret scan pada setiap push dan pull request |
| `release.yml` | Membangun gem dan membuat draft GitHub release dengan catatan changelog pada tag `v*` |
| `deploy-demo.yml` | Membangun situs demo dan men-deploy-nya ke GitHub Pages pada setiap push ke main yang menyentuh demo atau generator |

Release di-tag hanya setelah CI hijau di branch default.

---

## FAQ

<details>
<summary><b>Bagaimana cara deploy ke GitHub Pages?</b></summary>

Set `base_url` ke URL Pages kamu, commit `public/` atau pakai workflow deploy, lalu aktifkan Pages di pengaturan repository. Lihat bagian Penggunaan di atas.

</details>

<details>
<summary><b>Bagaimana cara beralih dari tema blog ke tema portfolio?</b></summary>

Ubah `theme: blog` menjadi `theme: portfolio` di `quire.yml` lalu rebuild. Konten tidak berubah.

</details>

<details>
<summary><b>Dari mana isi grid proyek berasal?</b></summary>

`data/projects.yml` di situs kamu. Setiap entri berisi `name`, `description`, `url` (opsional), dan `tech` (opsional).

</details>

<details>
<summary><b>Bisakah saya menambahkan raw HTML ke post?</b></summary>

Set `markdown.allow_html: true` di `quire.yml`. Secara default, raw HTML di-escape.

</details>

<details>
<summary><b>Kenapa draft tidak muncul?</b></summary>

Draft (dan post bertanggal masa depan) dikecualikan kecuali kamu menambahkan `--drafts` atau `--future` ke `quire build` atau `quire serve`.

</details>

---

## Penulis

<div align="center">

| [![Nicolas Dwi Dharma](https://github.com/nekonaru.png?size=100)](https://github.com/nekonaru) |
|:---:|
| **Nicolas Dwi Dharma** |
| [github.com/nekonaru](https://github.com/nekonaru) |

</div>

---

## Lisensi

Didistribusikan di bawah **MIT License**. Lihat [`LICENSE`](LICENSE) untuk informasi lebih lanjut.
