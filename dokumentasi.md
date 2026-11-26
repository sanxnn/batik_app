# Dokumentasi aplikasi Batik Rubung Kuning

Dokumen ini menjelaskan struktur aplikasi Flutter pelanggan, pemetaan endpoint API pada `roadmap.md`, aturan UI, dan cara menjalankan verifikasi. Server tetap menjadi sumber harga, stok, promo, ongkir, dan status pembayaran.

## Struktur aplikasi

```text
lib/
├── core/network/      # Dio, token aman, URL gambar, URL Snap
├── core/utils/        # ApiResult dan pemetaan error
├── models/            # Model response API
├── services/          # HTTP request dan parsing response
├── controllers/       # State ChangeNotifier per domain
├── views/             # Halaman aplikasi
├── widgets/           # Widget UI yang digunakan ulang
└── theme/             # Palet warna dan ThemeData utama
```

Setiap domain mengikuti alur `View → Controller → Service → ApiClient`. View tidak memanggil Dio secara langsung. Controller menangani loading, error, pagination, dan perubahan state. Service hanya mengurus request dan parsing response.

## Konfigurasi jaringan

`API_BASE_URL` dibaca dari `.env` melalui `flutter_dotenv`.

- Production: `https://batikrubungkuning.sanxnn.my.id/api`
- Android emulator lokal: `http://10.0.2.2:8000/api`
- Flutter desktop/web lokal: `http://localhost:8000/api`

`ApiClient` mengirim `Accept: application/json` dan `Content-Type: application/json`. Token Sanctum disimpan melalui `flutter_secure_storage`, dengan migrasi satu kali dari key lama `shared_preferences`. Interceptor menambahkan `Authorization: Bearer <token>` dan menghapus token ketika server mengembalikan `401`.

Gunakan `MIDTRANS_ENV=sandbox` untuk token sandbox (default) atau `MIDTRANS_ENV=production` untuk token production. Jangan mencampur token dan host dari environment berbeda.

## Palet dan komponen UI

Home final menjadi acuan tampilan seluruh aplikasi. Material 3 memakai Inter dari dependency `google_fonts` yang sudah tersedia. Token berada di `lib/theme/app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_radius.dart`, `app_shadows.dart`, dan `app_theme.dart`.

| Token | Nilai | Penggunaan |
| --- | --- | --- |
| `AppColors.ink` | `#1C1C1E` | Teks dan tombol utama |
| `AppColors.brandYellow` | `#FFC21A` | Banner dan highlight |
| `AppColors.brandYellowDark` | `#F2A900` | Gradien banner |
| `AppColors.yellowSoft` | `#FFF6D6` | Pilihan/status ringan |
| `AppColors.background` | `#FFFFFF` | Latar halaman |
| `AppColors.surfaceMuted` | `#F6F6F8` | Latar kontrol sekunder |
| `AppColors.border` | `#ECECEF` | Border kartu dan divider |
| `AppColors.textSecondary` | `#6B6B70` | Deskripsi dan metadata |
| `AppColors.danger` | `#C42C36` | Error dan aksi hapus |
| `AppColors.success` | `#167549` | Status berhasil |
| `AppColors.info` | `#1D65C1` | Status informasi |
| `AppColors.warning` | `#805900` | Status menunggu |

Kuning dipakai sebagai aksen, dengan teks gelap di atasnya. Foto produk adalah fokus katalog; banner Home menampilkan gambar saja. `AppBottomNav` mempertahankan empat tab existing. `AppAppBar` memusatkan judul layar sekunder. `AppCard`, `AppMenuTile`, `OrderCard`, `StatusChip`, `AppStateView`, `AppSection`, `AppNetworkImage`, serta widget auth dan cart dipakai ulang pada layar Tahap B. Form dan tombol mengikuti component theme; ukuran dan jarak memakai token. Motif kawung dari `BatikAccent` hanya menjadi aksen halus pada splash dan autentikasi.

Inventaris seluruh view dan checklist uji manual ada di `docs/ui_redesign_plan.md`. Tidak ada route onboarding, wishlist, filter harga, halaman voucher, notifikasi, pengaturan, rating, atau ulasan pada project saat ini. Detail produk tidak menampilkan diskon/review tanpa data, dan aksi favorit lama yang hanya memunculkan snackbar dihapus. Angka ongkir dan diskon final hanya ditampilkan setelah dihitung server. Tidak ada dependency UI baru dan tidak ada perubahan Tahap B pada service, model, controller, atau routing.

## Pemetaan fitur ke endpoint

### Katalog dan bundling

- `GET /categories` → `ProductService.getCategories()` → kategori dan subkategori.
- `GET /products` → `ProductService.getProducts()` → `ProductController`, membaca pagination dari `data.data`.
- `GET /products/{id}` → `ProductService.getProduct()` → `ProductDetailView`.
- `GET /bundles` → `BundleService.getBundles()` → `BundleController`, membaca item dari `data` dan pagination dari `meta`.
- `GET /bundles/{id}` → `BundleService.getBundle()` → detail bundle.

Beranda menampilkan produk pada kategori `Semua` dan kategori produk. Kategori `Bundling` menampilkan paket saja; daftar paket dimuat dari `GET /bundles` tanpa memanggil filter produk. Pencarian di Home hanya mencari produk dan mengalihkan tampilan dari Bundling ke produk. Kartu bundling memperlihatkan varian pertama dan harganya. Varian bundle memakai `product_variant_id` yang sama dengan endpoint cart sehingga dapat langsung ditambahkan ke keranjang.

### Keranjang

- `GET /cart` → muat isi keranjang.
- `POST /cart/items` dengan `{ "product_variant_id": id, "quantity": n }` → tambah produk atau bundle.
- `PUT /cart/items/{cartItemId}` dengan `{ "quantity": n }` → ubah jumlah.
- `DELETE /cart/items/{cartItemId}` → hapus item.
- `DELETE /cart` → kosongkan keranjang.

`CartController` hanya mengirim ID varian dan quantity. Harga, subtotal, dan stok berasal dari response server.

### Checkout dan pembayaran

1. Pengguna memilih alamat dari `GET /addresses`.
2. `POST /orders` hanya mengirim `address_id`, `voucher_code?`, dan `notes?`.
3. Order disimpan dari `data.order`; token awal dibaca dari `data.payment.snap_token`.
4. Jika token kosong, `POST /payments/{orderId}/snap-token` dipanggil ulang.
5. Parser pembayaran menerima bentuk response `data.snap_token`, `data.payment.snap_token`, dan fallback `snap_token` di root.
6. Token dibuka dengan host Snap sesuai `MIDTRANS_ENV`.
7. Setelah kembali dari browser pembayaran, `GET /orders/{id}` dipanggil ulang. Status webhook server menjadi sumber status final.

Status order: `pending_payment`, `paid`, `processing`, `packing`, `shipped`, `completed`, dan `cancelled`. Status payment: `pending`, `success`, `failed`, dan `expire`.

### Custom order

- `GET /custom-orders` → daftar berhalaman.
- `GET /custom-orders/{id}` → detail custom order.
- `POST /custom-orders` dengan deskripsi minimal 10 karakter. Tanpa gambar dikirim sebagai JSON; dengan gambar dikirim sebagai `multipart/form-data` berisi `description` dan `attachments[]`.
- `POST /custom-orders/{id}/attachments` dengan `attachments[]` untuk menambah gambar selama status `pending_review`.
- `POST /custom-orders/{id}/approve` dengan `address_id` dan `notes?` → membuat order pembayaran.
- `POST /custom-orders/{id}/cancel` → pembatalan pada status `pending_review` atau `quoted`.

`CustomOrderView` menyediakan form permintaan dengan pilihan gambar, riwayat dan gambar terunggah, penambahan gambar saat `pending_review`, quotation, pilihan catatan saat menyetujui, alamat utama, tombol batal, dan navigasi ke detail order untuk pembayaran. Maksimal 5 gambar per permintaan, masing-masing maksimal 2 MB dan berformat JPEG, PNG, atau WebP.

### Akun dan alamat

Auth mencakup register, verifikasi OTP, resend OTP, login, profile, forgot/reset password, dan logout. `GET/POST/PUT/PATCH/DELETE /addresses...` dikelola oleh `AddressService` dan `AddressController`. Form alamat memuat provinsi, kabupaten/kota, kecamatan, dan desa/kelurahan secara berurutan dari `/regions/...`, lalu mengirim empat kode wilayah beserta kode pos lima digit. Alamat lama tanpa kode wilayah tetap dapat diedit menggunakan nama wilayah tersimpan, atau dipindahkan ke pilihan kode wilayah baru. Error validasi Laravel (`errors`) dipetakan ke pesan field atau pesan umum tanpa mengasumsikan response selalu berupa Map.

## Perilaku error

`apiErrorMessage` memprioritaskan `message`, lalu error field pertama, lalu status `401`, kemudian pesan koneksi umum. Controller tidak menampilkan stack trace atau response mentah. Response non-JSON menghasilkan pesan aman dan tidak menyebabkan crash saat mengakses key Map.

## Verifikasi

Jalankan dari folder `batik_app`:

```bash
flutter analyze
flutter test
```

Test mencakup parsing cart, pagination produk/order/bundle, payload checkout, bentuk response token Midtrans, URL Snap sandbox, Home pada dua ukuran, komponen Tahap B pada dua ukuran, dan state normal/loading/kosong/error daftar pesanan. Uji manual yang disarankan memakai backend sandbox: login dan OTP, katalog multi halaman, produk dan bundle masuk cart, checkout dengan voucher, token pembayaran kosong lalu retry, kembali dari browser pembayaran, custom order sampai quotation, approve/cancel, serta perubahan alamat utama.

APK tidak dibangun sebagai bagian dari pekerjaan ini.

## Batasan kontrak API

Preview ongkir/promo, daftar voucher publik, filter harga/stok, dan sorting belum tersedia di API menurut `roadmap.md`; aplikasi tidak memanggil endpoint yang belum ada. Jika backend menambah endpoint tersebut, buat perubahan service/model/controller sekaligus dan perbarui dokumen ini.
