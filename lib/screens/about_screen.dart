import 'package:flutter/material.dart';

import '../data/contentful/contentful_graphql.dart';
import '../theme/sattva_theme.dart';
import '../widgets/aatmkala_app_bar.dart';

class AboutScreen extends StatelessWidget {
  static const String routeName = '/about';

  final ContentfulGraph contentful;

  const AboutScreen({
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
        child: FutureBuilder<Map<String, dynamic>?>(
          future: contentful.fetchAbout(),
          builder: (context, snapshot) {
            // --- Handle loading & error states first ---
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  // Orange banner with temporary title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    color: SattvaTheme.saffron,
                    child: const Center(
                      child: Text(
                        'Loading…',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    color: SattvaTheme.saffron,
                    child: const Center(
                      child: Text(
                        'About',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Could not load About content.\n\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final about = snapshot.data;
            if (about == null) {
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    color: SattvaTheme.saffron,
                    child: const Center(
                      child: Text(
                        'About',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'About information is not available at the moment.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            // --- We have data from Contentful ---
            final String title =
                (about['title'] as String?)?.trim().isNotEmpty == true
                    ? about['title'] as String
                    : 'About';

            final bodyDoc = about['body'];
            final richDoc =
                bodyDoc is Map<String, dynamic> ? bodyDoc : null;

            return Column(
              children: [
                // 1️⃣ Orange banner shows ONLY the title from Contentful
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  color: SattvaTheme.saffron,
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                // 2️⃣ Body area: ONLY rich text, no title repeated
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: richDoc == null
                        ? const Text(
                            'About content is not yet configured.',
                            style: TextStyle(fontSize: 14),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildRichTextBlocks(richDoc),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- Rich Text Rendering Helpers ----

  static List<Widget> _buildRichTextBlocks(Map<String, dynamic> doc) {
    final List<Widget> blocks = [];
    final content = doc['content'];

    if (content is! List) return blocks;

    for (final node in content) {
      if (node is! Map<String, dynamic>) continue;
      final widget = _buildBlockNode(node);
      if (widget != null) {
        blocks.add(widget);
        blocks.add(const SizedBox(height: 8));
      }
    }

    return blocks;
  }

  static Widget? _buildBlockNode(Map<String, dynamic> node) {
    final nodeType = node['nodeType'] as String? ?? '';

    switch (nodeType) {
      case 'heading-1':
      case 'heading-2':
        final text = _extractPlainText(node).trim();
        if (text.isEmpty) return null;
        return Text(
          text,
          style: TextStyle(
            fontSize: nodeType == 'heading-1' ? 20 : 18,
            fontWeight: FontWeight.w700,
          ),
        );

      case 'paragraph':
        final spans = _buildInlineSpans(node['content']);
        if (spans.isEmpty) return null;
        return RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
            children: spans,
          ),
        );

      case 'unordered-list':
        final items = node['content'];
        if (items is! List) return null;

        final List<Widget> bullets = [];
        for (final item in items) {
          if (item is! Map<String, dynamic>) continue;
          final text = _extractPlainText(item).trim();
          if (text.isEmpty) continue;
          bullets.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
          bullets.add(const SizedBox(height: 4));
        }
        if (bullets.isEmpty) return null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: bullets,
        );

      default:
        final text = _extractPlainText(node).trim();
        if (text.isEmpty) return null;
        return Text(
          text,
          style: const TextStyle(fontSize: 14, height: 1.4),
        );
    }
  }

  static List<InlineSpan> _buildInlineSpans(dynamic content) {
    final List<InlineSpan> spans = [];
    if (content is! List) return spans;

    for (final child in content) {
      if (child is! Map<String, dynamic>) continue;
      final nodeType = child['nodeType'] as String? ?? '';

      if (nodeType == 'text') {
        final text = (child['value'] as String?) ?? '';
        if (text.isEmpty) continue;

        final marks = child['marks'] as List<dynamic>? ?? [];
        bool isBold = false;
        bool isItalic = false;

        for (final m in marks) {
          if (m is! Map<String, dynamic>) continue;
          switch (m['type']) {
            case 'bold':
              isBold = true;
              break;
            case 'italic':
              isItalic = true;
              break;
          }
        }

        spans.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        );
      } else {
        final text = _extractPlainText(child);
        if (text.isNotEmpty) {
          spans.add(TextSpan(text: text));
        }
      }
    }

    return spans;
  }

  static String _extractPlainText(Map<String, dynamic> node) {
    final buffer = StringBuffer();

    void walk(dynamic n) {
      if (n is Map<String, dynamic>) {
        final type = n['nodeType'] as String? ?? '';
        if (type == 'text') {
          final value = n['value'] as String? ?? '';
          buffer.write(value);
        }
        final content = n['content'];
        if (content is List) {
          for (final c in content) {
            walk(c);
          }
        }
      } else if (n is List) {
        for (final c in n) {
          walk(c);
        }
      }
    }

    walk(node);
    return buffer.toString();
  }
}
