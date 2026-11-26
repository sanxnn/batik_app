# Panduan fitur aplikasi pelanggan

## Akun dan profil

1. Daftar dengan identitas pelanggan, email, dan kata sandi. Masukkan OTP dari email. Setelah verifikasi berhasil, aplikasi kembali ke layar Login.
2. Jika kode belum diterima, gunakan kirim ulang OTP. Alur lupa kata sandi memverifikasi OTP reset untuk memperoleh token reset, lalu meminta kata sandi baru dan konfirmasinya.
3. Buka **Profil** untuk mengubah identitas. Perubahan email memerlukan verifikasi email baru. Gunakan **Keluar** untuk mengakhiri sesi.

## Katalog, bundling, dan stok

- **Beranda** menampilkan kategori, produk reguler, dan paket. Banner dapat digeser atau dipindah dengan tombol panah. Pencarian dan penggantian filter memuat kembali halaman pertama. Gunakan **Muat produk lainnya** atau **Muat paket lainnya** untuk meneruskan daftar.
- Detail produk memuat ulang informasi varian. Pilih varian dan jumlah sebelum menambah ke keranjang. Varian reguler kategori Batik dengan stok nol dapat mengikuti pre-order. Varian kategori lain membutuhkan stok.
- Detail bundle menampilkan harga, stok paket, dan komponen untuk varian yang dipilih. Tombol tambah tersedia saat varian terpilih memiliki stok. Laravel menghitung stok bundle berdasarkan persediaan komponen.
- Aplikasi belum menyediakan daftar favorit.

## Alamat dan keranjang

- Buka **Profil → Alamat Saya**, atau **Kelola alamat** dari Checkout. Pelanggan bisa menambah, mengubah, menghapus, dan menetapkan alamat utama.
- Isi penerima, telepon, detail jalan, dan kode pos lima digit. Pilih provinsi, kabupaten/kota, kecamatan, lalu desa/kelurahan. Mengubah wilayah induk akan mengosongkan pilihan di bawahnya. Alamat lama tetap dapat dipakai saat checkout. Saat mengedit alamat lama tanpa kode wilayah, pilih hierarki wilayah sebelum menyimpan.
- **Keranjang** menampilkan item server beserta harga dan jumlah. Pelanggan bisa mengubah jumlah, menghapus item, atau mengosongkan keranjang. Stok dapat berubah sebelum checkout. Jika server menolak jumlah, baca pesan lalu sesuaikan item atau varian.

## Checkout dan pembayaran

1. Di langkah **Alamat**, pilih alamat pengiriman dan tekan **Tinjau pesanan**. Jika ada voucher, masukkan kode dan tekan **Cek voucher**. Pratinjau menunjukkan potongan dan subtotal setelah voucher. Promo tanggal dan ongkir dihitung saat pembuatan pesanan.
2. Tambahkan catatan jika perlu, lalu pilih **Buat pesanan**. Aplikasi membuka langkah **Bayar** di detail pesanan setelah server membuat pesanan dan menampilkan total akhir.
3. Tekan **Lanjutkan pembayaran** untuk membuka Snap. Tombol dapat meminta token baru jika token belum tersedia. Setelah kembali ke aplikasi, periksa status. Gunakan tombol perbarui jika notifikasi Midtrans masih diproses.
4. Untuk pesanan yang masih menunggu pembayaran, buka **Batalkan pesanan** dari detail. Jika pembatalan belum dikonfirmasi, periksa status terbaru sebelum mencoba kembali.

## Pesanan dan refund

- **Pesanan Saya** berisi daftar berhalaman. Detail menampilkan barang, penerima, rincian biaya, status pembayaran, kurir, serta perjalanan pesanan dari menunggu bayar hingga selesai. Nomor resi bisa disalin ketika tersedia.
- Tekan **Konfirmasi pesanan diterima** setelah paket sampai. Aksi tersedia untuk pesanan berstatus `shipped` dengan pembayaran `success`. Backend kemudian menandai pesanan `completed`.
- Pada pesanan yang memenuhi syarat, buka **Ajukan refund**. Isi alasan 20–2.000 karakter dan pilih satu foto JPEG, PNG, atau WebP maksimal 5 MB. Laravel menentukan nominal dari pembayaran.
- Pantau hasil melalui **Status refund** di detail pesanan atau **Riwayat refund** di layar Pesanan. Detail menampilkan alasan, bukti, status, dan catatan admin apabila tersedia. Pelanggan bisa membatalkan pengajuan selama berstatus `pending`.
- Pelanggan dapat mengajukan kembali setelah pengajuan sebelumnya ditolak atau dibatalkan jika pesanan masih memenuhi syarat. Pembayaran yang berhasil setelah pesanan batal juga dapat diajukan untuk refund. [Aturan lengkap refund](alur-sistem.md#status-refund)

## Custom order

1. Dari **Profil**, buka **Custom Order**. Tulis spesifikasi minimal 10 karakter dan pilih lampiran bila perlu. Sistem menerima hingga lima gambar JPEG, PNG, atau WebP, maksimal 2 MB per gambar.
2. Pantau pengajuan di **Riwayat custom order**. Saat menunggu peninjauan, pelanggan masih dapat menambah lampiran selama batas total terpenuhi.
3. Saat penawaran tersedia, buka kartu untuk melihat estimasi harga, waktu, dan catatan admin. Pilih **Setujui penawaran**, tentukan alamat, lalu konfirmasi. Laravel membuat pesanan terkait untuk dibayar melalui alur Snap.
4. Pengajuan dapat dibatalkan saat menunggu peninjauan atau ketika penawaran tersedia. Setelah penawaran disetujui, gunakan detail pesanan terkait untuk pembayaran dan aksi pesanan yang tersedia.

[Peta endpoint per fitur](referensi-integrasi-api.md) · [Alur dan status sistem](alur-sistem.md)

## Akses menu dan batasan antarmuka

| Aksi | Lokasi dan perilaku saat ini |
| --- | --- |
| Buka riwayat pesanan | Gunakan tab **Pesanan** pada navigasi bawah atau pilih **Pesanan saya** di Profil. |
| Buka riwayat refund | Gunakan ikon **Riwayat refund** pada bilah atas tab **Pesanan**. |
| Buka detail paket | Pilih kartu pada bagian paket di **Beranda**, lalu pilih varian untuk menampilkan komponen dan membeli. |
| Cari produk | Pencarian di **Semua** mencakup produk reguler dan paket. Filter **Bundling** menampilkan daftar paket. Kategori produk reguler memakai filter kategori yang tersedia di UI. |
| Kelola bantuan atau favorit | Bantuan & FAQ dan favorit belum tersedia di aplikasi. |
