import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/sattva_theme.dart';

class AatmkalaAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// If true, shows a back button before the logo.
  final bool showBack;

  /// Optional custom title. Defaults to "आत्मकला".
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
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 0,
      centerTitle: true,
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
        titleText ?? 'आत्मकला',
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

/// Shared logo widget
class AatmkalaLogo extends StatelessWidget {
  const AatmkalaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/aatmkala_logo.png',
      fit: BoxFit.contain,
    );
  }
}

// Menu items
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
        PopupMenuItem(
          value: AppMenuItem.home,
          child: Row(
            children: [
              Icon(
                Icons.home,
                size: 20,
                color: SattvaTheme.saffron,
              ),
              const SizedBox(width: 12),
              const Text('होम'),
            ],
          ),
        ),
        const PopupMenuDivider(height: 8),
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
              const Text('आत्मकला विषयी'),
            ],
          ),
        ),
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
              const Text('पुस्तके'),
            ],
          ),
        ),
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
              const Text('YouTube चॅनल'),
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
            Navigator.of(context).pushNamed('/about');
            break;
          case AppMenuItem.books:
            Navigator.of(context).pushNamed('/books');
            break;
          case AppMenuItem.youtubeChannel:
            _launchYouTubeChannel();
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

Future<void> _launchYouTubeChannel() async {
  final Uri url = Uri.parse('https://www.youtube.com/@aatmkala');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch YouTube channel.');
  }
}
