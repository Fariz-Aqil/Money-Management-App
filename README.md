# Money Management (Flutter, Android)

Ini proyek Flutter lengkap (sudah ada folder `android/`), jadi bisa langsung diunggah.

## Lewat FlutLab (atau IDE online lain)
1. Unggah `money_management_project.zip`. Berkas `pubspec.yaml`, `lib/`, dan `android/` ada di tingkat paling atas zip.
2. Jalankan `pub get`, lalu build APK (Build > Android APK).
3. Unduh APK, pasang di HP.

## Lewat komputer sendiri
1. Pasang Flutter SDK dan Android Studio: https://docs.flutter.dev/get-started/install
2. Ekstrak zip, buka terminal di foldernya, lalu jalankan `flutter pub get` dan `flutter build apk --release`.
3. APK ada di `build/app/outputs/flutter-apk/app-release.apk`.

## Mengaktifkan pencatatan otomatis
- Buka aplikasi, ketuk "Aktifkan", lalu nyalakan Money Management di daftar akses notifikasi.
- Android 13 ke atas: jika tombolnya abu-abu pada APK hasil pasang manual, buka
  Pengaturan > Aplikasi > Money Management > menu ⋮ > "Izinkan setelan terbatas", lalu ulangi.

## Catatan
- Kode belum dikompilasi atau diuji di perangkat. Jika build menampilkan galat, kirim pesannya.
- Konfigurasi Gradle ditulis untuk Flutter sekitar 3.22 sampai 3.27 (AGP 8.1.0, Gradle 8.3, Kotlin 1.8.22).
  Jika Flutter di FlutLab jauh lebih baru atau lebih lama dan menolak versi ini, sebutkan versi Flutter-nya.
- Nama paket aplikasi bank dan e-wallet (`pkgNames` di `lib/main.dart`) bisa berbeda per versi.
- Bahasa: tab Saya > Bahasa (bisa dicari). 13 bahasa dengan terjemahan penuh di `lib/i18n.dart`:
  Indonesia, English, Melayu, 中文, 日本語, 한국어, العربية (kanan-ke-kiri), हिन्दी, Español, Français, Deutsch, ไทย, Tiếng Việt.
  Terjemahan dibuat mesin, sebaiknya dicek penutur asli.
- Belum ada: kalender, tab Laporan (anggaran dan rekening), pilihan mata uang.
