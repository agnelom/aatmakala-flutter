import 'package:flutter/material.dart';
import '../theme/sattva_theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool fullWidth;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    this.borderRadius = 28,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onPressed,
      child: Padding(
        padding: padding,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    final decorated = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: SattvaTheme.saffronGradient,
        borderRadius: BorderRadius.all(Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: decorated);
    }
    return decorated;
  }
}
