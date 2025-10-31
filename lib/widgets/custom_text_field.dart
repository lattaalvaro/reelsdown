import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClearPressed;
  final VoidCallback? onPastePressed;
  final bool showPasteButton;
  final bool showClearButton;
  final IconData? prefixIcon;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? errorText;
  final bool autofocus;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClearPressed,
    this.onPastePressed,
    this.showPasteButton = true,
    this.showClearButton = true,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.errorText,
    this.autofocus = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.controller != null) {
      widget.controller!.addListener(_updateTextState);
      _hasText = widget.controller!.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller?.removeListener(_updateTextState);
    super.dispose();
  }

  void _updateTextState() {
    final hasText = (widget.controller?.text.isNotEmpty ?? false);
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
        ],
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  boxShadow: _hasFocus
                      ? [
                          BoxShadow(
                            color: AppTheme.secondaryColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      _hasFocus = hasFocus;
                    });
                    if (hasFocus) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  },
                  child: TextField(
                    controller: widget.controller,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    enabled: widget.enabled,
                    maxLines: widget.maxLines,
                    keyboardType: widget.keyboardType,
                    autofocus: widget.autofocus,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: widget.prefixIcon != null
                          ? Icon(
                              widget.prefixIcon,
                              color: _hasFocus
                                  ? AppTheme.secondaryColor
                                  : AppTheme.textSecondary,
                            )
                          : null,
                      suffixIcon: _buildSuffixActions(),
                      errorText: widget.errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        borderSide: const BorderSide(
                          color: AppTheme.secondaryColor,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        borderSide: const BorderSide(
                          color: AppTheme.errorColor,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        borderSide: const BorderSide(
                          color: AppTheme.errorColor,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: _hasFocus
                          ? AppTheme.surfaceColor
                          : Colors.grey.shade50,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget? _buildSuffixActions() {
    final actions = <Widget>[];

    if (_hasText && widget.showClearButton) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.clear, size: AppDimensions.iconSizeMedium),
          onPressed: () {
            widget.controller?.clear();
            widget.onClearPressed?.call();
          },
          color: AppTheme.textSecondary,
          tooltip: AppStrings.clearButton,
        ),
      );
    }

    if (widget.showPasteButton) {
      actions.add(
        IconButton(
          icon: const Icon(
            Icons.content_paste,
            size: AppDimensions.iconSizeMedium,
          ),
          onPressed: _pasteFromClipboard,
          color: AppTheme.textSecondary,
          tooltip: AppStrings.pasteButton,
        ),
      );
    }

    if (actions.isEmpty) return null;

    if (actions.length == 1) return actions.first;

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final text = clipboardData!.text!;
        widget.controller?.text = text;
        widget.onPastePressed?.call();
        widget.onChanged?.call(text);
      }
    } catch (e) {
      // Handle paste error silently
    }
  }
}
