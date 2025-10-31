import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isOutlined;
  final Widget? loadingWidget;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.borderRadius,
    this.padding,
    this.isOutlined = false,
    this.loadingWidget,
  });

  const CustomButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.borderRadius,
    this.padding,
    this.loadingWidget,
  }) : isOutlined = true;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isEnabled && !widget.isLoading;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: isActive ? _handleTapDown : null,
              onTapUp: isActive ? _handleTapUp : null,
              onTapCancel: isActive ? _handleTapCancel : null,
              onTap: isActive ? widget.onPressed : null,
              child: Container(
                width: widget.width,
                height: widget.height,
                padding:
                    widget.padding ??
                    const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingRegular,
                    ),
                decoration: BoxDecoration(
                  color: widget.isOutlined
                      ? Colors.transparent
                      : _getBackgroundColor(context),
                  borderRadius:
                      widget.borderRadius ??
                      BorderRadius.circular(AppConstants.borderRadius),
                  border: widget.isOutlined
                      ? Border.all(color: _getBorderColor(context), width: 1.5)
                      : null,
                  gradient: !widget.isOutlined && widget.backgroundColor == null
                      ? AppTheme.primaryGradient
                      : null,
                  boxShadow: !widget.isOutlined && isActive
                      ? [
                          BoxShadow(
                            color: _getBackgroundColor(
                              context,
                            ).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: _buildContent(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.isLoading) {
      return Center(
        child:
            widget.loadingWidget ??
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getTextColor(context),
                ),
              ),
            ),
      );
    }

    final content = <Widget>[];

    if (widget.icon != null) {
      content.add(
        Icon(
          widget.icon,
          color: _getTextColor(context),
          size: AppDimensions.iconSizeMedium,
        ),
      );
      content.add(const SizedBox(width: AppDimensions.spacingSmall));
    }

    content.add(
      Text(
        widget.text,
        style: TextStyle(
          color: _getTextColor(context),
          fontSize: AppDimensions.fontSizeRegular,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: content,
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (!widget.isEnabled) {
      return Colors.grey.shade300;
    }

    return widget.backgroundColor ?? AppTheme.secondaryColor;
  }

  Color _getBorderColor(BuildContext context) {
    if (!widget.isEnabled) {
      return Colors.grey.shade300;
    }

    return widget.backgroundColor ?? AppTheme.secondaryColor;
  }

  Color _getTextColor(BuildContext context) {
    if (!widget.isEnabled) {
      return Colors.grey.shade600;
    }

    if (widget.isOutlined) {
      return widget.textColor ?? AppTheme.secondaryColor;
    }

    return widget.textColor ?? Colors.white;
  }
}

// Widget para botones pequeños como chips
class CustomChip extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSelected;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomChip({
    super.key,
    required this.text,
    this.onPressed,
    this.isSelected = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: AppConstants.animationDuration,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMedium,
          vertical: AppDimensions.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (backgroundColor ?? AppTheme.secondaryColor)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (backgroundColor ?? AppTheme.secondaryColor)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AppDimensions.iconSizeSmall,
                color: isSelected
                    ? (textColor ?? Colors.white)
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: AppDimensions.spacingXSmall),
            ],
            Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? (textColor ?? Colors.white)
                    : AppTheme.textSecondary,
                fontSize: AppDimensions.fontSizeMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
