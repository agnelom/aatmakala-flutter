import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/aatmkala_app_bar.dart';
import '../data/contentful/contentful_graphql.dart';
import '../theme/sattva_theme.dart';
// import '../widgets/app_top_bar.dart'; // no longer needed on Home
import 'section_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final ContentfulGraph contentful;
  const HomeScreen({super.key, required this.contentful});

  // Marathi overrides for specific sections
  static const Map<String, String> _titleOverrides = {
    'ScienceAndReligion': 'विज्ञान आणि धर्म',
    'Science & Religion': 'विज्ञान आणि धर्म',
  };

  String _displayTitle(String id, String title) {
    return _titleOverrides[id] ?? _titleOverrides[title] ?? title;
  }

  @override
  Widget build(BuildContext context) {
    final sections = contentful.fetchSections();
    final screenWidth = MediaQuery.of(context).size.width;

    // Phones stay 2 columns; web/desktop 3 columns.
    final bool isPhone = screenWidth < 600;
    final int crossAxisCount = isPhone ? 2 : 3;

    // On large screens, center the grid and cap its width to avoid huge tiles.
    final double maxGridWidth = 800.0; // was 900; now smaller to avoid scroll

    return Scaffold(
      appBar: const AatmkalaAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Saffron banner (fixed on Home)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: SattvaTheme.saffron,
              child: const Column(
                children: [
                  Text(
                    'Aatmkala',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '"Healthy Body, Healthy Mind, Happy Life"',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Grid (fills remaining height). On desktop it computes aspect so 3x2 fits perfectly.
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Remaining area (beneath the saffron banner + above footer)
                  final double availableHeight = constraints.maxHeight;

                  // Centered grid container width
                  final double gridWidth =
                      math.min(constraints.maxWidth, maxGridWidth);

                  // Padding inside grid container
                  const double pad = 16.0;
                  const double spacing = 16.0;

                  // Effective content width/height after padding
                  final double contentWidth = gridWidth - (pad * 2);
                  final double contentHeight = availableHeight - (pad * 2);

                  // Compute a childAspectRatio that fits rows exactly on desktop
                  double childAspectRatio;
                  if (isPhone) {
                    // Keep square-ish tiles on phones; scrolling is OK if needed.
                    childAspectRatio = 1.0;
                  } else {
                    // We want exactly 2 rows visible (3 columns). For 2 rows:
                    // tileHeight = (contentHeight - (rows-1)*spacing) / rows
                    const int rows = 2;
                    final double tileHeight =
                        (contentHeight - (rows - 1) * spacing) / rows;

                    // For 3 columns:
                    // tileWidth = (contentWidth - (cols-1)*spacing) / cols
                    const int cols = 3;
                    final double tileWidth =
                        (contentWidth - (cols - 1) * spacing) / cols;

                    // Aspect ratio = width / height
                    childAspectRatio = tileWidth / tileHeight;

                    // Clamp to keep visuals reasonable if window gets very short/tall
                    childAspectRatio = childAspectRatio.clamp(0.85, 1.35);
                  }

                  return Center(
                    child: Container(
                      width: gridWidth,
                      padding: const EdgeInsets.all(pad),
                      color: SattvaTheme.cream,
                      child: GridView.builder(
                        // On desktop, we ensure there is no scroll by fitting 2 rows.
                        // On phone, allow scroll naturally if needed.
                        physics: isPhone
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        itemCount: sections.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          final s = sections[index];
                          final resolvedTitle = _displayTitle(s.id, s.title);

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                SectionListScreen.routeName,
                                arguments: SectionListArgs(
                                  sectionId: s.id,
                                  title: resolvedTitle,
                                ),
                              );
                            },
                            child: Card(
                              color: SattvaTheme.saffron,
                              elevation: 5,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Center(
                                  child: Text(
                                    resolvedTitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: SattvaTheme.saffron,
              child: const Center(
                child: Text(
                  '© 2025 Aatmkala. All rights reserved.',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
