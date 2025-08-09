import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? message = GoRouterState.of(context).extra as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('Offline / Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 64),
              const SizedBox(height: 16),
              Text(message ?? 'We are unable to fetch latest data.'),
              const SizedBox(height: 8),
              const Text('If available, we will show cached values within the last 30 minutes.'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              )
            ],
          ),
        ),
      ),
    );
  }
}


