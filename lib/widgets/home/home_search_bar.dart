import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_shadows.dart';

class HomeSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilter;

  const HomeSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilter,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final FocusNode _focusNode = FocusNode();

  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    _hasText = widget.controller.text.isNotEmpty;

    _focusNode.addListener(_handleFocus);

    widget.controller.addListener(_handleText);
  }

  void _handleFocus() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleText() {
    final hasText = widget.controller.text.isNotEmpty;

    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _clearSearch() {
    widget.controller.clear();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    widget.controller.removeListener(_handleText);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: _isFocused ? AppColors.ink : AppColors.border,
          width: 1,
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.md),

          Icon(
            Icons.search_rounded,
            size: 22,
            color: _isFocused ? AppColors.ink : AppColors.textSecondary,
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              cursorColor: AppTheme.primary,
              textInputAction: TextInputAction.search,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.ink),
              decoration: const InputDecoration(
                hintText: 'Cari produk batik...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: _hasText
                ? IconButton(
                    key: const ValueKey('clear'),
                    onPressed: _clearSearch,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 19,
                      color: AppColors.textTertiary,
                    ),
                    tooltip: 'Hapus pencarian',
                  )
                : const SizedBox(key: ValueKey('empty'), width: AppSpacing.xxs),
          ),
          if (widget.onFilter != null) ...[
            Container(width: 1, height: 24, color: AppColors.border),
            IconButton(
              onPressed: widget.onFilter,
              tooltip: 'Pilih kategori',
              icon: const Icon(Icons.tune_rounded, color: AppColors.ink),
            ),
          ],
          const SizedBox(width: AppSpacing.xxs),
        ],
      ),
    );
  }
}
