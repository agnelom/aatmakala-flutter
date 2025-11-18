class Article {
  final String id;
  final String title;
  final String? bodyHtml;
  final String? imageUrl;

  Article({required this.id, required this.title, this.bodyHtml, this.imageUrl});

    factory Article.fromGraph(Map<String, dynamic> n) {
    final type = (n['__typename'] as String?) ?? '';

    // Title per type
    String? title;
    switch (type) {
        case 'Kaavya':
        title = n['poemTitle'] as String?;
        break;
        default:
        title = n['title'] as String?;
    }
    title ??= 'Untitled';

    // Body (where available)
    String? body;
    switch (type) {
        case 'KaavyaManthan':
        case 'Patanjali2':
        case 'QandA':
        case 'ScienceAndReligion':
        body = n['body'] as String?;
        break;
        case 'Schedule':
        final date = n['date'] as String?;
        body = (date != null) ? 'Date: $date' : null;
        break;
        case 'Kaavya':
        body = null; // no body field in schema dump
        break;
        default:
        body = n['body'] as String?;
    }

    // Image
    String? imageUrl;
    if (type == 'Kaavya') {
        final img = n['poemImage'];
        if (img is Map && img['url'] is String) {
        imageUrl = 'https:${img['url']}';
        }
    } else {
        // Some types might add an image later; try common ids just in case
        for (final k in ['image', 'heroImage', 'thumbnail', 'cover']) {
        final m = n[k];
        if (m is Map && m['url'] is String) {
            imageUrl = 'https:${m['url']}';
            break;
        }
        }
    }

    return Article(
        id: (n['sys']?['id'] as String?) ?? '',
        title: title,
        bodyHtml: body,   // rendered by ContentHtml widget
        imageUrl: imageUrl,
    );
    }


}