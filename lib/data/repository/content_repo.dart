import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../services/contentful_graphql.dart';

final contentRepoProvider = Provider<ContentRepo>((ref) => ContentRepo(ContentfulGraph()));

class ContentRepo {
  final ContentfulGraph graph;
  ContentRepo(this.graph);

  Future<List<Article>> latest({int limit = 20}) async {
    final items = await graph.fetchArticles(limit: limit);
    return items.map(Article.fromGraph).toList();
  }

  Future<Article?> byId(String id) async {
    final n = await graph.fetchArticle(id);
    return n == null ? null : Article.fromGraph(n);
  }
}