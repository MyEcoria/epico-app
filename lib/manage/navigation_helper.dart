import 'package:flutter/material.dart';

class NavigationHelper {
  static Future<T?> pushFade<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push(_fadeRoute(page));
  }

  static Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
