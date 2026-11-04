import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class HomeSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const HomeSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
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
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? AppTheme.primary : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),

          Icon(
            Icons.search_rounded,
            size: 22,
            color: _isFocused ? AppTheme.primary : const Color(0xFF9CA3AF),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              cursorColor: AppTheme.primary,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1F2937),
              ),
              decoration: const InputDecoration(
                hintText: 'Cari produk batik...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
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
                      color: Color(0xFF9CA3AF),
                    ),
                    splashRadius: 18,
                    visualDensity: VisualDensity.compact,
                  )
                : const SizedBox(key: ValueKey('empty'), width: 12),
          ),

          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
