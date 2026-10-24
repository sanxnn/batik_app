import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const HomeSearchBar({super.key, required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Cari batik favoritmu...',
                hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 14),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.textSecondary),
            onPressed: () {}, // Bisa diisi dengan filter modal nanti
          ),
        ],
      ),
    );
  }
}