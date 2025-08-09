import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../authentication/views/login_screen.dart';
import '../currency_converter/views/amount_input.dart';
import '../currency_converter/views/currency_selector.dart';
import '../currency_converter/views/error_screen.dart';
import '../currency_converter/views/result_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter({required bool isAuthenticated}) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: isAuthenticated ? CurrencySelectorScreen.routeName : LoginScreen.routeName,
      routes: [
        GoRoute(
          path: LoginScreen.routeName,
          pageBuilder: (context, state) => _slide(const LoginScreen()),
        ),
        GoRoute(
          path: CurrencySelectorScreen.routeName,
          pageBuilder: (context, state) => _slide(const CurrencySelectorScreen()),
        ),
        GoRoute(
          path: AmountInputScreen.routeName,
          pageBuilder: (context, state) => _flip(const AmountInputScreen()),
        ),
        GoRoute(
          path: ResultScreen.routeName,
          pageBuilder: (context, state) => _scale(const ResultScreen()),
        ),
        GoRoute(
          path: ErrorScreen.routeName,
          pageBuilder: (context, state) => _slide(const ErrorScreen(), fromRight: false),
        ),
      ],
      redirect: (context, state) {
        final goingToLogin = state.matchedLocation == LoginScreen.routeName;
        if (!isAuthenticated && !goingToLogin) return LoginScreen.routeName;
        if (isAuthenticated && goingToLogin) return CurrencySelectorScreen.routeName;
        return null;
      },
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

  static CustomTransitionPage _flip(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final rotate = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final angle = rotate.value * 3.1415926;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(angle),
              child: child,
            );
          },
        );
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


