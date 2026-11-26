# Rencana redesign UI/UX Batik Rubung Kuning

Redesign mengikuti **Material 3 dengan tata letak minimalis**. Interaksi inti memakai komponen Flutter yang familiar, sementara warna emas dan foto batik membangun identitas toko. Rencana ini berdasarkan `batik_app` pada `dev` (`f82d7ed`) dan `rubung-v3` (`6044a28`).

## Audit awal

- Flutter sudah memakai Material 3, tetapi masih memakai warna langsung di 13 berkas layar dan widget. Navigasi utama memakai empat tab dalam `IndexedStack` dengan `BottomNavigationBar`. PR fondasi perlu mempertahankan state dan posisi gulir saat berpindah tab. [Tema Flutter](../lib/theme/app_theme.dart) · [Navigasi utama](../lib/views/main_view.dart)
- Landing page memberi acuan emas `#F4C430`, emas lembut `#FFF7DB`, dan teks `#252525`. Gunakan palet tersebut sebagai sumber identitas, dengan tabel dan status panel admin sebagai referensi terminologi. [CSS landing page](https://github.com/sanxnn/rubung-v3/blob/6044a28/public/css/company-profile.css) · [Dashboard admin](https://github.com/sanxnn/rubung-v3/blob/6044a28/resources/views/admin/dashboard.blade.php)
- Beranda sudah memiliki aset foto dan carousel otomatis setiap tiga detik. Redesign memberi prioritas pada pencarian, kategori, dan foto produk. Gunakan banner yang bisa digeser pengguna, dengan satu foto sebagai fallback untuk lebar sempit atau kondisi aksesibilitas. [Beranda Flutter](../lib/views/home_view.dart) · [Aset toko](../assets/images)
- Checkout menyimpan pesanan lebih dulu, membuka detail, lalu pelanggan melanjutkan ke Snap. Status bayar, resi, dan refund berasal dari Laravel. Desain progress harus membedakan langkah yang dapat dilakukan pelanggan dari status asinkron server. [Alur sistem](alur-sistem.md#checkout-dan-pembayaran)

## Arah visual

| Peran | Usulan |
| --- | --- |
| Tombol utama | Emas `#F4C430` dengan teks `#252525` (9,33:1). |
| Pilihan aktif | Emas lembut `#FFF7DB` dengan teks dan ikon `#725400` (6,56:1). |
| Permukaan dan teks | Kanvas `#FAFAF8`, kartu `#FFFFFF`, teks utama `#252525`, teks sekunder `#57534E` (7,30:1 pada kanvas). |
| Status | Hijau tua `#166534` pada `#DCFCE7` untuk sukses dan merah tua `#991B1B` pada `#FEE2E2` untuk gagal atau batal. Ikon dan label menemani warna. |
| Tipografi | **Instrument Sans** sebagai font utama, bobot 400–700. Judul layar 24–28 sp, judul bagian 18–20 sp, isi 14–16 sp. Font dibundel lokal setelah verifikasi lisensi, dengan fallback sistem. |
| Ikon dan foto | Satu keluarga ikon Material bergaya rounded. Label tab tetap terlihat. Foto produk aktual, grid dengan rasio gambar konsisten, dan fallback gambar saat API gagal. |

Skala awal memakai jarak 4/8/12/16/24/32 dp, radius 12 dp untuk kontrol dan 16–20 dp untuk kartu. Target sentuh minimal 48 × 48 dp, teks normal minimal 4,5:1, dan konten tetap dapat dipakai pada skala teks 200%. Periksa fokus, label screen reader, dan kontras indikator di kondisi aktif. [Flutter Accessibility](https://docs.flutter.dev/ui/accessibility) · [WCAG 2.2](https://www.w3.org/TR/WCAG22/)

## Keputusan interaksi

| Prinsip atau pola | Penerapan |
| --- | --- |
| Fitts dan Jakob | Empat tujuan tetap berlabel Beranda, Keranjang, Pesanan, Profil. Tombol tambah, lanjut bayar, dan konfirmasi diletakkan dekat konteks tindakan dengan area sentuh besar. |
| Hick dan Miller | Satu CTA primer per konteks. Kelompokkan checkout ke alamat dan ringkasan, dengan voucher dan catatan sebagai opsi. Gunakan pengelompokan informasi di detail pesanan. |
| Doherty dan snappy timing | Tampilkan perubahan visual saat ditekan. Target awal untuk feedback 90–140 ms, perpindahan tab 180–220 ms, dan dialog 180–240 ms. Status loading tetap terlihat saat server merespons lebih lama. |
| Peak–End dan exaggerated feedback | Untuk tindakan sukses, pakai check, pesan ringkas dan langkah berikutnya. Tambah ke keranjang mendapat konfirmasi singkat. Pesanan dianggap dibayar hanya setelah backend mencatat pembayaran sukses. |
| Sliding pill | Gunakan indikator pill pada empat tab, dimulai dari Material `NavigationBar`. Jika prototipe membutuhkan pill yang benar-benar bergeser, pertahankan semantik dan area sentuh Material. Liquid bulge dan floating notch ditunda karena empat tujuan setara dan tidak ada aksi tengah yang membutuhkan ruang sendiri. |
| Stroke morph dan spin swap | Gunakan outline → filled saat tab berubah. Untuk perubahan aksi lokal seperti plus → check, pakai swap singkat dengan fade/scale dan rotasi ringan jika menambah kejelasan. Morph jalur khusus hanya dievaluasi untuk ikon dengan bentuk yang kompatibel. |
| Rubber banding | Gunakan perilaku scroll bawaan platform. Pertahankan bounce alami pada platform yang mendukung dan jangan memaksa efek elastis pada seluruh layar. |
| Skeleton, dot loader, toast, modal pop | Skeleton mengikuti struktur kartu saat data awal dimuat. Loader kecil dengan label untuk tombol yang sedang mengirim. Snackbar untuk hasil ringan dan error inline untuk masalah yang harus diperbaiki. Dialog singkat untuk aksi yang butuh konfirmasi, seperti membatalkan pesanan. |
| Floating label | Terapkan pada login, OTP, profil, alamat, voucher, dan form refund/custom order. Label dan pesan validasi tetap terbaca saat kolom terisi. |
| Numbered steps dan segment bar | Pakai penanda ringkas **1 Alamat · 2 Tinjau · 3 Bayar** untuk alur checkout. Langkah Bayar mengarah ke detail pesanan setelah pembuatan order. Gunakan ikon lokasi, ringkasan, dan pembayaran sebagai pendamping label. |
| Order tracking | Timeline terpisah dengan milestone **Menunggu bayar → Dibayar → Diproses → Dikirim → Selesai**. `processing` dan `packing` bisa dikelompokkan di UI. `cancelled` mendapat status tersendiri. Resi muncul ketika tersedia dan refund memiliki status terpisah. |

Hormati preferensi pengurangan animasi. Transisi nonesensial menjadi instan atau sederhana, loader tetap memiliki teks yang bermakna, dan fokus tetap berada pada aksi yang relevan. [Laws of UX](https://www.oreilly.com/library/view/laws-of-ux/9781098146955/) · [Flutter NavigationBar](https://api.flutter.dev/flutter/material/NavigationBar-class.html) · [Material Motion](https://m1.material.io/motion/duration-easing.html) · [Carbon Loading](https://www.carbondesignsystem.com/building-blocks/core/patterns/loading) · [Baymard Checkout Progress](https://baymard.com/blog/progress-indicator-ui-ux) · [Flutter Reduce Motion](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)

## Urutan PR implementasi ke dev

| Tahap | Lingkup | Kriteria review |
| --- | --- | --- |
| 1. Fondasi dan navigasi | Token tema, font lokal, ikon, button, input, snackbar, empty/error/loading state, serta sliding pill di empat tab. | Preview empat tab, area sentuh dan kontras lulus, tab mempertahankan state dan scroll, Reduce Motion bekerja. |
| 2. Beranda dan katalog | Pencarian, kategori, banner manual, kartu, skeleton, detail produk dan bundle, serta CTA tambah ke keranjang. | Produk, pre-order, stok habis, pilihan varian, fallback gambar, pagination dan feedback penambahan dapat diverifikasi di Laravel lokal. |
| 3. Akun, profil dan alamat | Login, registrasi, OTP, reset, profil, serta form wilayah. | Keyboard dan skala teks tidak menutupi CTA. Pesan OTP dan field jelas. Alamat lama serta perpindahan pilihan wilayah tetap bisa diproses. |
| 4. Keranjang dan checkout | Kontrol kuantitas, ringkasan, voucher, langkah checkout, konfirmasi pembuatan pesanan, serta handoff Snap. | Pengiriman ganda dicegah, total sebelum dan sesudah submit jelas, voucher invalid dapat diperbaiki, token kosong dapat dipulihkan dari detail. |
| 5. Pesanan, refund dan custom order | Timeline, nomor resi, konfirmasi penerimaan, refund privat, lampiran, dan penawaran custom. | Tampilan sesuai status aktual server. Pembatalan, penolakan, pengajuan ulang, resi, dan konfirmasi dapat diuji dengan fixture yang sesuai. |
| 6. Regresi dan penyelesaian visual | Tinjau konsistensi lintas layar, performa animasi, fokus, scrolling, dan dokumentasi desain. | Smoke test alur transaksi lokal, `flutter analyze`, `flutter test`, cek layar sempit dan skala font, serta pengujian Android/iOS dan Snap sandbox apabila tersedia. |

Setiap tahap memakai branch fitur dan PR tersendiri ke `dev`, dengan screenshot layar yang berubah serta kondisi loading, error, dan sukses yang relevan. Mulai tahap berikutnya dari `dev` setelah tahap yang menjadi dependensinya digabung. Perubahan kontrak Laravel memerlukan keputusan terpisah jika desain menemukan kebutuhan data baru.
