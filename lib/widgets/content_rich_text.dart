import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ContentHtml extends StatelessWidget {
  final String html;
  const ContentHtml(this.html, {super.key});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      html,
      textStyle: Theme.of(context).textTheme.bodyMedium,
      renderMode: RenderMode.column,
      onTapUrl: (url) => true,
    );
  }
}