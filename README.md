# Batik Rubung Kuning — aplikasi pelanggan

Aplikasi Flutter untuk katalog, akun pelanggan, alamat, keranjang, checkout, pembayaran Midtrans, dan riwayat pesanan. Kontrak API proyek ada di [roadmap.md](roadmap.md); panduan arsitektur dan pengujian ada di [dokumentasi.md](dokumentasi.md).

## Persyaratan

- Flutter dengan Dart SDK yang memenuhi `pubspec.yaml` (`^3.13.1`).
- Untuk build Android: JDK lengkap yang menyediakan `javac`, Android SDK, dan signing release milik tim.
- Backend Laravel API yang sesuai dengan `roadmap.md`.
- Untuk uji pembayaran: akun dan konfigurasi Midtrans sandbox di backend. Production memerlukan konfigurasi Midtrans production di backend.

## Menjalankan aplikasi

1. Salin `.env.example` menjadi `.env`. Endpoint bawaan mengarah ke `https://batikrubungkuning.sanxnn.my.id/api`. Untuk pengembangan lokal saja, ubah `API_BASE_URL` ke host backend lokal yang sesuai perangkat.
2. Jalankan `flutter pub get`.
3. Jalankan `flutter run --dart-define=MIDTRANS_ENV=sandbox`.

File `.env` diabaikan Git tetapi dikemas sebagai Flutter asset. Jangan menaruh server key, token pengguna, atau rahasia lain di dalamnya.

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

## Alur pembayaran

Checkout mengirim `address_id`, kode voucher, dan catatan ke backend. Harga akhir, diskon, ongkir, dan status pembayaran berasal dari backend. Aplikasi membuka halaman Snap di browser perangkat dan membaca ulang detail pesanan ketika pelanggan kembali. Jika token belum tersedia, tombol pembayaran di detail pesanan meminta token melalui `POST /payments/{orderId}/snap-token`.

## Batasan saat ini

Katalog bundling dan custom order yang tercantum di `roadmap.md` belum mempunyai layar pelanggan. Token autentikasi disimpan melalui secure storage perangkat; versi lama yang memakai `shared_preferences` dimigrasikan saat startup. Lihat [dokumentasi.md](dokumentasi.md) untuk keputusan implementasi dan risiko yang tersisa.
