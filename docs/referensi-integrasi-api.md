# Referensi integrasi API Flutter

Halaman ini memetakan pemakaian API di aplikasi. Contoh payload lengkap dan aturan validasi server tersedia di [referensi API Laravel](https://github.com/sanxnn/rubung-v3/blob/main/docs/api-reference.md).

## Dasar request

- Semua path pada tabel relatif terhadap `API_BASE_URL`, termasuk prefiks `/api` pada nilainya. Contoh lokal untuk browser di mesin backend adalah `http://127.0.0.1:8000/api`.
- Katalog dan wilayah adalah endpoint publik. Profil, alamat, keranjang, pesanan, pembayaran pelanggan, refund, serta custom order membutuhkan `Authorization: Bearer <token>`. Endpoint OTP dan login dapat dipanggil sebelum pelanggan masuk.
- Gunakan ID dari respons server. ID produk memilih detail katalog, ID varian memilih barang yang ditambahkan, dan ID item keranjang memilih baris yang diubah atau dihapus. Custom order dan refund memiliki ID terpisah dari pesanan.
- Tampilkan harga dalam Rupiah. Payload checkout hanya membawa data yang dipilih pelanggan. Harga, ongkir, kuota, dan status berasal dari Laravel.

## Endpoint menurut service

| Service | Metode dan path | Pemakaian |
| --- | --- | --- |
| [AuthService](../lib/services/auth_service.dart) | `POST /auth/register`, `POST /auth/login`, `GET /auth/me`, `PUT /auth/profile`, `POST /auth/logout` | Registrasi, sesi, profil, dan logout. |
| AuthService | `POST /auth/email/verify`, `POST /auth/email/resend`, `POST /auth/password/forgot`, `POST /auth/password/verify-otp`, `POST /auth/password/reset` | Verifikasi email, pengiriman kode, dan reset kata sandi. |
| [ProductService](../lib/services/product_service.dart) | `GET /categories`, `GET /products`, `GET /products/{id}` | Kategori beserta subkategori, pencarian dan filter, serta detail produk. |
| [BundleService](../lib/services/bundle_service.dart) | `GET /bundles`, `GET /bundles/{id}` | Daftar paket dan detail varian beserta komponen. |
| [AddressService](../lib/services/address_service.dart) | `GET /regions/provinces`, `GET /regions/regencies/{provinceCode}`, `GET /regions/districts/{cityCode}`, `GET /regions/villages/{districtCode}` | Isi pilihan wilayah berjenjang dengan nilai `code` dan `name`. |
| AddressService | `GET\|POST /addresses`, `GET\|PUT\|DELETE /addresses/{id}`, `PATCH /addresses/{id}/primary` | Kelola alamat. Form mengirim empat kode wilayah sebagai string dan kode pos lima digit. |
| [CartService](../lib/services/cart_service.dart) | `GET\|DELETE /cart`, `POST /cart/items`, `PUT\|DELETE /cart/items/{cartItemId}` | Tambah memakai `product_variant_id` dan `quantity`. Ubah jumlah atau hapus memakai ID item. |
| [OrderService](../lib/services/order_service.dart) | `POST /vouchers/validate` | Body `code`. Aplikasi membaca `code`, `discount`, dan `subtotal_after_voucher` dari `data`. |
| OrderService | `GET\|POST /orders`, `GET /orders/{id}`, `POST /orders/{id}/cancel`, `POST /orders/{id}/complete` | Riwayat, checkout, detail, pembatalan, dan konfirmasi penerimaan. |
| OrderService | `POST /payments/{orderId}/snap-token` | Minta token Snap untuk pesanan yang masih menunggu pembayaran. |
| [RefundService](../lib/services/refund_service.dart) | `POST /orders/{orderId}/refund`, `GET /refunds`, `GET /refunds/{id}`, `GET /refunds/{id}/evidence`, `POST /refunds/{id}/cancel` | Pengajuan multipart dengan `reason` dan `evidence`, riwayat, detail, bukti privat, dan pembatalan. |
| [CustomOrderService](../lib/services/custom_order_service.dart) | `GET\|POST /custom-orders`, `GET /custom-orders/{id}`, `POST /custom-orders/{id}/attachments`, `POST /custom-orders/{id}/approve`, `POST /custom-orders/{id}/cancel` | Pengajuan dengan `description`, unggahan berulang pada `attachments[]`, penawaran, dan pembatalan. |
| [Pembentuk URL gambar](../lib/core/network/image_url.dart) | `GET /storage-image/{path}` | Gambar katalog dan lampiran custom order dari path relatif. |

## Bentuk respons yang penting

| Operasi | Field yang dipakai |
| --- | --- |
| Produk berhalaman | Item di `data.data`. Halaman dari `data.current_page` dan `data.last_page`. |
| Bundling, pesanan, custom order | Item di `data`, halaman dari `meta.current_page` dan `meta.last_page`. |
| Riwayat refund | Item di `data`; `links.next` menentukan apakah halaman selanjutnya tersedia. |
| Checkout | Pesanan di `data.order`, token opsional di `data.payment.snap_token`. |
| Detail pesanan | `data.pricing`, `data.shipping`, `data.address`, `data.payment`, serta `data.refund` jika dikembalikan backend. |
| Persetujuan custom order | `data.id` adalah ID pesanan yang terbentuk. |
| Bukti refund | Byte gambar dari request yang menyertakan token pemilik. |

## Respons gagal

- `401` menghapus token pada klien. Login kembali jika sesi berakhir.
- `403` dapat muncul ketika email belum diverifikasi atau akses ditolak. `404` dapat berarti data tidak ditemukan atau tidak dimiliki akun yang aktif.
- `422` memuat pesan validasi atau aturan bisnis. Periksa `message` dan `errors` sebelum mengirim ulang.
- `409` saat membatalkan pembayaran memerlukan pemeriksaan status terbaru sebelum mencoba kembali.
- `429` dapat muncul saat terlalu sering meminta OTP atau mencoba login. `503` pada wilayah berarti data wilayah sementara tidak tersedia.

Webhook Midtrans ditangani Laravel. Flutter membaca status melalui detail pesanan. [Alur sistem](alur-sistem.md) · [Koleksi Postman backend](https://github.com/sanxnn/rubung-v3/tree/main/docs/api-testing)

## Cakupan integrasi saat ini

Aplikasi menerima pratinjau voucher dari backend. Pratinjau total checkout yang sekaligus mencakup ongkir dan promo tanggal belum tersedia. Form checkout meminta pesanan dibuat sebelum menampilkan rincian total final. Referensi Laravel juga mencatat keterbatasan katalog seperti pengurutan menurut harga atau stok dan daftar voucher publik. [Batas integrasi Laravel](https://github.com/sanxnn/rubung-v3/blob/main/docs/api-reference.md#batas-integrasi)

## Contoh request dan pemetaan model

Contoh berikut memakai ID dan nominal ilustrasi. Tambahkan prefiks dari `API_BASE_URL` dan token Bearer apabila endpoint memerlukannya.

| Operasi | Payload aplikasi |
| --- | --- |
| Tambah item | JSON `{"product_variant_id":41,"quantity":2}`. Berlaku untuk varian produk reguler dan bundle. |
| Ubah jumlah | JSON `{"quantity":3}` ke alamat endpoint dengan ID item keranjang. |
| Buat alamat | JSON berisi `label`, `recipient_name`, `phone`, `province_code`, `city_code`, `district_code`, `village_code`, `postal_code`, `detail`, dan `is_primary`. Kode wilayah dan kode pos memakai string. |
| Pratinjau voucher | JSON `{"code":"BATIKHEMAT"}`. Laravel menilai voucher terhadap keranjang pelanggan. |
| Buat pesanan | JSON `{"address_id":8,"voucher_code":"BATIKHEMAT","notes":"Jangan dilipat"}`. Field voucher dan catatan dapat dihilangkan. |
| Minta refund | Multipart dengan satu field teks `reason` dan satu file `evidence`. |
| Buat custom order | JSON `{"description":"Batik tulis motif bunga untuk acara keluarga"}` jika tanpa lampiran. Jika ada file, multipart dengan `description` dan field berulang `attachments[]`. |
| Setujui penawaran | JSON `{"address_id":8,"notes":"Warna biru tua"}`. Respons merujuk ke pesanan untuk pembayaran. |

| Model | Kontrak yang perlu dipertahankan |
| --- | --- |
| [UserModel](../lib/models/user_model.dart) | Status verifikasi dibaca dari `email_verified_at`. Registrasi dan edit profil mengirim tanggal lahir sebagai `YYYY-MM-DD`. |
| [CartModel](../lib/models/cart_model.dart) | `data.items[].id` adalah ID item. Informasi varian mencakup harga, stok, dan `is_bundle`. |
| [OrderModel](../lib/models/order_model.dart) | `id` dipakai di endpoint. `order_number` ditampilkan. `pricing.final_amount` menyimpan total dan `shipping.resi_number` menyimpan nomor resi. |
| [RefundModel](../lib/models/refund_model.dart) | Ringkasan refund dari detail pesanan dapat memuat hanya ID, status, dan nominal. Layar detail meminta data refund lengkap dan memuat bukti terpisah. |
| [CustomOrderModel](../lib/models/custom_order_model.dart) | `reference_number` mengidentifikasi permintaan di UI, `attachments[].file_path` menentukan thumbnail, dan `order.id` adalah ID pesanan terkait bila tersedia. |

Token Snap pada endpoint token dibaca dari `data.snap_token` dengan fallback ke `snap_token` tingkat atas. Dibandingkan respons checkout, endpoint detail pesanan mengembalikan objek langsung di `data`.
