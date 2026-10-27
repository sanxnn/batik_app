import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class HomeSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;

  const HomeSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, // Lebih bersih daripada surface saat focus
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: _isFocused ? AppTheme.primaryDark : AppTheme.border,
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // 1. Ikon Search dengan Background Halus
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isFocused ? AppTheme.primaryLight : AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              color: _isFocused ? AppTheme.primaryDark : AppTheme.textSecondary,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // 2. TextField
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              cursorColor: AppTheme.primaryDark,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
                letterSpacing: 0.2,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari batik, motif, atau bahan...',
                hintStyle: TextStyle(
                  color: AppTheme.textHint,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // 3. Tombol Clear (X) dengan Animasi Fade
          AnimatedOpacity(
            opacity: hasText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: hasText ? 32 : 0,
              child: hasText
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          widget.controller.clear();
                          widget.onChanged?.call('');
                          // Opsional: kembalikan focus setelah clear
                          // _focusNode.requestFocus();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.textSecondary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // 4. Divider Vertikal (Hanya muncul jika ada teks)
          AnimatedOpacity(
            opacity: hasText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: hasText ? 1 : 0,
              height: 24,
              color: AppTheme.border,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),

          // 5. Tombol Filter dengan Ripple Effect
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap:
                  widget.onFilterTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur filter lanjutan segera hadir!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    );
                  },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.tune_rounded,
                  color: hasText || _isFocused
                      ? AppTheme.primaryDark
                      : AppTheme.textSecondary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
