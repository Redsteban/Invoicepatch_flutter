import 'package:flutter/material.dart';

enum SlideDirection { left, right, up, down }

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final SlideDirection direction;
  
  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Offset begin;
      switch (direction) {
        case SlideDirection.right:
          begin = const Offset(1.0, 0.0);
          break;
        case SlideDirection.left:
          begin = const Offset(-1.0, 0.0);
          break;
        case SlideDirection.up:
          begin = const Offset(0.0, 1.0);
          break;
        case SlideDirection.down:
          begin = const Offset(0.0, -1.0);
          break;
      }
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      var fadeTween = Tween(begin: 0.0, end: 1.0);
      var fadeAnimation = animation.drive(fadeTween);
      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}