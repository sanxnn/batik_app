# Batik Rubung Kuning — aplikasi pelanggan

Aplikasi Flutter untuk akun pelanggan, katalog, bundling, alamat, keranjang, checkout, pembayaran Midtrans, pengiriman, refund, dan custom order. Kontrak integrasi mengikuti [referensi API backend](https://github.com/sanxnn/rubung-v3/blob/main/docs/api-reference.md). Mulai dari [dokumentasi aplikasi](docs/README.md) untuk arsitektur, fitur, alur sistem, dan panduan pengujian.

## Persyaratan

- Flutter dengan Dart SDK yang memenuhi `pubspec.yaml` (`^3.13.1`).
- Untuk build Android: JDK lengkap yang menyediakan `javac`, Android SDK, dan signing release milik tim.
- Backend Laravel dengan versi API yang sesuai dengan [peta integrasi Flutter](docs/referensi-integrasi-api.md).
- Untuk uji pembayaran: akun dan konfigurasi Midtrans sandbox di backend. Production memerlukan konfigurasi Midtrans production di backend.

## Menjalankan aplikasi

1. Periksa `.env` dan isi `API_BASE_URL` dengan host backend pengembangan yang dapat dijangkau perangkat. Salin `.env.example` jika `.env` belum tersedia.
2. Jalankan `flutter pub get`.
3. Jalankan `flutter run --dart-define=MIDTRANS_ENV=sandbox`.

File `.env` dilacak Git dan dikemas sebagai Flutter asset. Simpan perubahan URL lokal di workspace. Jangan menaruh server key, token pengguna, atau rahasia lain di dalamnya.

## Build production

1. Pastikan `.env` berisi `API_BASE_URL=https://batikrubungkuning.sanxnn.my.id/api` atau endpoint HTTPS production yang berlaku.
2. Pastikan backend mengeluarkan token Midtrans **production**. Nilai `MIDTRANS_ENV` aplikasi harus sama dengan lingkungan backend.
3. Jalankan `flutter test` dan `flutter analyze`.
4. Bangun artefak sesuai target, misalnya:

```bash
flutter build apk --release --dart-define=MIDTRANS_ENV=production
flutter build appbundle --release --dart-define=MIDTRANS_ENV=production
flutter build ios --release --dart-define=MIDTRANS_ENV=production
```

Konfigurasi signing Android/iOS, identitas aplikasi, ikon, dan pengujian transaksi nyata tetap perlu dilakukan oleh tim rilis. Uji alur registrasi, verifikasi email, checkout, pembatalan, serta pembayaran Midtrans sandbox pada perangkat sebelum mengganti ke production.

## Panduan lanjut

- [Fitur dan panduan pelanggan](docs/fitur.md)
- [Alur sistem dan perubahan status](docs/alur-sistem.md)
- [Peta integrasi API](docs/referensi-integrasi-api.md)
- [Skenario pengujian dan persiapan rilis](docs/pengujian-dan-rilis.md)
