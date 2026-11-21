import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Search input bar with direct query submission, clipboard paste support, and clear action.
class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final bool isLoading;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    required this.onClear,
    this.isLoading = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.isLoading) return;
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      _focusNode.unfocus();
      widget.onSearch(query);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      _controller.text = text;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
      _submit();
    }
  }

  void _clear() {
    _controller.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider, width: 0.8),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: 'Search songs, artists or paste YouTube URL...',
          hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 22,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                )
              else if (_hasText)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textSecondary),
                  tooltip: 'Clear',
                  onPressed: _clear,
                )
              else
                IconButton(
                  icon: const Icon(Icons.content_paste_rounded, size: 19, color: AppTheme.textSecondary),
                  tooltip: 'Paste URL',
                  onPressed: _pasteFromClipboard,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
