import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/batik_accent.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animasi untuk bentuk latar belakang (Shape Bloom)
  late Animation<double> _shape1Anim;
  late Animation<double> _shape2Anim;

  // Animasi untuk Logo (Pop/Bounce)
  late Animation<double> _logoAnim;

  // Animasi untuk Teks (Fade & Slide Up)
  late Animation<double> _textAnim;

  @override
  void initState() {
    super.initState();

    // Durasi animasi 1.5 detik, sisanya 0.5 detik untuk jeda sebelum pindah halaman (Total 2 detik)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 1. Animasi Shape Latar Belakang (Membesar dari 0 ke 1.2 dengan lembut)
    _shape1Anim = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuad),
      ),
    );
    _shape2Anim = Tween<double>(begin: 0.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.9, curve: Curves.easeOutQuad),
      ),
    );

    // 2. Animasi Logo (Muncul dengan efek memantul / elastic)
    _logoAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // 3. Animasi Teks (Fade in + sedikit geser ke atas)
    _textAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Tunggu tepat 2 detik sesuai permintaan
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final controller = context.read<AuthController>();
    // determineInitialRoute akan otomatis mengarahkan ke:
    // - '/login' (jika belum login) -> Root Page (Welcome, Login, Register)
    // - '/verify-email' (jika belum verifikasi)
    // - '/home' (jika sudah login)
    final nextRoute = await controller.determineInitialRoute();

    if (!mounted) return;

    // pushReplacementNamed memastikan user tidak bisa menekan tombol back ke splash screen
    Navigator.pushReplacementNamed(
      context,
      nextRoute,
      arguments: nextRoute == '/verify-email'
          ? controller.pendingVerificationEmail ?? controller.user?.email
          : null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -AppSpacing.xxl,
              right: -AppSpacing.xxl,
              child: ScaleTransition(
                scale: _shape1Anim,
                child: const CircleAvatar(
                  radius: AppSpacing.categoryIcon,
                  backgroundColor: AppColors.yellowTint,
                ),
              ),
            ),
            Positioned(
              bottom: -AppSpacing.xxl,
              left: -AppSpacing.xxl,
              child: ScaleTransition(
                scale: _shape2Anim,
                child: const CircleAvatar(
                  radius: AppSpacing.categoryIcon,
                  backgroundColor: AppColors.yellowTint,
                ),
              ),
            ),
            const Positioned.fill(child: BatikAccent(opacity: 0.02)),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _logoAnim,
                      child: Container(
                        width: AppSpacing.categoryIcon + AppSpacing.xxl,
                        height: AppSpacing.categoryIcon + AppSpacing.xxl,
                        decoration: BoxDecoration(
                          color: AppColors.brandYellow,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: AppColors.ink,
                          size: AppSpacing.xxl,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeTransition(
                      opacity: _textAnim,
                      child: Text(
                        'Batik Rubung Kuning',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Karya batik dari Jember',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
