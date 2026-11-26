# Pengembangan, pengujian, dan rilis

## Menjalankan Flutter dan Laravel lokal

1. Gunakan Flutter dengan Dart yang memenuhi [pubspec.yaml](../pubspec.yaml). Jalankan `flutter doctor` untuk memeriksa toolchain target.
2. Jalankan Laravel, migrasi, dan seed data sesuai panduan backend. Gunakan akun uji, database pengembangan, serta konfigurasi email lokal. Untuk checkout, backend memerlukan ongkir yang berfungsi dan konfigurasi Midtrans sesuai lingkungan.
3. Sesuaikan `API_BASE_URL` dalam `.env` Flutter. Gunakan `http://127.0.0.1:8000/api` untuk browser di mesin Laravel. Emulator Android standar menggunakan `10.0.2.2` untuk host. Perangkat fisik memerlukan alamat yang bisa dijangkau dari perangkat. Jika platform menolak koneksi HTTP, gunakan endpoint HTTPS pengembangan atau pengaturan transport khusus debug.
4. Jalankan aplikasi dengan lingkungan pembayaran sandbox. [Panduan menjalankan Laravel](https://github.com/sanxnn/rubung-v3#menjalankan-lokal)

```bash
flutter pub get
flutter run --dart-define=MIDTRANS_ENV=sandbox
```

Untuk uji browser lokal, pilih target Chrome atau jalankan `flutter run -d web-server --dart-define=MIDTRANS_ENV=sandbox`. Untuk backend di origin berbeda, verifikasi CORS mencakup origin browser dan request berautentikasi. `.env` dilacak Git dan dikemas dalam build. Perubahan URL lokal dapat disimpan di salinan kerja. Kunci dan token rahasia berada di luar aset aplikasi.

## Tes otomatis

```bash
flutter analyze
flutter test
```

Suite ada di [test](../test) dan mencakup pagination katalog serta pesanan, parsing subtotal keranjang, payload checkout, token dan URL Snap, validasi voucher, konfirmasi penerimaan, kelayakan refund, dan nama field multipart untuk refund serta lampiran custom. Tes service memakai respons Dio simulasi. Jalankan uji integrasi backend dan pengujian pada perangkat untuk memeriksa layanan eksternal, dialog pemilihan berkas, serta perpindahan aplikasi dan browser.

## Skenario uji sebelum rilis

| Skenario | Yang diperiksa |
| --- | --- |
| Akun dan OTP | Daftar, verifikasi atau kirim ulang OTP, login, ubah email, reset kata sandi, dan logout. Ulangi startup dengan token kedaluwarsa atau verifikasi tertunda. |
| Katalog dan keranjang | Ganti filter saat memuat, lanjutkan pagination, pilih varian reguler atau bundle, uji pre-order Batik dan stok habis, lalu ubah jumlah dan hapus item. |
| Alamat | Buat alamat hingga kelurahan, ganti induk wilayah, ubah alamat lama menjadi berkode, dan tetapkan alamat utama. |
| Voucher dan checkout | Uji voucher valid, tidak ditemukan, dan kuota habis. Bandingkan pratinjau subtotal dengan total final server yang mencakup promo dan ongkir. Uji pemulihan ketika token Snap kosong. |
| Pembayaran dan pengiriman | Uji Snap sandbox berhasil, gagal, atau ditinggalkan. Muat ulang detail saat kembali. Uji pembatalan pesanan pending, resi, dan konfirmasi paket yang sudah dibayar serta dikirim. |
| Refund | Ajukan bukti valid dan uji berkas yang ditolak. Periksa detail, akses bukti dengan akun pemilik, status admin, pembatalan pending, dan pengajuan ulang setelah ditolak atau dibatalkan. |
| Custom order | Buat permintaan dengan lampiran. Tambah lampiran saat peninjauan, tampilkan penawaran admin, pilih alamat, dan periksa order terkait. Uji pembatalan sebelum persetujuan. |

Gunakan [koleksi Postman backend](https://github.com/sanxnn/rubung-v3/tree/main/docs/api-testing) untuk mengisolasi masalah API dan menyiapkan kondisi yang memerlukan aksi admin.

## Build rilis

1. Gunakan HTTPS production pada `API_BASE_URL`. Cocokkan `MIDTRANS_ENV` dengan backend yang menerbitkan token. Nilai bawaan Flutter adalah `sandbox`.
2. Tetapkan identitas aplikasi, ikon, versi, dan signing tim. Konfigurasi Android saat ini masih memakai ID contoh dan debug signing untuk build release. Siapkan juga provisioning dan signing iOS melalui Xcode.
3. Jalankan tes serta pemeriksaan perangkat, lalu buat artefak sesuai target. Pastikan konfigurasi jaringan debug hanya berlaku di build pengembangan.

```bash
flutter build appbundle --release --dart-define=MIDTRANS_ENV=production
flutter build ipa --release --dart-define=MIDTRANS_ENV=production
```

Validasi rilis di Android dan iOS untuk secure storage, pemilihan foto, pembukaan Snap, dan pembacaan status pembayaran saat aplikasi aktif kembali.
