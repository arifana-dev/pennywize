import 'package:flutter/material.dart';

class SlideRoute<T> extends PageRouteBuilder<T> {
  SlideRoute({required Widget page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (ctx, animation, __, child) {
            final reduceMotion =
                MediaQuery.maybeOf(ctx)?.disableAnimations ?? false;
            if (reduceMotion) {
              return FadeTransition(opacity: animation, child: child);
            }
            final offset = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(offset),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        );
}
