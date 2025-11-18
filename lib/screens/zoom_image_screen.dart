import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/app_top_bar.dart';

class ZoomImageScreen extends StatefulWidget {
  final String imageUrl;
  final String? title; // optional

  const ZoomImageScreen({
    super.key,
    required this.imageUrl,
    this.title,
  });

  @override
  State<ZoomImageScreen> createState() => _ZoomImageScreenState();
}

class _ZoomImageScreenState extends State<ZoomImageScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  Animation<Matrix4>? _animation;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        _controller.value = _animation?.value ?? _controller.value;
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(Matrix4 target) {
    _animation = Matrix4Tween(
      begin: _controller.value,
      end: target,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_animController));
    _animController
      ..reset()
      ..forward();
  }

  void _handleDoubleTapDown(TapDownDetails details, BoxConstraints c) {
    final tapPos = details.localPosition;
    final current = _controller.value;

    // If already zoomed in, reset.
    final isZoomed = current.getMaxScaleOnAxis() > 1.05;
    if (isZoomed) {
      _animateTo(Matrix4.identity());
      return;
    }

    // Zoom in to 2x around the tap position.
    final double scale = 2.0;
    final Matrix4 zoom = Matrix4.identity()
      ..translate(-tapPos.dx * (scale - 1), -tapPos.dy * (scale - 1))
      ..scale(scale);

    _animateTo(zoom);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? '';

    return Scaffold(
      // Keep constant green AppBar
      appBar: const AppTopBar(showBack: true),
      backgroundColor: Colors.black, // for immersive viewing
      body: SafeArea(
        child: Column(
          children: [
            // Optional tiny header (hidden if title is too long)
            if (title.trim().isNotEmpty && title.trim().length <= 80)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Zoomable area
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onDoubleTapDown: (d) => _handleDoubleTapDown(d, constraints),
                    onDoubleTap: () {}, // handled in onDoubleTapDown
                    child: Center(
                      child: InteractiveViewer(
                        transformationController: _controller,
                        minScale: 0.8,
                        maxScale: 6.0,
                        boundaryMargin: const EdgeInsets.all(80),
                        panEnabled: true,
                        scaleEnabled: true,
                        clipBehavior: Clip.none,
                        child: Hero(
                          tag: widget.imageUrl,
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Text(
                              '⚠️ Image could not be loaded',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Small hint row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                children: const [
                  _HintChip(text: 'Pinch to zoom'),
                  _HintChip(text: 'Drag to pan'),
                  _HintChip(text: 'Double-tap to zoom'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  final String text;
  const _HintChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.white10,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.white24),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
    );
  }
}
