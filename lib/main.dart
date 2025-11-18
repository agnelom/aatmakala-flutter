import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'widgets/aatmkala_app_bar.dart';
import 'core/env.dart';
import 'data/contentful/contentful_graphql.dart';
import 'screens/home_screen.dart';
import 'screens/section_list_screen.dart';
import 'screens/article_detail_screen.dart';
import 'screens/about_screen.dart';
import 'screens/books_screen.dart';
import 'theme/sattva_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: 'assets/env/.env');
    Env.debugPrintEnv();
  } catch (e) {
    debugPrint('⚠️ dotenv not loaded: $e');
  }

  final contentful = ContentfulGraph();

  runApp(AatmkalaApp(contentful: contentful));
}

class AatmkalaApp extends StatelessWidget {
  final ContentfulGraph contentful;

  const AatmkalaApp({super.key, required this.contentful});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: dotenv.env['APP_NAME'] ?? 'Aatmkala',
      theme: SattvaTheme.light(),
      home: HomeScreen(contentful: contentful),
      // Static routes that don't need arguments
      routes: {
        AboutScreen.routeName: (_) => AboutScreen(contentful: contentful),
        BooksScreen.routeName: (_) => BooksScreen(contentful: contentful),
      },
      // Routes that need arguments
      onGenerateRoute: (settings) {
        if (settings.name == SectionListScreen.routeName) {
          final args = settings.arguments as SectionListArgs;
          return MaterialPageRoute(
            builder: (_) =>
                SectionListScreen(contentful: contentful, args: args),
          );
        }
        if (settings.name == ArticleDetailScreen.routeName) {
          final entryId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) =>
                ArticleDetailScreen(contentful: contentful, entryId: entryId),
          );
        }
        return null;
      },
    );
  }
}
