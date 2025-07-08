import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;
  
  const AnimatedCounter({
    Key? key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '$prefix${value.toStringAsFixed(0)}$suffix',
          style: style,
        );
      },
    );
  }
}