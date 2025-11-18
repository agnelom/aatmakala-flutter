import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/env.dart';

class ContentfulRest {
  final _base = 'https://cdn.contentful.com';

  Future<Map<String, dynamic>> entries({String contentType = 'article', int limit = 20}) async {
    final uri = Uri.parse('$_base/spaces/${Env.contentfulSpaceId}/environments/${Env.contentfulEnvironment}/entries')
        .replace(queryParameters: {
      'content_type': contentType,
      'limit': '$limit',
      'order': '-sys.updatedAt',
    });
    final res = await http.get(uri, headers: {'Authorization': 'Bearer ${Env.contentfulToken}'});
    if (res.statusCode != 200) throw Exception('Contentful error: ${res.statusCode}');
    return json.decode(res.body) as Map<String, dynamic>;
  }
}
