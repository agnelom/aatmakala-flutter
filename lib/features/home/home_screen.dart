import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repository/content_repo.dart';
import '../../widgets/content_rich_text.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aatmkala')),
      body: FutureBuilder(
        future: ref.read(contentRepoProvider).latest(limit: 20),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
              return Center(
                child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                    'Could not load content.\n'
                    'Check your .env (SPACE_ID, ENVIRONMENT, TOKEN) and Contentful model IDs.\n\n'
                    'Error: ${snap.error}',
                    textAlign: TextAlign.center,
                    ),
                ),
            );
        }
          final items = snap.data ?? [];
          final width = MediaQuery.of(context).size.width;
          final crossAxisCount = width < 600 ? 2 : 3;
          if (items.isEmpty) return const Center(child: Text('No content'));
          return LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth > 900;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  for (final a in items)
                    InkWell(
                      onTap: () => context.go('/article/${a.id}')
                      ,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (a.imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(imageUrl: a.imageUrl!, height: 160, width: double.infinity, fit: BoxFit.cover),
                                ),
                              const SizedBox(height: 12),
                              Text(a.title, style: Theme.of(context).textTheme.titleMedium),
                              if (a.bodyHtml != null) ...[
                                const SizedBox(height: 8),
                                Expanded(child: SingleChildScrollView(child: ContentHtml(a.bodyHtml!.substring(0, a.bodyHtml!.length > 400 ? 400 : a.bodyHtml!.length))))
                              ]
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
