import 'package:equatable/equatable.dart';

class ConverterEvent extends Equatable {
  const ConverterEvent();
  @override
  List<Object?> get props => [];
}

class FromCurrencySelected extends ConverterEvent {
  final String code;
  const FromCurrencySelected(this.code);
  @override
  List<Object?> get props => [code];
}

class ToCurrencySelected extends ConverterEvent {
  final String code;
  const ToCurrencySelected(this.code);
  @override
  List<Object?> get props => [code];
}

class AmountChanged extends ConverterEvent {
  final double amount;
  const AmountChanged(this.amount);
  @override
  List<Object?> get props => [amount];
}

class SwapCurrencies extends ConverterEvent {
  const SwapCurrencies();
}

class ConvertRequested extends ConverterEvent {
  const ConvertRequested();
}


