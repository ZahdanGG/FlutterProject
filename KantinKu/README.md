# KantinKu 🍽️

**Aplikasi Pre-Order Makanan Kantin Berbasis Flutter**

KantinKu adalah aplikasi pemesanan makanan kantin yang saya buat menggunakan Flutter. Aplikasi ini dibuat untuk mempermudah mahasiswa atau pengguna kantin dalam memesan makanan tanpa harus mengantre terlalu lama.

Lewat KantinKu, pengguna bisa melihat menu makanan, memilih kantin, melakukan pemesanan, dan mengambil makanan sesuai waktu yang dipilih.

## Tujuan Project

Tujuan utama dari aplikasi ini adalah membuat proses pemesanan makanan di kantin jadi lebih praktis, terutama saat jam istirahat ketika kantin sedang ramai.

Dengan sistem pre-order, pengguna bisa memesan makanan lebih awal sehingga waktu istirahat tidak habis hanya untuk mengantre.

## Fitur KantinKu

Berikut fitur yang dirancang dalam aplikasi:

- **Home:** Menampilkan daftar kantin, menu makanan, dan rekomendasi makanan.
- **Detail Menu:** Melihat informasi makanan sebelum dipesan.
- **Keranjang:** Menyimpan makanan yang ingin dibeli.
- **Checkout:** Mengatur pesanan sebelum pembayaran.
- **Pembayaran:** Memilih metode pembayaran dan melihat status pembayaran.
- **Order:** Melihat daftar pesanan dan detailnya.
- **Kode Pengambilan:** Menampilkan kode untuk mengambil makanan.
- **Login & Registrasi:** Sistem akun untuk pengguna.
- **Profile:** Menampilkan dan mengubah informasi pengguna.
- **Settings:** Pengaturan akun, keamanan, privasi, dan bantuan.

Pengunjung yang belum login tetap bisa melihat daftar kantin dan makanan, tetapi harus mempunyai akun untuk melakukan pemesanan.

## Progress Pengembangan

**Status: Dalam Pengembangan — 50%**

Saat ini saya sedang mengembangkan tampilan aplikasi sekaligus menghubungkan navigasi dan fitur-fitur utamanya.

Pengerjaan yang sudah masuk ke project meliputi:

- Struktur folder Flutter yang lebih tertata.
- Pembuatan halaman utama, menu, keranjang, dan checkout.
- Penambahan halaman login dan registrasi.
- Pembuatan tampilan pesanan, pembayaran, serta profil.
- Penambahan gambar makanan, kantin, dan aset aplikasi.
- Pengembangan navigasi antarhalaman.
- Penambahan pengujian dasar aplikasi.

Untuk tahap berikutnya, saya akan fokus menyempurnakan alur pemesanan, memastikan tombol dan navigasi berjalan sesuai fungsinya, memperbaiki bug, dan menguji aplikasi secara keseluruhan.

## Teknologi yang Digunakan

- **Flutter** — Framework untuk membuat aplikasi.
- **Dart** — Bahasa pemrograman.
- **Figma** — Desain UI/UX aplikasi.
- **VS Code** — Editor untuk mengerjakan coding.
- **Git & GitHub** — Menyimpan dan mengelola perkembangan project.

## Struktur Folder

```text
KantinKu/
├── assets/
│   ├── fonts/
│   └── images/
├── lib/
│   ├── app/
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   ├── cart/
│   │   ├── catalog/
│   │   ├── checkout/
│   │   ├── home/
│   │   ├── order/
│   │   ├── profile/
│   │   └── settings/
│   ├── shared/
│   └── main.dart
├── test/
└── pubspec.yaml
```

Struktur folder ini dibuat supaya setiap fitur lebih mudah dikembangkan dan diperbaiki tanpa harus mengubah keseluruhan project.

## Cara Menjalankan Aplikasi

Pastikan Flutter sudah terpasang di komputer.

**1. Clone repository**

```bash
git clone https://github.com/ZahdanGG/FlutterProject.git
```

**2. Masuk ke folder aplikasi**

```bash
cd FlutterProject/KantinKu
```

**3. Install dependency**

```bash
flutter pub get
```

**4. Jalankan aplikasi**

```bash
flutter run
```

Untuk mengecek masalah pada coding:

```bash
flutter analyze
```

Untuk menjalankan pengujian:

```bash
flutter test
```

## Rencana Pengembangan Selanjutnya

Melanjutkan pengerjaan KantinKu secara bertahap, dengan target aplikasi bisa digunakan dari awal sampai akhir proses pemesanan.

Fokus utamanya adalah menyelesaikan integrasi fitur, memperbaiki tampilan agar sesuai desain Figma, menguji alur aplikasi, dan memastikan aplikasi berjalan dengan stabil di Android.

---

**KantinKu — Project Aplikasi Mobile Flutter**

*Status pengembangan: 50% — masih dalam proses pengerjaan dan penyempurnaan.*
