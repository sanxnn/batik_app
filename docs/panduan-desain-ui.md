# Panduan desain UI Flutter

Batik Rubung Kuning memakai Material 3 dengan palet emas dan tata letak minimalis. Foto katalog menjadi fokus pada layar belanja. Layar transaksi memberi prioritas pada nominal, status, dan tindakan berikutnya.

## Tema dan komponen

| Elemen | Penerapan |
| --- | --- |
| Warna utama | Emas `#F4C430` dengan teks `#252525` untuk aksi primer. Emas lembut `#FFF7DB` dengan tinta `#725400` untuk pilihan aktif. |
| Permukaan | Kanvas `#FAFAF8`, kartu `#FFFFFF`, dan garis dekoratif `#E7E5E4`. Kontrol aktif memakai garis `#918576` untuk membantu membedakan batas input. |
| Tipografi | Instrument Sans dibundel dengan bobot 400, 500, 600, dan 700. Pilih gaya dari `TextTheme` agar ukuran mengikuti pengaturan sistem. |
| Status | Pasangkan warna dengan label dan ikon. Gunakan **Total pesanan** sebelum pembayaran sukses dan **Total dibayar** setelah konfirmasi backend. |
| Formulir | Gunakan floating label yang tetap terbaca setelah kolom terisi, pesan validasi di dekat input, serta tombol yang menunjukkan proses. |
| Data dan kegagalan | Gunakan skeleton untuk pemuatan awal katalog, indikator berlabel untuk aksi atau pembaruan, fallback saat gambar tidak tersedia, dan aksi coba lagi saat relevan. |

Gunakan [AppTheme](../lib/theme/app_theme.dart) untuk token. Foto katalog dan lampiran custom order memakai [CatalogImage](../lib/widgets/catalog/catalog_image.dart). Bukti refund dimuat lewat service berautentikasi dan ditampilkan dari byte di memori.

## Navigasi, fokus, dan motion

- Empat tujuan utama tetap berlabel. Material 3 `NavigationBar` memberi indikator pill pada tab aktif. `IndexedStack` mempertahankan state serta posisi gulir, dan tab tersembunyi dikecualikan dari fokus keyboard.
- Animasi tab berdurasi 200 ms. Pergantian ikon pada tombol tambah ke keranjang berdurasi 120 ms dan menampilkan tanda centang setelah sukses. Saat Reduce Motion aktif, indikator tab dan ikon berpindah tanpa animasi.
- Banner memakai geser manual dan tombol panah. Pada layar sempit atau ketika Reduce Motion aktif, tampilkan satu banner statis.
- Gunakan prinsip area sentuh minimal 48 dp untuk kontrol utama. Uji label yang panjang, navigasi keyboard, dan teks 200% pada layar sempit.

## Alur transaksi

1. Keranjang menampilkan item dan subtotal. Promo serta ongkir akhir dihitung saat pesanan dibuat oleh Laravel.
2. Checkout menampilkan **Alamat → Tinjau → Bayar**. Tinjau dapat menampilkan pratinjau voucher. Langkah Bayar mengambil total final dari detail pesanan.
3. Timeline pengiriman mengikuti status pesanan dari Laravel. Tampilkan keadaan pembatalan terpisah. Kelayakan refund mengikuti kombinasi status pesanan dan pembayaran, serta riwayat refund.
4. Pesanan custom mengikuti proses permintaan, penawaran, dan persetujuan alamat sebelum terbentuk pesanan yang dapat dibayar.

Lihat [panduan fitur](fitur.md), [alur sistem](alur-sistem.md), dan [skenario uji](pengujian-dan-rilis.md).
