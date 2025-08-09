import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/authentication/bloc/auth_bloc.dart';
import 'features/authentication/bloc/auth_event.dart';
import 'features/authentication/bloc/auth_state.dart';
// ignore: unused_import
import 'features/authentication/views/login_screen.dart';
import 'features/currency_converter/bloc/converter_bloc.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'routes/app_router.dart';

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
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isAuthenticated = state is Authenticated;
          final router = AppRouter.createRouter(isAuthenticated: isAuthenticated);
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Currency Converter',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            routerDelegate: router.routerDelegate,
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider,
          );
        },
      ),
    );
  }

}


