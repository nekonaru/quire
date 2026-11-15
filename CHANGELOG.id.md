# Changelog

Semua perubahan penting pada Quire didokumentasikan di sini. Formatnya mengikuti [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), dan proyek ini memakai [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.1.1

Rilis patch yang memperbaiki cacat encoding pada judul dan beberapa masalah ketahanan.

## Perbaikan bug

- **Mojibake di judul halaman.** Pemisah antara judul halaman dan judul situs ter-encode dua kali dan tampil sebagai "Â·" di semua halaman selain beranda pada kedua tema.
- **Indented code block.** HTML di dalam code block 4 spasi ter-escape dua kali, sehingga contoh kode menampilkan teks entity mentah alih-alih markup.
- **Lingkungan non-UTF-8.** Pembuat slug tidak lagi crash ketika nama file atau konten memakai locale non-UTF-8.
- **Parsing front matter.** Blok YAML tidak lagi menyertakan baris `---` penutup, menghilangkan jebakan parsing yang laten.
- **Validasi posts_per_page.** Nilai desimal ditolak dengan pesan error yang jelas alih-alih dipotong diam-diam menjadi integer.
- **Jumlah argumen `quire new site`.** Argumen berlebih sekarang menghasilkan error usage alih-alih diabaikan diam-diam.

## Peningkatan

- **Akurasi README.** Bagian Security sekarang menjelaskan apa yang benar-benar dicek CI alih-alih checklist rilis yang tidak ada.

## v0.1.0

Rilis publik pertama Quire, static site generator yang ditulis dalam Ruby.

## Fitur baru

- **Pipeline Markdown.** kramdown dengan input GFM merender post; tabel, fenced code block dengan syntax highlighting Rouge, dan footnote semuanya langsung jalan.
- **YAML front matter.** Post dan page menerima `title`, `date`, `tags`, `draft`, `layout`, `slug`, dan `description`. Front matter yang tidak valid menggagalkan build dengan menyebut file dan nomor baris.
- **Dua tema bawaan.** `blog` untuk daftar bacaan panjang yang nyaman dengan tag dan paginasi, `portfolio` untuk situs personal dengan hero dan grid proyek dari `data/projects.yml`. Ganti tema hanya dengan mengubah satu baris di `quire.yml`.
- **CLI.** `quire new site`, `quire new post`, `quire new page`, `quire build`, `quire serve`, `quire clean`, dan `quire version`.
- **Server lokal dengan live reload.** `quire serve` membangun ulang saat file berubah dan browser me-refresh otomatis (polling, tanpa build step JavaScript).
- **Feed dan penemuan konten.** Atom feed di `feed.xml`, `sitemap.xml`, `robots.txt`, serta meta Open Graph dan canonical di kedua tema.
- **Draft dan post terjadwal.** Tidak ikut build secara default; diikutsertakan dengan `--drafts` dan `--future`.
- **Build inkremental.** Input yang tidak berubah berarti tidak ada rebuild; `quire build --force` untuk memaksa rebuild.
- **Override tema.** Situs bisa menimpa satu file tema mana pun (layout atau asset) dengan menaruh file di `themes/<name>/`, tanpa fork tema.

## Penggunaan

Install dari GitHub Releases dengan Ruby 3.2 atau lebih baru:

```bash
curl -LO https://github.com/nekonaru/quire/releases/download/v0.1.0/quire-0.1.0.gem
gem install ./quire-0.1.0.gem
quire new site mysite
cd mysite
quire build
quire serve
```

Atau build gem dari source dengan `gem build quire.gemspec` dan `gem install ./quire-0.1.0.gem`. Lihat README untuk tutorial lengkap.
