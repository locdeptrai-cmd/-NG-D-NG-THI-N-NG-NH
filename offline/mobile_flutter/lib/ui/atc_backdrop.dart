import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'atc_theme.dart';

class AtcBackdrop extends StatelessWidget {
  const AtcBackdrop({
    super.key,
    required this.child,
    this.imageAsset,
    this.imageAlignment = Alignment.center,
    this.imageOpacity = 1,
    this.scrimGradient,
    this.showRadar = true,
  });

  final Widget child;
  final String? imageAsset;
  final Alignment imageAlignment;
  final double imageOpacity;
  final Gradient? scrimGradient;
  final bool showRadar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: atcNavy),
        if (imageAsset != null)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.035, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Opacity(
              opacity: imageOpacity,
              child: Image.asset(
                imageAsset!,
                fit: BoxFit.cover,
                alignment: imageAlignment,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        if (scrimGradient != null)
          DecoratedBox(
            decoration: BoxDecoration(gradient: scrimGradient),
          ),
        if (showRadar)
          const IgnorePointer(child: CustomPaint(painter: _RadarPainter())),
        child,
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.82, size.height * 0.18);
    final radius = math.min(size.width, size.height) * 0.58;
    final ring = Paint()
      ..color = atcCyan.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var index = 1; index <= 5; index++) {
      canvas.drawCircle(center, radius * index / 5, ring);
    }
    for (var angle = 0; angle < 360; angle += 30) {
      final radians = angle * math.pi / 180;
      canvas.drawLine(
        center,
        center + Offset(math.cos(radians), math.sin(radians)) * radius,
        ring,
      );
    }
    final sweep = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          atcCyan.withValues(alpha: 0.11),
          Colors.transparent,
        ],
        stops: const [0, 0.08, 0.16],
        transform: const GradientRotation(-0.6),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sweep);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
