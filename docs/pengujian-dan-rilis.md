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

## Data dan kondisi uji

- Gunakan akun pelanggan lokal dengan alamat, produk reguler berstok, satu varian Batik berstok nol, bundle dengan komponen tersedia, serta voucher aktif. Gunakan fixture terpisah untuk stok habis dan voucher kedaluwarsa.
- Siapkan pesanan pending, pesanan berbayar yang sudah dikirim dengan resi, serta pesanan batal dengan pembayaran sukses. Gunakan akun kedua untuk memastikan bukti refund hanya dapat diambil pemilik. Gunakan gambar contoh dan data pelanggan fiktif.
- Siapkan custom order menunggu peninjauan dan penawaran yang sudah tersedia. Verifikasi pembentukan pesanan terkait setelah memilih alamat. Pengiriman email dan pembayaran eksternal perlu lingkungan uji yang sesuai.

## Diagnosis

| Gejala | Pemeriksaan |
| --- | --- |
| Katalog gagal dimuat | Akses `GET /api/products` dari perangkat atau browser yang sama. Periksa host, prefiks `/api`, HTTPS, dan CORS jika origin berbeda. |
| OTP belum diterima | Periksa mailer Laravel. Jika memakai log lokal, cari kiriman OTP di log backend pengembangan. Gunakan kirim ulang sesuai batas percobaan. |
| Form wilayah tidak memuat pilihan berikutnya | Pastikan kode induk dikirim lengkap. Respons `503` mengindikasikan layanan wilayah sementara tidak tersedia. |
| Checkout gagal | Periksa pesan backend, stok, alamat, dan konfigurasi RajaOngkir. Jika request terputus, cek daftar pesanan dan keranjang sebelum mencoba lagi. |
| Snap terbuka tetapi status masih pending | Verifikasi token berasal dari lingkungan Midtrans yang sesuai, periksa status transaksi dan pengiriman webhook pada Laravel, lalu perbarui detail pesanan. |
| Bukti refund gagal dibuka | Periksa sesi pelanggan, kepemilikan refund, dan respons byte gambar. Hindari mencatat token, isi bukti, atau data pelanggan pada laporan masalah. |

[Indeks dokumentasi](README.md) · [Alur sistem](alur-sistem.md)

## Regresi visual

- Uji lebar 320 dp dan teks 200% pada formulir dengan keyboard terbuka, navigasi tab, dan langkah checkout.
- Pastikan isi tab mempertahankan posisi gulir, sementara fokus keyboard hanya masuk ke tab aktif. Aktifkan Reduce Motion untuk memeriksa perpindahan tab dan feedback tambah ke keranjang.
- Verifikasi status kosong, loading, gagal, sukses, dan label utama terhadap [panduan desain](panduan-desain-ui.md). Gunakan akun dan bukti fiktif untuk screenshot.
- Pengujian Web dengan simulasi RajaOngkir dan Snap mencakup integrasi aplikasi dengan Laravel lokal. Pengujian provider Midtrans sandbox dan perangkat Android/iOS dilakukan secara terpisah sebelum rilis.
