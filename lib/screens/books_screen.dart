import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/contentful/contentful_graphql.dart';
import '../theme/sattva_theme.dart';
import '../widgets/aatmkala_app_bar.dart';

class BooksScreen extends StatelessWidget {
  static const String routeName = '/books';

  final ContentfulGraph contentful;

  const BooksScreen({
    super.key,
    required this.contentful,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AatmkalaAppBar(
        showBack: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Orange banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              color: SattvaTheme.saffron,
              child: const Center(
                child: Text(
                  'पुस्तके',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // List of books
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: contentful.fetchBooks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Could not load books.\n\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  }

                  final books = snapshot.data ?? [];

                  if (books.isEmpty) {
                    return const Center(
                      child: Text(
                        'No books available at the moment.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final title = (book['title'] as String?) ?? '';
                      final body = (book['body'] as String?) ?? '';
                      final coverUrl = book['coverImageUrl'] as String?;
                      final buyLink = (book['buyLink'] as String?)?.trim();

                      return Card(
                        elevation: 3,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cover image on the left
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 80,
                                  height: 110,
                                  child: coverUrl != null &&
                                          coverUrl.trim().isNotEmpty
                                      ? Image.network(
                                          coverUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, st) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.book_outlined,
                                            size: 32,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Title + body + buy button on the right
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      body,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (buyLink != null &&
                                        buyLink.isNotEmpty)
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _launchBuyLink(buyLink),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                SattvaTheme.saffron,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            'Buy',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

// Open external buy link
Future<void> _launchBuyLink(String urlString) async {
  Uri uri;
  try {
    uri = Uri.parse(urlString);
  } catch (_) {
    debugPrint('Invalid buy link: $urlString');
    return;
  }

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch buy link: $urlString');
  }
}
