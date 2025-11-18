import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_screen.dart';
import 'features/article/article_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, st) => const HomeScreen()),
    GoRoute(path: '/article/:id', builder: (ctx, st) => ArticleScreen(entryId: st.pathParameters['id']!)),
  ],
  errorBuilder: (ctx, st) => Scaffold(body: Center(child: Text('Not found: ${st.error}'))),
);