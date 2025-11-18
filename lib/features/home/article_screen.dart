import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/content_repo.dart';
import '../../widgets/content_rich_text.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArticleScreen extends ConsumerWidget {
  final String entryId;
  const ArticleScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: ref.read(contentRepoProvider).byId(entryId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final a = snap.data;
          if (a == null) return const Center(child: Text('Not found'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (a.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(imageUrl: a.imageUrl!, height: 220, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),
              Text(a.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              if (a.bodyHtml != null) ContentHtml(a.bodyHtml!),
            ],
          );
        },
      ),
    );
  }
}