import 'package:equatable/equatable.dart';

enum ConverterStatus { initial, loading, success, error }

class ConverterState extends Equatable {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final ConverterStatus status;
  final double? rate;
  final double? convertedValue;
  final DateTime? fetchedAt;
  final bool isCached;
  final bool isStale;
  final String? errorMessage;

  const ConverterState({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.status,
    this.rate,
    this.convertedValue,
    this.fetchedAt,
    this.isCached = false,
    this.isStale = false,
    this.errorMessage,
  });

  factory ConverterState.initial() => const ConverterState(
        fromCurrency: 'USD',
        toCurrency: 'INR',
        amount: 0,
        status: ConverterStatus.initial,
      );

  ConverterState copyWith({
    String? fromCurrency,
    String? toCurrency,
    double? amount,
    ConverterStatus? status,
    double? rate,
    double? convertedValue,
    DateTime? fetchedAt,
    bool? isCached,
    bool? isStale,
    String? errorMessage,
  }) {
    return ConverterState(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      rate: rate ?? this.rate,
      convertedValue: convertedValue ?? this.convertedValue,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isCached: isCached ?? this.isCached,
      isStale: isStale ?? this.isStale,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        fromCurrency,
        toCurrency,
        amount,
        status,
        rate,
        convertedValue,
        fetchedAt,
        isCached,
        isStale,
        errorMessage,
      ];
}


