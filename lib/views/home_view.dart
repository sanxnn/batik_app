import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna tema (Sesuaikan dengan AppTheme Anda jika ada)
    const primaryColor = Color(0xFF6D4C41); // Coklat Batik Elegan
    const bgColors = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColors,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Beranda',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profil Saya',
          ),
        ],
      ),
      body: Consumer<AuthController>(
        builder: (context, controller, _) {
          final user = controller.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header Sambutan ---
                const Text(
                  'Selamat Datang,',
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // --- Kartu Ringkasan Profil ---
                Card(
                  elevation: 4,
                  shadowColor: primaryColor.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.email,
                                style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    user.isEmailVerified ? Icons.verified_user_rounded : Icons.error_outline,
                                    size: 16,
                                    color: user.isEmailVerified ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user.isEmailVerified ? 'Akun Terverifikasi' : 'Belum Terverifikasi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: user.isEmailVerified ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: Colors.grey[600],
                          onPressed: () => Navigator.pushNamed(context, '/profile'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // --- Menu Utama ---
                const Text(
                  'Menu Utama',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: const [
                    _MenuCard(icon: Icons.shopping_bag_outlined, label: 'Produk', color: Colors.blue),
                    _MenuCard(icon: Icons.category_outlined, label: 'Kategori', color: Colors.purple),
                    _MenuCard(icon: Icons.shopping_cart_outlined, label: 'Keranjang', color: Colors.orange),
                    _MenuCard(icon: Icons.receipt_long_outlined, label: 'Pesanan', color: Colors.green),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuCard({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fitur $label segera hadir!'), behavior: SnackBarBehavior.floating),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}