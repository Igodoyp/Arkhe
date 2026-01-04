import 'package:flutter/material.dart';

/// PageRoute personalizado con transición de fade to black
/// 
/// Simula la experiencia de Dark Souls:
/// 1. Fade out a negro desde la pantalla actual
/// 2. Fade in a negro hacia la nueva pantalla
class BonfirePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  BonfirePageRoute({
    required this.builder,
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Color? get barrierColor => Colors.black;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 2000);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Animación en dos fases:
    // 0.0 - 0.5: Fade out a negro (pantalla actual desaparece)
    // 0.5 - 1.0: Fade in desde negro (nueva pantalla aparece)

    final fadeOut = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    return Stack(
      children: [
        // Pantalla negra como base
        Container(color: Colors.black),

        // Nueva pantalla (fade in desde negro)
        FadeTransition(
          opacity: fadeIn,
          child: child,
        ),

        // Overlay negro que desaparece primero
        FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
          child: Container(color: Colors.black),
        ),
      ],
    );
  }
}
