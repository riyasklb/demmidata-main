import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/converter_bloc.dart';
import '../bloc/converter_state.dart';

class ResultScreen extends StatelessWidget {
  static const String routeName = '/result';
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: SafeArea(child: _ResultBody()),
    );
  }
}

class _ResultBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConverterBloc, ConverterState>(
      buildWhen: (p, c) => p.status != c.status || p.convertedValue != c.convertedValue,
      builder: (context, state) {
        if (state.status == ConverterStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ConverterStatus.error) {
          return Center(child: Text(state.errorMessage ?? 'Error'));
        }
        if (state.status != ConverterStatus.success) {
          return const Center(child: Text('No result yet'));
        }
        final value = state.convertedValue ?? 0;
        final rate = state.rate ?? 0;
        final time = state.fetchedAt != null ? TimeOfDay.fromDateTime(state.fetchedAt!) : null;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.isStale)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                  child: const Text('This rate is older than 5 minutes.'),
                ),
              const SizedBox(height: 16),
              Text('Converted Amount', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, val, child) {
                  return Text(
                    '${val.toStringAsFixed(2)} ${state.toCurrency}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Chip(label: Text('Rate: ${rate.toStringAsFixed(5)}')),
                  const SizedBox(width: 8),
                  if (time != null) Chip(label: Text('At: ${time.format(context)}')),
                  const SizedBox(width: 8),
                  if (state.isCached) Chip(label: const Text('Cached')),
                ],
              ),
              const Spacer(),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Start Over'),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}


