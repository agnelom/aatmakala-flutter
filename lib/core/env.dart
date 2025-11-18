import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration for Aatmkala app.
///
/// This reads from two possible sources:
/// 1️⃣  assets/env/.env  → loaded using flutter_dotenv (great for local dev)
/// 2️⃣  --dart-define flags at build/run time  → for secure CI or production
///
/// Usage examples:
///   Env.graphqlEndpoint
///   Env.contentfulToken
class Env {
  /// GraphQL endpoint for Contentful.
  ///
  /// Priority:
  /// 1. .env file key CONTENTFUL_GRAPHQL_ENDPOINT
  /// 2. --dart-define CONTENTFUL_GRAPHQL_ENDPOINT
  /// 3. Empty string (fallback)
  static String get graphqlEndpoint =>
      dotenv.env['CONTENTFUL_GRAPHQL_ENDPOINT'] ??
      const String.fromEnvironment(
        'CONTENTFUL_GRAPHQL_ENDPOINT',
        defaultValue: '',
      );

  /// Contentful Delivery API access token.
  ///
  /// Priority:
  /// 1. .env file key CONTENTFUL_DELIVERY_TOKEN
  /// 2. --dart-define CONTENTFUL_DELIVERY_TOKEN
  /// 3. Empty string (fallback)
  static String get contentfulToken =>
      dotenv.env['CONTENTFUL_DELIVERY_TOKEN'] ??
      const String.fromEnvironment(
        'CONTENTFUL_DELIVERY_TOKEN',
        defaultValue: '',
      );

  /// Utility to print current environment values for debugging.
  static void debugPrintEnv() {
    // We don't print actual token values for security reasons.
    final token = contentfulToken.isNotEmpty
        ? 'present (len=${contentfulToken.length})'
        : 'missing';
    final endpoint = graphqlEndpoint.isNotEmpty
        ? graphqlEndpoint
        : '(missing endpoint)';

    // ignore: avoid_print
    print('🔧 Env → endpoint=$endpoint, token=$token');
  }
}
