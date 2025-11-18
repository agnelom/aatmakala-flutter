import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/env.dart';
import '../../core/error_logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


/// Guard before making a network-based call to Graphql
Future<void> _ensureOnline() async {
  final c = await Connectivity().checkConnectivity();
  if (c == ConnectivityResult.none) {
    throw Exception('No internet connection. Please connect and try again.');
  }
}


/// Top-level section model: mirrors your index.html menu.
class SectionConfig {
  final String id;          // internal key (e.g. 'patanjali2')
  final String title;       // display title
  final String description; // optional subtitle
  final String collection;  // GraphQL collection name (e.g. 'patanjali2Collection')

  const SectionConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.collection,
  });
}

/// GraphQL service for Contentful (CDA).
/// - One codepath for Web + Mobile.
/// - Section → Entries → Article detail flow, like your HTML site.
class ContentfulGraph {
  late final GraphQLClient client;

  ContentfulGraph() {
    final endpoint = Env.graphqlEndpoint;

    Log.d('Graph endpoint => $endpoint');
    Log.d('Token present? ${Env.contentfulToken.isNotEmpty} len=${Env.contentfulToken.length}');

    final link = HttpLink(
      endpoint,
      defaultHeaders: {
        'Authorization': 'Bearer ${Env.contentfulToken}',
      },
    );

    client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );
  }

  /// Static definition of sections (replicates index.html menu).
  /// Adjust titles/descriptions as per your existing site.
  List<SectionConfig> fetchSections() {
    return const [
      SectionConfig(
        id: 'kaavya',
        title: 'काव्य',
        description: 'Poems & devotional verses',
        collection: 'kaavyaCollection',
      ),
      SectionConfig(
        id: 'kaavyaManthan',
        title: 'काव्य मंथन',
        description: 'Reflections & commentary',
        collection: 'kaavyaManthanCollection',
      ),
      SectionConfig(
        id: 'patanjali2',
        title: 'पतंजलि योग',
        description: 'Patanjali Yog articles',
        collection: 'patanjali2Collection',
      ),
      SectionConfig(
        id: 'qanda',
        title: 'प्रश्नोत्तर',
        description: 'Q & A with Swamiji',
        collection: 'qandACollection',
      ),
      SectionConfig(
        id: 'schedule',
        title: 'कार्यक्रम',
        description: 'Events & schedule',
        collection: 'scheduleCollection',
      ),
      SectionConfig(
        id: 'scienceAndReligion',
        title: 'Science & Religion',
        description: 'Talks & articles',
        collection: 'scienceAndReligionCollection',
      ),
    ];
  }

  /// List page: fetch all entries for a given section/content type.
  ///
  /// [sectionId] should be one of the ids from [fetchSections].
  /// Returns a list of simplified maps for UI consumption:
  /// {
  ///   'id': String,
  ///   'title': String,
  ///   'slug': String?,
  ///   'excerpt': String?,
  ///   'imageUrl': String?,
  /// }
    Future<List<Map<String, dynamic>>> fetchEntriesForSection(String sectionId) async {
    await _ensureOnline();
    final section = fetchSections().firstWhere(
      (s) => s.id == sectionId,
      orElse: () {
        throw ArgumentError('Unknown sectionId: $sectionId');
      },
    );

    // 🔹 Special handling for Kaavya (PoemTitle + PoemImage)
    if (section.id == 'kaavya') {
      const kaavyaQuery = '''
        query KaavyaEntries {
          kaavyaCollection(order: sys_publishedAt_DESC) {
            items {
              sys { id }
              poemTitle
              poemImage {
                url
              }
            }
          }
        }
      ''';

      try {
        final res = await client.query(
          QueryOptions(
            document: gql(kaavyaQuery),
            fetchPolicy: FetchPolicy.networkOnly,
          ),
        );

        if (res.hasException) {
          Log.e('GraphQL exception in fetchEntriesForSection(kaavya): ${res.exception}');
          throw res.exception!;
        }

        final raw = (res.data?['kaavyaCollection']?['items'] as List?) ?? const [];

        return raw.map<Map<String, dynamic>>((item) {
          final sys = item['sys'] as Map<String, dynamic>?;
          final img = item['poemImage'] as Map<String, dynamic>?;

          return {
            'id': sys?['id'] as String?,
            'title': item['poemTitle'] as String? ?? '',
            'excerpt': '',
            'imageUrl': img?['url'] as String?,
          };
        }).where((m) => (m['id'] as String?)?.isNotEmpty == true).toList();
      } catch (e, st) {
        Log.e('Contentful fetchEntriesForSection(kaavya) failed', e, st);
        rethrow;
      }
    }

    // 🔹 Default handling for all *other* sections
    final query = '''
      query SectionEntries {
        ${section.collection}(order: sys_publishedAt_DESC) {
          items {
            sys { id }
            title
          }
        }
      }
    ''';

    try {
      final res = await client.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (res.hasException) {
        Log.e('GraphQL exception in fetchEntriesForSection($sectionId): ${res.exception}');
        throw res.exception!;
      }

      final raw = (res.data?[section.collection]?['items'] as List?) ?? const [];

      return raw.map<Map<String, dynamic>>((item) {
        final sys = item['sys'] as Map<String, dynamic>?;

        return {
          'id': sys?['id'] as String?,
          'title': item['title'] as String? ?? '',
          'excerpt': '',
          'imageUrl': null,
        };
      }).where((m) => (m['id'] as String?)?.isNotEmpty == true).toList();
    } catch (e) {
        if (e.toString().contains('SocketException')) {
          throw Exception('Unable to reach server. If you are on mobile data, check Private DNS / VPN / Data Saver.');
        }
        rethrow;
    }
  }



  /// Common article-detail fetch.
  ///
  /// Uses Contentful `entry(id: ...)` with inline fragments so one template
  /// widget can render any type.
  ///
  /// Returns:
  /// {
  ///   'id': String,
  ///   'title': String,
  ///   'body': String?,           // flattened from rich-text/fields where possible
  ///   'imageUrl': String?,
  ///   'type': String,            // __typename
  ///   ...other raw fields
  /// }
  /// Fetch a single article by sys.id across all known collections.
  ///
  /// This matches how we navigate: from a list item (with sys.id) to a
  /// common detail page, without needing to know the concrete content type.
    /// Fetch a single entry by sys.id across known collections.
  ///
  /// We:
  /// - Search each collection with a where filter on sys.id
  /// - Return the first match as a normalized { id, type, title, body }
  /// - Avoid querying non-existent fields (fixes Kaavya errors)
    Future<Map<String, dynamic>?> fetchArticle(String id) async {
    await _ensureOnline();
    const query = r'''
      query GetEntry($id: String!) {
        patanjali2Collection(where: { sys: { id: $id } }, limit: 1) {
          items {
            sys { id }
            title
            body
          }
        }
        kaavyaManthanCollection(where: { sys: { id: $id } }, limit: 1) {
          items {
            sys { id }
            title
            body
          }
        }
        scienceAndReligionCollection(where: { sys: { id: $id } }, limit: 1) {
          items {
            sys { id }
            title
            body
          }
        }
        qandACollection(where: { sys: { id: $id } }, limit: 1) {
          items {
            sys { id }
            title
            body
          }
        }
        scheduleCollection(where: { sys: { id: $id } }, limit: 1) {
          items {
            sys { id }
            title
            date
          }
        }
        # Kaavya: poemTitle + poemImage
        kaavyaCollection(where: { sys: { id: $id } }, limit: 1) {
          items {
            sys { id }
            poemTitle
            poemImage {
              url
            }
          }
        }
      }
    ''';

    try {
      final res = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (res.hasException) {
        Log.e('GraphQL exception in fetchArticle: ${res.exception}');
        throw res.exception!;
      }

      final data = res.data ?? const {};

      Map<String, dynamic>? picked;
      String? type;

      Map<String, dynamic>? pickFrom(String key, String t) {
        final col = data[key] as Map<String, dynamic>?;
        final items = col?['items'] as List?;
        if (items != null && items.isNotEmpty) {
          type = t;
          return items.first as Map<String, dynamic>;
        }
        return null;
      }

      picked = pickFrom('patanjali2Collection', 'Patanjali2') ??
          pickFrom('kaavyaManthanCollection', 'KaavyaManthan') ??
          pickFrom('scienceAndReligionCollection', 'ScienceAndReligion') ??
          pickFrom('qandACollection', 'QandA') ??
          pickFrom('scheduleCollection', 'Schedule') ??
          pickFrom('kaavyaCollection', 'Kaavya');

      if (picked == null) {
        Log.e('fetchArticle: no entry found for id=$id');
        return null;
      }

      // 🔹 Common normalized fields
      final sys = picked['sys'] as Map<String, dynamic>?;
      final sysId = (sys?['id'] as String?) ?? id;

      String title = '';
      String body = '';
      String? imageUrl;

      // 🔹 Handle per-content-type logic
      switch (type) {
        case 'Patanjali2':
        case 'KaavyaManthan':
        case 'ScienceAndReligion':
        case 'QandA':
          title = (picked['title'] as String?) ?? '';
          body = (picked['body'] as String?) ??
              (picked['content'] as String?) ??
              '';
          break;

        case 'Schedule':
          title = (picked['title'] as String?) ?? '';
          body = (picked['date'] as String?) ?? '';
          break;

        case 'Kaavya':
          title = (picked['poemTitle'] as String?) ?? 'Kaavya Poem';
          final img = picked['poemImage'] as Map<String, dynamic>?;
          imageUrl = img?['url'] as String?;
          body = ''; // Kaavya is image + title, no long text
          break;

        default:
          title = (picked['title'] as String?) ?? '';
          body = (picked['body'] as String?) ??
              (picked['content'] as String?) ??
              (picked['description'] as String?) ??
              '';
      }

      return {
        'id': sysId,
        'type': type ?? 'Unknown',
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'raw': picked,
      };
    } catch (e, st) {
      Log.e('Contentful fetchArticle failed', e, st);
      rethrow;
    }
  }
}
