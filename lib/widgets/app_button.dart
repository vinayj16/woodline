import 'package:flutter/material.dart';
import 'package:woodline/theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final Widget? icon;
  final bool isOutlined;
  final BorderRadiusGeometry? borderRadius;
  final double elevation;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.height = 48,
    this.width,
    this.icon,
    this.isOutlined = false,
    this.borderRadius,
    this.elevation = 0,
  }) : super(key: key);

  const AppButton.outlined({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
    this.textColor,
    this.height = 48,
    this.width,
    this.icon,
    this.borderRadius,
    this.elevation = 0,
  })  : isOutlined = true,
        backgroundColor = Colors.transparent,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: textColor ?? theme.primaryColor,
            side: BorderSide(
              color: textColor ?? theme.primaryColor,
              width: 1.5,
            ),
            backgroundColor: backgroundColor,
            padding: padding,
            elevation: elevation,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
            minimumSize: Size(
              isFullWidth ? double.infinity : (width ?? 0),
              height!,
            ),
          )
        : ElevatedButton.styleFrom(
            foregroundColor: textColor ?? Colors.white,
            backgroundColor: backgroundColor ?? theme.primaryColor,
            padding: padding,
            elevation: elevation,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
            minimumSize: Size(
              isFullWidth ? double.infinity : (width ?? 0),
              height!,
            ),
          );

    return isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: _buildChild(theme),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: _buildChild(theme),
          );
  }


  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: isOutlined 
            ? (textColor ?? theme.primaryColor) 
            : (textColor ?? Colors.white),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    }

    return textWidget;
  }
}
