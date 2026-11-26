# Rencana redesign UI Batik Rubung Kuning

## Audit

Project memakai Provider/ChangeNotifier, route bernama di `lib/main.dart`, dan `MaterialPageRoute` untuk halaman detail. Theme berada di `lib/theme/app_theme.dart`; widget di `lib/widgets/`. `google_fonts` sudah ada di `pubspec.yaml`. Tidak ada `AGENTS.md` di folder project.

| File view | Fungsi |
| --- | --- |
| `splash_view.dart` | Startup dan sesi |
| `auth/login_view.dart` | Login |
| `auth/register_view.dart` | Registrasi |
| `auth/forgot_password_view.dart` | Permintaan OTP reset |
| `auth/reset_password_otp_view.dart` | Verifikasi OTP reset |
| `auth/reset_password_view.dart` | Password baru |
| `auth/verify_email_view.dart` | Verifikasi email |
| `main_view.dart` | Empat tab utama |
| `home_view.dart` | Katalog, cari, kategori, banner, bundle |
| `product_detail.dart` | Detail dan varian produk |
| `bundle_detail_view.dart` | Detail dan varian bundle |
| `cart_view.dart` | Cart |
| `checkout_view.dart` | Checkout |
| `order_view.dart` | Riwayat pesanan |
| `order_detail_view.dart` | Detail, bayar, batal |
| `profile_view.dart` | Menu akun dan logout |
| `edit_profile_view.dart` | Edit akun |
| `address_view.dart` | Alamat |
| `form_address_view.dart` | Form alamat |
| `custom_order_view.dart` | Custom order |

Widget existing: auth button/layout/field, cart item/quantity/summary, home search, product card, network image, section/state view, dan motif accent. Dialog existing: logout, hapus cart/alamat, batal order/custom order, dan persetujuan quotation.

## Tahap A

1. Pisahkan warna, tipografi, spacing, radius, shadow; susun ThemeData Material 3.
2. Buat/rapikan komponen Home: search, banner asset existing, kategori, heading section, product card/grid, image fallback, loading/empty/error.
3. Rombak Home. Sapaan memakai data `AuthController`; produk, kategori, bundle, cart memakai controller existing. Pertahankan semua aksi.
4. Format, analyze, test, audit diff dan hardcode; berhenti menunggu persetujuan.

## Tahap B (hanya setelah persetujuan eksplisit)

Kelompok 1: splash dan autentikasi. Kelompok 2: detail produk/bundle dan cart. Kelompok 3: checkout, alamat, order, custom order. Kelompok 4: profil dan edit profil. Widget tambahan dibuat saat dibutuhkan kelompok tersebut.

## Risiko dan keputusan

- Worktree sebelum Tahap A sudah berisi perubahan presentation serta `cart_controller.dart` dan `auth_service.dart` dari pekerjaan sebelumnya. Tahap A tidak mengedit logic tersebut.
- Tidak ada data notifikasi, rating, review, diskon, atau unggulan khusus pada model Home. Elemen itu disembunyikan.
- Aplikasi punya empat tab, sehingga referensi lima tab diterapkan sebagai empat tab existing.
- Banner asset tidak memiliki target kampanye; carousel menampilkan gambar saja, tanpa teks atau CTA tambahan.
- Screenshot ponsel memerlukan emulator/device. Bila tidak ada, pengujian widget pada ukuran layar berbeda menjadi pengganti pemeriksaan layout otomatis.

## Checklist uji manual Tahap A (`flutter run`)

- Buka Home di ponsel kecil dan besar; pastikan header, banner, kategori, kartu, dan tab tidak overflow pada text scale 1,3.
- Periksa loading awal, katalog terisi, tanpa hasil pencarian, serta kegagalan jaringan dan tombol retry.
- Cari produk, hapus kata kunci, pilih kategori dari baris maupun ikon filter, dan reset pilihan.
- Geser banner; pastikan keempat gambar tampil tanpa teks atau tombol di atasnya.
- Buka detail produk dan bundle; tambah produk ke cart lalu cek badge header dan tab.
- Pindah antar empat tab dan kembali ke Home; pastikan posisi dan state pencarian tetap wajar.

## Hasil Tahap B

Inventaris layar tetap sama. Home dan empat tab utama tetap mengikuti hasil Tahap A; pencarian, kategori, serta filter memang berada di Home. Layar splash dan enam layar autentikasi memakai layout brand serta kontrol bersama. Detail produk, detail bundle, keranjang, checkout, riwayat/detail pesanan, profil, edit profil, daftar/form alamat, dan custom order memakai warna, tipografi, jarak, radius, kartu, tombol, serta state dari theme Home.

Komponen presentasi yang ditambahkan: `AppAppBar`, `AppCard`, `AppMenuTile`, `StatusChip`, dan `OrderCard`. Widget autentikasi dan keranjang existing dirapikan. `lib/widgets/category/category_chip.dart` dihapus karena tidak lagi dipakai oleh view mana pun. Tidak ada dependency baru. Aksi favorit di detail produk yang sebelumnya hanya menampilkan snackbar tanpa menyimpan data dihapus. Rating, ulasan, diskon, wishlist, halaman voucher, notifikasi, pengaturan, dan tracking terpisah tidak ada pada inventaris/model sehingga tidak dibuat. Ongkir dan diskon final tetap tampil setelah dihitung server; UI checkout tidak membuat angka perkiraan.

Verifikasi: `flutter pub get`, `dart format .` (0 file berubah pada pemeriksaan akhir), `flutter analyze` (0 temuan), dan `flutter test` (16 lulus). Test Tahap B memeriksa kartu keranjang/pesanan pada 360 dan 430 dp dengan skala teks 1,3, layout auth pada layar kecil, serta state normal/loading/kosong/error daftar pesanan. Pemeriksaan visual pada emulator/device dan alur API/Midtrans nyata masih perlu uji manual; tidak ada build APK.

## Checklist uji manual Tahap B (`flutter run`)

- Splash: animasi dan arah sesi menuju login, verifikasi, atau Home sesuai akun.
- Login: validasi kosong/email, tampil/sembunyi password, gagal/berhasil masuk, tautan daftar dan lupa password.
- Register: semua field, pilihan gender/tanggal, validasi, submit, dan navigasi verifikasi email.
- Lupa password, OTP reset, password baru, verifikasi email: validasi, kirim ulang, feedback error/sukses, serta kembali ke login.
- Home/katalog: pencarian, filter kategori, banner, produk, bundle, loading, kosong, error, refresh, dan empat tab seperti checklist Tahap A.
- Detail produk/bundle: gambar gagal/berhasil, nama panjang, varian, stok/pre-order, jumlah, tambah ke keranjang, refresh bundle.
- Keranjang: loading/kosong/error, tambah/kurangi jumlah, hapus satu/semua, subtotal, dan lanjut checkout.
- Checkout: alamat kosong/terpilih, kelola alamat, voucher/catatan, validasi tombol, biaya akhir dari server, dan pembuatan pesanan.
- Pesanan/detail: loading/kosong/error, muat halaman berikutnya, status, refresh, item/rincian biaya, batal, pembayaran Midtrans sandbox, lalu perbarui status setelah kembali.
- Profil/edit profil: data panjang, semua menu, validasi profil, perubahan email yang perlu verifikasi, dan dialog logout.
- Alamat/form alamat: loading/kosong/error, tambah/edit/hapus, alamat utama, validasi kode pos dan field wajib.
- Custom order: deskripsi minimal, daftar dan status, quotation, persetujuan/batal, alamat sebelum persetujuan, dan buka detail pesanan.
- Ulangi pada lebar sekitar 360 dp dan layar lebih besar dengan text scale 1,3; periksa keyboard, scroll, tombol bawah, dan tidak ada overflow.
