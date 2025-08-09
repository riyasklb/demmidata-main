import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/converter_bloc.dart';
import '../bloc/converter_event.dart';
import '../bloc/converter_state.dart';
import 'package:go_router/go_router.dart';
import '../../routes/route_paths.dart';

class AmountInputScreen extends StatefulWidget {
  const AmountInputScreen({super.key});

  @override
  State<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends State<AmountInputScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final amount = context.read<ConverterBloc>().state.amount;
    if (amount > 0) _controller.text = amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Amount')),
      body: SafeArea(
        child: BlocConsumer<ConverterBloc, ConverterState>(
          listener: (context, state) {
            if (state.status == ConverterStatus.success || state.status == ConverterStatus.loading) {
              context.push(RoutePaths.result);
            } else if (state.status == ConverterStatus.error && state.errorMessage != null) {
              context.push(RoutePaths.error, extra: state.errorMessage);
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (${state.fromCurrency})',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      final value = double.tryParse(v) ?? 0;
                      context.read<ConverterBloc>().add(AmountChanged(value));
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Chip(label: Text('From: ${state.fromCurrency}')),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward),
                      const SizedBox(width: 10),
                      Chip(label: Text('To: ${state.toCurrency}')),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final amount = double.tryParse(_controller.text.trim()) ?? 0;
                        if (amount <= 0 || amount >= 100000) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Enter amount between 0 and 100,000')));
                          return;
                        }
                        context.read<ConverterBloc>().add(AmountChanged(amount));
                        context.read<ConverterBloc>().add(const ConvertRequested());
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Convert'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


