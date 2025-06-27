/*
** EPITECH PROJECT, 2025
** navigation_helper.dart
** File description:
** Navigation helper for the Epico.
*/

import 'package:flutter/material.dart';

class NavigationHelper {
  static Future<T?> pushFade<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(_fadeRoute<T>(page));
  }

  static PageRouteBuilder<T> _fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}