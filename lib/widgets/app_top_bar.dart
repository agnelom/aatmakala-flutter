import 'package:flutter/material.dart';
import '../theme/sattva_theme.dart';

/// Constant green AppBar with Aatmkala logo at far-left.
/// Shows an optional back button *next to* the logo on non-home screens.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;

  const AppTopBar({super.key, this.showBack = false});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: SattvaTheme.tulsi,
      foregroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
      // Make room for logo (+ optional back button) on the left
      leadingWidth: showBack ? 104 : 64,
      leading: Row(
        children: [
          const SizedBox(width: 10),
          // Logo at extreme left
          Image.asset(
            'assets/images/aatmkala_logo.png',
            width: 34,
            height: 34,
            fit: BoxFit.contain,
            semanticLabel: 'Aatmkala',
          ),
          if (showBack) ...[
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ],
      ),
      // No title text (as requested)
      title: const SizedBox.shrink(),
    );
  }
}
