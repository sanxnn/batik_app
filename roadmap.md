# Peta integrasi API Flutter

Halaman ini memetakan pemakaian API di aplikasi. Contoh payload lengkap dan aturan validasi server tersedia di [referensi API Laravel](https://github.com/sanxnn/rubung-v3/blob/main/docs/api-reference.md).

## Dasar request

- Semua path pada tabel relatif terhadap `API_BASE_URL`, termasuk prefiks `/api` pada nilainya. Contoh lokal untuk browser di mesin backend adalah `http://127.0.0.1:8000/api`.
- Katalog dan wilayah adalah endpoint publik. Profil, alamat, keranjang, pesanan, pembayaran pelanggan, refund, serta custom order membutuhkan `Authorization: Bearer <token>`. Endpoint OTP dan login dapat dipanggil sebelum pelanggan masuk.
- Gunakan ID dari respons server. ID produk memilih detail katalog, ID varian memilih barang yang ditambahkan, dan ID item keranjang memilih baris yang diubah atau dihapus. Custom order dan refund memiliki ID terpisah dari pesanan.
- Tampilkan harga dalam Rupiah. Payload checkout hanya membawa data yang dipilih pelanggan. Harga, ongkir, kuota, dan status berasal dari Laravel.

## Endpoint menurut service

| Service | Metode dan path | Pemakaian |
| --- | --- | --- |
| [AuthService](lib/services/auth_service.dart) | `POST /auth/register`, `POST /auth/login`, `GET /auth/me`, `PUT /auth/profile`, `POST /auth/logout` | Registrasi, sesi, profil, dan logout. |
| AuthService | `POST /auth/email/verify`, `POST /auth/email/resend`, `POST /auth/password/forgot`, `POST /auth/password/verify-otp`, `POST /auth/password/reset` | Verifikasi email, pengiriman kode, dan reset kata sandi. |
| [ProductService](lib/services/product_service.dart) | `GET /categories`, `GET /products`, `GET /products/{id}` | Kategori beserta subkategori, pencarian dan filter, serta detail produk. |
| [BundleService](lib/services/bundle_service.dart) | `GET /bundles`, `GET /bundles/{id}` | Daftar paket dan detail varian beserta komponen. |
| [AddressService](lib/services/address_service.dart) | `GET /regions/provinces`, `GET /regions/regencies/{provinceCode}`, `GET /regions/districts/{cityCode}`, `GET /regions/villages/{districtCode}` | Isi pilihan wilayah berjenjang dengan nilai `code` dan `name`. |
| AddressService | `GET\|POST /addresses`, `GET\|PUT\|DELETE /addresses/{id}`, `PATCH /addresses/{id}/primary` | Kelola alamat. Form mengirim empat kode wilayah sebagai string dan kode pos lima digit. |
| [CartService](lib/services/cart_service.dart) | `GET\|DELETE /cart`, `POST /cart/items`, `PUT\|DELETE /cart/items/{cartItemId}` | Tambah memakai `product_variant_id` dan `quantity`. Ubah jumlah atau hapus memakai ID item. |
| [OrderService](lib/services/order_service.dart) | `POST /vouchers/validate` | Body `code`. Aplikasi membaca `code`, `discount`, dan `subtotal_after_voucher` dari `data`. |
| OrderService | `GET\|POST /orders`, `GET /orders/{id}`, `POST /orders/{id}/cancel`, `POST /orders/{id}/complete` | Riwayat, checkout, detail, pembatalan, dan konfirmasi penerimaan. |
| OrderService | `POST /payments/{orderId}/snap-token` | Minta token Snap untuk pesanan yang masih menunggu pembayaran. |
| [RefundService](lib/services/refund_service.dart) | `POST /orders/{orderId}/refund`, `GET /refunds`, `GET /refunds/{id}`, `GET /refunds/{id}/evidence`, `POST /refunds/{id}/cancel` | Pengajuan multipart dengan `reason` dan `evidence`, riwayat, detail, bukti privat, dan pembatalan. |
| [CustomOrderService](lib/services/custom_order_service.dart) | `GET\|POST /custom-orders`, `GET /custom-orders/{id}`, `POST /custom-orders/{id}/attachments`, `POST /custom-orders/{id}/approve`, `POST /custom-orders/{id}/cancel` | Pengajuan dengan `description`, unggahan berulang pada `attachments[]`, penawaran, dan pembatalan. |
| [Pembentuk URL gambar](lib/core/network/image_url.dart) | `GET /storage-image/{path}` | Gambar katalog dan lampiran custom order dari path relatif. |

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

Webhook Midtrans ditangani Laravel. Flutter membaca status melalui detail pesanan. [Alur sistem](docs/alur-sistem.md) · [Koleksi Postman backend](https://github.com/sanxnn/rubung-v3/tree/main/docs/api-testing)

## Cakupan integrasi saat ini

Aplikasi menerima pratinjau voucher dari backend. Pratinjau total checkout yang sekaligus mencakup ongkir dan promo tanggal belum tersedia. Form checkout meminta pesanan dibuat sebelum menampilkan rincian total final. Referensi Laravel juga mencatat keterbatasan katalog seperti pengurutan menurut harga atau stok dan daftar voucher publik. [Batas integrasi Laravel](https://github.com/sanxnn/rubung-v3/blob/main/docs/api-reference.md#batas-integrasi)
