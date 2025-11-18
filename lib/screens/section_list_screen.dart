import 'package:flutter/material.dart';
import '../widgets/aatmkala_app_bar.dart';
import '../data/contentful/contentful_graphql.dart';
import '../theme/sattva_theme.dart';
import '../widgets/app_top_bar.dart';
import 'article_detail_screen.dart';

class SectionListArgs {
  final String sectionId;
  final String title;
  const SectionListArgs({required this.sectionId, required this.title});
}

class SectionListScreen extends StatelessWidget {
  static const routeName = '/section';
  final ContentfulGraph contentful;
  final SectionListArgs args;

  const SectionListScreen({
    super.key,
    required this.contentful,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AatmkalaAppBar(), // constant green AppBar
      body: SafeArea(
        child: Column(
          children: [
            // Saffron banner – **section name**
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              color: SattvaTheme.saffron,
              child: Center(
                child: Text(
                  args.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: contentful.fetchEntriesForSection(args.sectionId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(child: Text('No content found.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            item['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ArticleDetailScreen.routeName,
                              arguments: item['id'],
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
