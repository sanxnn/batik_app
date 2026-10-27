import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import 'edit_profile_view.dart'; // Pastikan import ini ada setelah file dibuat

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final Color primaryColor = const Color(0xFF6D4C41);

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Keluar Akun',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi? Anda perlu login kembali untuk mengakses fitur.',
          style: TextStyle(color: Colors.black54, height: 1.5, fontSize: 15),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ya, Keluar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthController>().logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<AuthController>(
        builder: (context, authCtrl, _) {
          if (authCtrl.user == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6D4C41)),
            );
          }

          final user = authCtrl.user!;
          final initial = user.name.isNotEmpty
              ? user.name[0].toUpperCase()
              : '?';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // --- 1. Header Profil ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 32,
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
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF6D4C41),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileView(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- 2. Menu Navigasi ---
              _buildMenuSection([
                _MenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profil',
                  subtitle: 'Ubah nama, email, dan nomor HP',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileView(),
                    ),
                  ),
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Alamat Saya',
                  subtitle: 'Kelola alamat pengiriman',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Halaman Alamat segera hadir!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Pesanan Saya',
                  subtitle: 'Lacak status pesanan dan riwayat',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Halaman Pesanan segera hadir!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Bantuan & FAQ',
                  subtitle: 'Pusat bantuan dan pertanyaan umum',
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 32),

              // --- 3. Tombol Logout (Opsional, karena sudah ada di AppBar) ---
              // Bisa dihapus jika merasa redundan dengan tombol di AppBar
            ],
          );
        },
      ),
    );
  }

  // Helper Widget untuk Menu Item
  Widget _buildMenuSection(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: primaryColor, size: 24),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 24,
                ),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Data Class untuk Menu
class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
