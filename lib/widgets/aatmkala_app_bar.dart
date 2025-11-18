import 'package:flutter/material.dart';
import '../theme/sattva_theme.dart';

class AatmkalaAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// If true, shows a back button before the logo.
  final bool showBack;

  /// Optional custom title. Defaults to "Aatmkala".
  final String? titleText;

  const AatmkalaAppBar({
    super.key,
    this.showBack = false,
    this.titleText,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2E7D32), // <- fixed green
      elevation: 0,
      centerTitle: false,
      leadingWidth: showBack ? 96 : 56,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (showBack)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                splashRadius: 20,
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            Expanded(
              child: InkWell(
                onTap: () => _navigateHome(context),
                borderRadius: BorderRadius.circular(8),
                child: const AatmkalaLogo(),
              ),
            ),
          ],
        ),
      ),
      titleSpacing: 0,
      title: Text(
        titleText ?? 'Aatmkala',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: const [
        _AppMenu(),
      ],
    );
  }
}

/// Shared logo widget — final path as requested
class AatmkalaLogo extends StatelessWidget {
  const AatmkalaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/aatmkala_logo.png', // <- your logo path
      fit: BoxFit.contain,
    );
  }
}

enum AppMenuItem {
  home,
  about,
  books,
  youtubeChannel,
}

class _AppMenu extends StatelessWidget {
  const _AppMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppMenuItem>(
      icon: const Icon(Icons.menu),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      offset: const Offset(0, kToolbarHeight),
      itemBuilder: (context) => [
        // ----- HOME -----
        PopupMenuItem(
          value: AppMenuItem.home,
          child: Row(
            children: [
              Icon(
                Icons.home,
                size: 20,
                color: SattvaTheme.saffron, // saffron-colored icon
              ),
              const SizedBox(width: 12),
              const Text('Home'),
            ],
          ),
        ),

        const PopupMenuDivider(height: 8),

        // ----- ABOUT -----
        PopupMenuItem(
          value: AppMenuItem.about,
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: SattvaTheme.saffron,
              ),
              const SizedBox(width: 12),
              const Text('About'),
            ],
          ),
        ),

        // ----- BOOKS -----
        PopupMenuItem(
          value: AppMenuItem.books,
          child: Row(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 20,
                color: SattvaTheme.saffron,
              ),
              const SizedBox(width: 12),
              const Text('Books'),
            ],
          ),
        ),

        // ----- YOUTUBE -----
        PopupMenuItem(
          value: AppMenuItem.youtubeChannel,
          child: Row(
            children: [
              Icon(
                Icons.ondemand_video,
                size: 20,
                color: SattvaTheme.saffron,
              ),
              const SizedBox(width: 12),
              const Text('YouTube Channel'),
            ],
          ),
        ),
      ],
      onSelected: (item) {
        switch (item) {
          case AppMenuItem.home:
            _navigateHome(context);
            break;
          case AppMenuItem.about:
            _showNotLinkedYet(context, 'About');
            break;
          case AppMenuItem.books:
            _showNotLinkedYet(context, 'Books');
            break;
          case AppMenuItem.youtubeChannel:
            _showNotLinkedYet(context, 'YouTube Channel');
            break;
        }
      },
    );
  }
}

//
// Helper functions
//

void _navigateHome(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}

void _showNotLinkedYet(BuildContext context, String label) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$label tapped (not yet linked)')),
  );
}
