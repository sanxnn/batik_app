import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
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
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuad)),
    );
    _shape2Anim = Tween<double>(begin: 0.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.9, curve: Curves.easeOutQuad)),
    );

    // 2. Animasi Logo (Muncul dengan efek memantul / elastic)
    _logoAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack)),
    );

    // 3. Animasi Teks (Fade in + sedikit geser ke atas)
    _textAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
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
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background, // Putih bersih
      body: Stack(
        children: [
          // --- BACKGROUND SHAPES (Dribbble Style Soft Blobs) ---
          Positioned(
            top: -80,
            right: -80,
            child: ScaleTransition(
              scale: _shape1Anim,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: ScaleTransition(
              scale: _shape2Anim,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // --- MAIN CONTENT ---
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. LOGO CONTAINER
                    ScaleTransition(
                      scale: _logoAnim,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.storefront_rounded, // Ganti dengan Image.asset('assets/logo.png') jika ada
                          size: 56,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 2. TEXT CONTENT (Fade & Slide Up)
                    FadeTransition(
                      opacity: _textAnim,
                      child: Transform.translate(
                        offset: Offset(0, 15 * (1 - _textAnim.value)), // Efek slide up 15px
                        child: Column(
                          children: [
                            const Text(
                              'Batik Rubung Kuning',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Authentic Indonesian Heritage',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 64),
                    
                    // 3. MODERN LOADER
                    FadeTransition(
                      opacity: _textAnim, // Muncul bersamaan dengan teks
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          backgroundColor: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}