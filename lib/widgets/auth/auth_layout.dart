import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool showBranding;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBranding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showBranding) const _AuthBranding(),

                    // Area Form dengan padding yang lebih lega dan proporsional
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 28,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14.5,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 32),
                          child,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthBranding extends StatelessWidget {
  const _AuthBranding();

  @override
  Widget build(BuildContext context) {
    // Warna emas tua yang kaya untuk aksen teks (bisa disesuaikan dengan AppTheme.primaryDark)
    const Color richGold = Color(0xFFB88700);

    return Container(
      height: 230, // Sedikit lebih tinggi agar elemen bisa "bernapas"
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            40,
          ), // Lengkungan lebih besar untuk kesan modern
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          // --- DEKORASI LATAR BELAKANG (Soft Organic Blobs) ---
          // Blob 1: Kanan Atas (Sangat halus)
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Blob 2: Kiri Bawah (Sedikit lebih tegas)
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Blob 3: Tengah (Aksen sangat tipis untuk kedalaman)
          Positioned(
            top: 40,
            left: 60,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --- KONTEN UTAMA ---
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo & Brand Name
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.diamond_outlined, // Ikon yang lebih merepresentasikan "Premium/Craft"
                        size: 26,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RUBUNG KUNING',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'BATIK • CRAFT • CULTURE',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(), // Mendorong teks tagline ke bagian bawah header
                // Tagline dengan Tipografi Elegan
                const Text(
                  'Cerita indah,',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'dalam setiap motif.',
                  style: TextStyle(
                    color: richGold, // Aksen emas yang kaya
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
