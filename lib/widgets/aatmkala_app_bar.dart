import 'package:flutter/material.dart';
import '../theme/sattva_theme.dart';

class AatmkalaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AatmkalaAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2E7D32), // or const Color(0xFF2E7D32)
      elevation: 0,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: InkWell(
          onTap: () => _navigateHome(context),
          borderRadius: BorderRadius.circular(8),
          child: const AatmkalaLogo(),
        ),
      ),
      titleSpacing: 0,
      title: const Text(
        'Aatmkala',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: const [
        _AppMenu(),
      ],
    );
  }
}

/// Shared logo widget — ensure the correct path
class AatmkalaLogo extends StatelessWidget {
  const AatmkalaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/aatmkala_logo.png', // <-- update this if your path differs
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      offset: const Offset(0, kToolbarHeight),
      itemBuilder: (context) => [
        // ----- HOME -----
        PopupMenuItem(
          value: AppMenuItem.home,
          child: Row(
            children: const [
              Icon(Icons.home, size: 20),
              SizedBox(width: 12),
              Text('Home'),
            ],
          ),
        ),

        // Divider
        const PopupMenuDivider(height: 8),

        // ----- ABOUT -----
        PopupMenuItem(
          value: AppMenuItem.about,
          child: Row(
            children: const [
              Icon(Icons.info_outline, size: 20),
              SizedBox(width: 12),
              Text('About'),
            ],
          ),
        ),

        // ----- BOOKS -----
        PopupMenuItem(
          value: AppMenuItem.books,
          child: Row(
            children: const [
              Icon(Icons.menu_book_outlined, size: 20),
              SizedBox(width: 12),
              Text('Books'),
            ],
          ),
        ),

        // ----- YOUTUBE -----
        PopupMenuItem(
          value: AppMenuItem.youtubeChannel,
          child: Row(
            children: const [
              Icon(Icons.ondemand_video, size: 20),
              SizedBox(width: 12),
              Text('YouTube Channel'),
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
// Helper Functions
//

void _navigateHome(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}

void _showNotLinkedYet(BuildContext context, String label) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$label tapped (not yet linked)')),
  );
}
