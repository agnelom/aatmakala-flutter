import 'package:flutter/material.dart';
import '../widgets/aatmkala_app_bar.dart';
import '../data/contentful/contentful_graphql.dart';
import '../theme/sattva_theme.dart';
import 'article_detail_screen.dart';

class SectionListArgs {
  final String sectionId;
  final String title;
  const SectionListArgs({required this.sectionId, required this.title});
}

class SectionListScreen extends StatefulWidget {
  static const routeName = '/section';
  final ContentfulGraph contentful;
  final SectionListArgs args;

  const SectionListScreen({
    super.key,
    required this.contentful,
    required this.args,
  });

  @override
  State<SectionListScreen> createState() => _SectionListScreenState();
}

class _SectionListScreenState extends State<SectionListScreen> {
  final int _pageSize = 10; // how many articles per "page"
  final List<Map<String, dynamic>> _allItems = [];
  final List<Map<String, dynamic>> _visibleItems = [];
  late final ScrollController _scrollController;

  bool _initialLoading = true;
  bool _loadingMore = false;
  String? _error;
  int _loadedCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _initialLoading = true;
      _error = null;
    });

    try {
      final items =
          await widget.contentful.fetchEntriesForSection(widget.args.sectionId);

      _allItems.clear();
      _allItems.addAll(items);

      _visibleItems.clear();
      _loadedCount = 0;
      _appendNextPage();

      setState(() {
        _initialLoading = false;
      });
    } catch (e) {
      setState(() {
        _initialLoading = false;
        _error = e.toString();
      });
    }
  }

  void _appendNextPage() {
    if (_loadedCount >= _allItems.length) return;

    final nextEnd = (_loadedCount + _pageSize).clamp(0, _allItems.length);
    _visibleItems.addAll(_allItems.sublist(_loadedCount, nextEnd));
    _loadedCount = nextEnd;
  }

  bool get _hasMore => _loadedCount < _allItems.length;

  void _onScroll() {
    if (!_hasMore || _loadingMore || _initialLoading) return;

    // Load more when we are near the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;

    setState(() {
      _loadingMore = true;
    });

    await Future.delayed(const Duration(milliseconds: 200));
    // In the future, this is where we'll call a real paged Contentful method
    setState(() {
      _appendNextPage();
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
      appBar: AatmkalaAppBar(
        showBack: true,
        titleText: args.title,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Saffron banner – section name
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
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_visibleItems.isEmpty) {
      return const Center(child: Text('No content found.'));
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _visibleItems.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= _visibleItems.length) {
            // "Loading more..." indicator row
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final item = _visibleItems[index];

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
      ),
    );
  }
}
