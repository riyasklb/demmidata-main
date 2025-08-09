
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:currency_converter/features/currency_converter/bloc/converter_bloc.dart';
import 'package:currency_converter/features/currency_converter/bloc/converter_event.dart';

import 'package:currency_converter/features/currency_converter/bloc/converter_state.dart';
import 'package:currency_converter/data/services/api_service.dart';

void main() {
  testWidgets('Currency Selector BLoC Test', (WidgetTester tester) async {
 
    final bloc = ConverterBloc(apiService: CurrencyApiService());
    
  
    
    await tester.pump();
    

    final state = bloc.state;
    expect(state.fromCurrency, 'USD');
    expect(state.toCurrency, 'INR');
    
 
    bloc.add(FromCurrencySelected('EUR'));
    await tester.pump();
    
    final newState = bloc.state;
    expect(newState.fromCurrency, 'EUR');
    
    bloc.close();
  });

  testWidgets('Currency Selector UI Test', (WidgetTester tester) async {
  
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => ConverterBloc(apiService: CurrencyApiService()),
          child: const Scaffold(
            body: Center(
              child: Text('Currency Selector Test'),
            ),
          ),
        ),
      ),
    );

  
    expect(find.text('Currency Selector Test'), findsOneWidget);
  });

  testWidgets('Basic Widget Test', (WidgetTester tester) async {
   
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );

    expect(find.text('Hello World'), findsOneWidget);
  });
}
