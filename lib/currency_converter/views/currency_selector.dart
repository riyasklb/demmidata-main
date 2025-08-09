import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/converter_bloc.dart';
import '../bloc/converter_event.dart';
import '../bloc/converter_state.dart';
import '../models/currency_model.dart';
import 'amount_input.dart';

class CurrencySelectorScreen extends StatelessWidget {
  static const String routeName = '/selector';
  const CurrencySelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Currencies')),
      body: SafeArea(
        child: BlocBuilder<ConverterBloc, ConverterState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _CurrencyChips(
                    selected: state.fromCurrency,
                    onSelected: (code) => context.read<ConverterBloc>().add(FromCurrencySelected(code)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                      IconButton(
                        onPressed: () => context.read<ConverterBloc>().add(const SwapCurrencies()),
                        icon: const Icon(Icons.swap_horiz, size: 28),
                        tooltip: 'Swap',
                      ),
                      Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('To', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _CurrencyChips(
                    selected: state.toCurrency,
                    onSelected: (code) => context.read<ConverterBloc>().add(ToCurrencySelected(code)),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pushNamed(AmountInputScreen.routeName),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Next'),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CurrencyChips extends StatelessWidget {
  final String selected;
  final void Function(String code) onSelected;
  const _CurrencyChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in supportedCurrencies)
          ChoiceChip(
            label: Text(c.code),
            selected: selected == c.code,
            onSelected: (_) => onSelected(c.code),
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
            shape: StadiumBorder(side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
            labelStyle: TextStyle(
              color: selected == c.code ? Theme.of(context).colorScheme.onPrimaryContainer : null,
              fontWeight: FontWeight.w600,
            ),
          )
      ],
    );
  }
}


