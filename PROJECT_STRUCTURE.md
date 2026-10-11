# Struktur FlutterProject

```text
FlutterProject/
├── .idea/                       # Konfigurasi workspace IDE
├── hello_mobile_app/
│   └── build/                   # Hasil build; belum berisi source project Flutter
├── warungku/                    # Aplikasi Flutter yang saat ini berisi source
│   ├── android/                 # Konfigurasi platform Android
│   ├── assets/
│   │   └── images/              # Lokasi aset gambar aplikasi
│   ├── ios/                     # Konfigurasi platform iOS
│   ├── lib/
│   │   ├── core/                # Token UI, ikon, dan fungsi format
│   │   ├── data/                # Data katalog
│   │   ├── navigation/          # Definisi layar dan navigasi
│   │   ├── screens/             # Halaman aplikasi
│   │   ├── state/               # State aplikasi
│   │   ├── widgets/             # Widget yang digunakan ulang
│   │   └── main.dart            # Entry point aplikasi
│   ├── linux/                   # Konfigurasi platform Linux
│   ├── macos/                   # Konfigurasi platform macOS
│   ├── test/                    # Widget tests
│   ├── tool/                    # Skrip bantuan pengembangan
│   ├── web/                     # Konfigurasi platform web
│   ├── windows/                 # Konfigurasi platform Windows
│   ├── analysis_options.yaml    # Konfigurasi analisis Dart
│   ├── pubspec.yaml             # Metadata proyek dan dependencies
│   ├── pubspec.lock             # Versi dependencies yang terkunci
│   └── README.md                # Catatan dan petunjuk aplikasi WarungKu
└── PROJECT_STRUCTURE.md         # Dokumentasi struktur workspace ini
```

`hello_mobile_app` saat ini hanya memiliki folder `build`, jadi belum tampak sebagai
proyek Flutter lengkap. Source aplikasi yang tersedia berada di `warungku`.
Folder seperti `.dart_tool` dan `build` di dalam `warungku` merupakan hasil
tooling/build dan tidak dicantumkan sebagai bagian source utama.
