import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/api_service.dart';
import 'converter_event.dart';
import 'converter_state.dart';

class ConverterBloc extends Bloc<ConverterEvent, ConverterState> {
  final CurrencyApiService apiService;

  ConverterBloc({required this.apiService}) : super(ConverterState.initial()) {
    on<FromCurrencySelected>((event, emit) => emit(state.copyWith(fromCurrency: event.code)));
    on<ToCurrencySelected>((event, emit) => emit(state.copyWith(toCurrency: event.code)));
    on<AmountChanged>((event, emit) => emit(state.copyWith(amount: event.amount)));
    on<SwapCurrencies>((event, emit) => emit(state.copyWith(fromCurrency: state.toCurrency, toCurrency: state.fromCurrency)));
    on<ConvertRequested>(_onConvertRequested);
  }

  Future<void> _onConvertRequested(ConvertRequested event, Emitter<ConverterState> emit) async {
    if (state.amount <= 0 || state.amount >= 100000) {
      emit(state.copyWith(status: ConverterStatus.error, errorMessage: 'Enter amount between 0 and 100,000'));
      return;
    }
    emit(state.copyWith(status: ConverterStatus.loading, errorMessage: null));
    try {
      final result = await apiService.getBestRate(state.fromCurrency, state.toCurrency);
      final converted = state.amount * result.rate;
      emit(state.copyWith(
        status: ConverterStatus.success,
        rate: result.rate,
        convertedValue: converted,
        fetchedAt: result.fetchedAt,
        isCached: result.fromCache,
        isStale: result.isOlderThan5Min,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: ConverterStatus.error, errorMessage: 'Unable to fetch rate. Please try again.'));
    }
  }
}


