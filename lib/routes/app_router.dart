import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/views/login_screen.dart';
import '../features/currency_converter/views/amount_input.dart';
import '../features/currency_converter/views/currency_selector.dart';
import '../features/currency_converter/views/error_screen.dart';
import '../features/currency_converter/views/result_screen.dart';
import 'route_paths.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter({required bool isAuthenticated}) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: isAuthenticated ? RoutePaths.selector : RoutePaths.login,
      routes: [
        GoRoute(
          path: RoutePaths.login,
          pageBuilder: (context, state) => _slide(const LoginScreen()),
        ),
        GoRoute(
          path: RoutePaths.selector,
          pageBuilder: (context, state) => _slide(const CurrencySelectorScreen()),
        ),
        GoRoute(
          path: RoutePaths.amount,
          pageBuilder: (context, state) => _scale(const AmountInputScreen()),
        ),
        GoRoute(
          path: RoutePaths.result,
          pageBuilder: (context, state) => _scale(const ResultScreen()),
        ),
        GoRoute(
          path: RoutePaths.error,
          pageBuilder: (context, state) => _slide(const ErrorScreen(), fromRight: false),
        ),
      ],
    );
  }

  static CustomTransitionPage _slide(Widget child, {bool fromRight = true}) {
    return CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = Offset(fromRight ? 1.0 : -1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }


  static CustomTransitionPage _scale(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return ScaleTransition(scale: curved, child: child);
      },
    );
  }
}


