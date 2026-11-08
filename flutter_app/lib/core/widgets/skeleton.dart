import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';

/// A quiet block that holds the shape of the content it is replacing.
///
/// No spinner, no sweeping gradient: the block breathes between two opacities
/// and stops moving when the system asks for reduced motion.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height = 14, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }

    final Widget block = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: context.amp.skeleton,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );

    return reduceMotion
        ? block
        : FadeTransition(
            opacity: Tween<double>(begin: 0.55, end: 1).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: block,
          );
  }
}

/// A line that takes a fraction of the available width, left aligned.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.widthFactor = 1, this.height = 12});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Skeleton(height: height, radius: 6),
    );
  }
}

/// The shape of a charger row: glyph square, two text lines, a price block.
///
/// A loader that does not match the real layout makes the screen jump when the
/// data lands; this one does not.
class ChargerRowSkeleton extends StatelessWidget {
  const ChargerRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AmpTheme.spaceM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Skeleton(width: 48, height: 48, radius: 12),
          const SizedBox(width: AmpTheme.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SkeletonLine(widthFactor: 0.7, height: 16),
                const SizedBox(height: AmpTheme.spaceS),
                const SkeletonLine(widthFactor: 0.45, height: 12),
                const SizedBox(height: AmpTheme.spaceS),
                const SkeletonLine(widthFactor: 0.55, height: 12),
              ],
            ),
          ),
          const SizedBox(width: AmpTheme.spaceM),
          const Skeleton(width: 52, height: 20, radius: 6),
        ],
      ),
    );
  }
}
