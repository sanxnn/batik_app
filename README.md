# Batik Rubung Kuning — aplikasi pelanggan

Aplikasi Flutter untuk katalog, akun pelanggan, alamat, keranjang, checkout, pembayaran Midtrans, dan riwayat pesanan. Kontrak integrasi mengikuti [referensi API backend](https://github.com/sanxnn/rubung-v3/blob/main/docs/api-reference.md). Panduan arsitektur aplikasi ada di [dokumentasi.md](dokumentasi.md).

## Persyaratan

- Flutter dengan Dart SDK yang memenuhi `pubspec.yaml` (`^3.13.1`).
- Untuk build Android: JDK lengkap yang menyediakan `javac`, Android SDK, dan signing release milik tim.
- Backend Laravel API yang sesuai dengan `roadmap.md`.
- Untuk uji pembayaran: akun dan konfigurasi Midtrans sandbox di backend. Production memerlukan konfigurasi Midtrans production di backend.

## Menjalankan aplikasi

1. Salin `.env.example` menjadi `.env`. Endpoint bawaan mengarah ke `https://batikrubungkuning.sanxnn.my.id/api`. Untuk pengembangan lokal saja, ubah `API_BASE_URL` ke host backend lokal yang sesuai perangkat.
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

## Alur pembayaran

Checkout mengirim `address_id`, kode voucher, dan catatan ke backend. Harga akhir, diskon, ongkir, dan status pembayaran berasal dari backend. Aplikasi membuka halaman Snap di browser perangkat dan membaca ulang detail pesanan ketika pelanggan kembali. Jika token belum tersedia, tombol pembayaran di detail pesanan meminta token melalui `POST /payments/{orderId}/snap-token`.

## Alur pelanggan lainnya

Pelanggan memilih wilayah hingga desa atau kelurahan dan mengisi kode pos. Di checkout, pratinjau voucher menampilkan potongan dan subtotal setelah voucher.

Detail pesanan menampilkan kurir dan resi, konfirmasi penerimaan untuk pesanan berbayar yang sudah dikirim, dan aksi refund sesuai status pesanan dan pembayaran. Riwayat pesanan menyediakan akses ke riwayat refund. Custom order mendukung lampiran, peninjauan penawaran, dan pemilihan alamat sebelum pembayaran.

Token autentikasi disimpan melalui secure storage perangkat. Token dari versi lama yang memakai `shared_preferences` dimigrasikan saat startup.
