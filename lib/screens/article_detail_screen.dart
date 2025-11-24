import 'package:flutter/material.dart';
import '../widgets/aatmkala_app_bar.dart';
import '../data/contentful/contentful_graphql.dart';
import '../theme/sattva_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/app_top_bar.dart';
import 'zoom_image_screen.dart';

class ArticleDetailScreen extends StatelessWidget {
  static const routeName = '/article';

  final ContentfulGraph contentful;
  final String entryId;

  const ArticleDetailScreen({
    super.key,
    required this.contentful,
    required this.entryId,
  });

  String _normalizeImageUrl(String url) {
    if (!url.startsWith('http')) url = 'https:$url';
    if (!url.contains('fm=')) url = '$url?fm=jpg';
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AatmkalaAppBar(
        showBack: true,
      ), // constant green AppBar
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: contentful.fetchArticle(entryId),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError;
            final article = snapshot.data;

            // Title for saffron banner (hide if > 100 chars)
            final bannerTitle = () {
              if (isLoading) return 'Loading…';
              if (hasError) return '';
              if (article == null) return '';
              final t = (article['title'] ?? '') as String;
              return t.trim().length > 50 ? '' : t;
            }();

            return Column(
              children: [
                // Saffron banner – article title (hidden if long)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                  color: SattvaTheme.saffron,
                  child: Center(
                    child: Text(
                      bannerTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                // Article body
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (hasError) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (article == null) {
                        return const Center(child: Text('Article not found.'));
                      }

                      final String title = (article['title'] ?? '') as String;
                      final String body = (article['body'] ?? '') as String;
                      final String? imageUrl = article['imageUrl'] as String?;
                      final String type = (article['type'] ?? '') as String;

                      final maxImageHeight =
                          MediaQuery.of(context).size.height * 0.45;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (type.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 12),
                                child: Text(
                                  " ",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),

                            // Tappable image → fullscreen zoom viewer
                            if (imageUrl != null && imageUrl.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ConstrainedBox(
                                  constraints:
                                      BoxConstraints(maxHeight: maxImageHeight),
                                  child: Center(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            transitionDuration:
                                                const Duration(milliseconds: 250),
                                            reverseTransitionDuration:
                                                const Duration(milliseconds: 200),
                                            pageBuilder: (_, __, ___) =>
                                                ZoomImageScreen(
                                              imageUrl:
                                                  _normalizeImageUrl(imageUrl),
                                              title: title,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Hero(
                                        tag: _normalizeImageUrl(imageUrl),
                                        child: Image.network(
                                          _normalizeImageUrl(imageUrl),
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const Text(
                                            '⚠️ Image could not be loaded',
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            if (body.isNotEmpty)
                              Text(
                                body,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),

                            if (body.isEmpty &&
                                (imageUrl == null || imageUrl.isEmpty))
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Content will be available soon.',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),

                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: GradientButton(
                                    text: 'Back to List',
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GradientButton(
                                    text: 'Home',
                                    onPressed: () => Navigator.of(context)
                                        .popUntil((r) => r.isFirst),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
