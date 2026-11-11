# Dokumentasi aplikasi pelanggan

## Struktur

- `lib/core/network`: konfigurasi Dio, URL gambar, dan pembuka pembayaran Snap.
- `lib/core/utils`: pemetaan error API.
- `lib/models`: parsing data akun, katalog, alamat, keranjang, dan pesanan.
- `lib/services`: request HTTP dan parsing respons; tidak memiliki state UI.
- `lib/controllers`: state layar dan operasi asinkron menggunakan `ChangeNotifier`.
- `lib/views`: layar pelanggan; widget terpakai ulang ada di `lib/widgets`.

Nama berkas alamat sudah diseragamkan menjadi `address_*`. Kontrak endpoint dan contoh payload ada di [roadmap.md](roadmap.md).

## Alur utama

1. Saat startup token lama dipindahkan sekali dari `shared_preferences` ke secure storage perangkat. Splash memeriksa token melalui `/auth/me`. Akun yang belum memverifikasi email menerima alamat email pada layar OTP.
2. Beranda memuat kategori dan produk. Pencarian/kategori memulai halaman pertama; tombol muat lagi membaca halaman berikutnya. Respons request lama diabaikan ketika filter berubah. Detail produk memuat ulang `GET /products/{id}` saat dibuka.
3. Detail produk menambah `product_variant_id` dan `quantity` ke keranjang. Keranjang membaca data terbaru dari server.
4. Checkout memilih alamat, menampilkan subtotal keranjang, lalu mengirim `POST /orders`. Aplikasi tidak mengirim harga atau ongkir. Respons order disimpan agar detail tetap dapat dibuka jika token pembayaran belum tersedia.
5. Detail order membuka halaman Snap menggunakan token pembayaran. Ketika aplikasi aktif lagi, detail order meminta status terbaru dari backend. Tombol perbarui tersedia; callback browser bukan sumber status final.
6. Riwayat mengambil `GET /orders` secara berhalaman. Pembatalan hanya ditawarkan saat `pending_payment`.

## Konfigurasi

`API_BASE_URL` berasal dari `.env`, misalnya `https://batikrubungkuning.sanxnn.my.id/api`. URL gambar dibentuk dari base URL yang sama dan path `storage-image/{image}`. `MIDTRANS_ENV` diset saat build memakai `--dart-define`, bernilai `sandbox` (default) atau `production`. Jangan mencampur token sandbox dan URL production.

Halaman Snap dibuka di browser perangkat agar pengalihan ke aplikasi bank/e-wallet dapat dilakukan oleh sistem. Format URL mengikuti Snap Redirect Midtrans. Pastikan konfigurasi URL redirection Finish, Unfinish, dan Error di dashboard Midtrans sesuai kebutuhan deployment.

## Pengujian

- `flutter analyze`
- `flutter test`
- Uji manual dengan backend dan Midtrans sandbox: OTP, login, katalog dengan lebih dari satu halaman, tambah/ubah/hapus keranjang, alamat utama, voucher valid/tidak valid, checkout saat stok berubah, token pembayaran kosong, pembayaran sukses/gagal, pembatalan pending, dan kembali dari browser pembayaran.

Tes otomatis saat ini mencakup parsing keranjang, pagination katalog dan pesanan, payload checkout, bentuk token pembayaran, serta URL Snap. Respons backend nyata perlu diuji di lingkungan staging karena `roadmap.md` adalah dokumentasi kontrak, bukan server yang dijalankan oleh tes.

## Batasan dan pekerjaan berikutnya

- Bundling dan custom order di backend belum ditampilkan dalam UI Flutter.
- Integrasi secure storage perlu diuji pada perangkat Android/iOS fisik. Web dan desktop mempunyai persyaratan penyimpanan kunci tersendiri; rilis utama ditujukan untuk mobile.
- Harga dan stok dapat berubah sesudah detail produk dibuka. Backend tetap memutuskan validitas stok dan total akhir saat checkout.
- Navigasi dan tampilan status pembayaran perlu diuji pada Android/iOS fisik bersama metode pembayaran yang digunakan toko.
