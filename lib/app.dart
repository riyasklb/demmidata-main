import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'authentication/bloc/auth_bloc.dart';
import 'authentication/bloc/auth_event.dart';
import 'authentication/bloc/auth_state.dart';
import 'authentication/views/login_screen.dart';
import 'currency_converter/bloc/converter_bloc.dart';
import 'currency_converter/views/amount_input.dart';
import 'currency_converter/views/currency_selector.dart';
import 'currency_converter/views/error_screen.dart';
import 'currency_converter/views/result_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final apiService = CurrencyApiService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authService: authService)..add(AppStarted()),
        ),
        BlocProvider<ConverterBloc>(
          create: (_) => ConverterBloc(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Currency Converter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        onGenerateRoute: _onGenerateRoute,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is Authenticated) {
              return const CurrencySelectorScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    WidgetBuilder builder;
    switch (settings.name) {
      case CurrencySelectorScreen.routeName:
        builder = (_) => const CurrencySelectorScreen();
        return _buildSlideRoute(builder, settings);
      case AmountInputScreen.routeName:
        builder = (_) => const AmountInputScreen();
        return _buildFlipRoute(builder, settings);
      case ResultScreen.routeName:
        builder = (_) => const ResultScreen();
        return _buildScaleRoute(builder, settings);
      case ErrorScreen.routeName:
        builder = (_) => const ErrorScreen();
        return _buildSlideRoute(builder, settings, fromRight: false);
      case LoginScreen.routeName:
        builder = (_) => const LoginScreen();
        return _buildSlideRoute(builder, settings, fromRight: false);
      default:
        builder = (_) => const CurrencySelectorScreen();
        return _buildSlideRoute(builder, settings);
    }
  }

  PageRoute _buildSlideRoute(WidgetBuilder builder, RouteSettings settings, {bool fromRight = true}) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = Offset(fromRight ? 1.0 : -1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  PageRoute _buildFlipRoute(WidgetBuilder builder, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
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

  PageRoute _buildScaleRoute(WidgetBuilder builder, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return ScaleTransition(scale: curved, child: child);
      },
    );
  }
}


