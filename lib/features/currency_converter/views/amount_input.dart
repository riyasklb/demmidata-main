import 'dart:ui';
import 'package:currency_converter/features/currency_converter/views/widget/currency_chip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/converter_bloc.dart';
import '../bloc/converter_event.dart';
import '../bloc/converter_state.dart';
import '../../../routes/route_paths.dart';




class AmountInputScreen extends StatefulWidget {
  const AmountInputScreen({super.key});
  @override
  State<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends State<AmountInputScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  late AnimationController _entranceController;
  late Animation<double> _fieldAnim, _chipsAnim, _buttonAnim;
  bool _isConvertPressed = false; 

  @override
  void initState() {
    super.initState();
    final amount = context.read<ConverterBloc>().state.amount;
    if (amount > 0) _controller.text = amount.toString();

    _entranceController = AnimationController(
      vsync: this, duration: Duration(milliseconds: 1100)
    )..forward();
    _fieldAnim = CurvedAnimation(parent: _entranceController, curve: Interval(0.0, 0.4, curve: Curves.easeOut));
    _chipsAnim = CurvedAnimation(parent: _entranceController, curve: Interval(0.3, 0.75, curve: Curves.easeOut));
    _buttonAnim = CurvedAnimation(parent: _entranceController, curve: Interval(0.65, 1.0, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
        
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.indigo.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
       
          Positioned(top: 80, left: 24, child: Icon(Icons.account_balance_wallet, size: 68, color: Colors.white.withOpacity(0.12))),
          Positioned(top: 270, right: 18, child: Icon(Icons.pie_chart, size: 52, color: Colors.white.withOpacity(0.11))),
          Positioned(bottom: 100, left: 60, child: Icon(Icons.attach_money, size: 46, color: Colors.indigo.withOpacity(0.15))),
          Positioned(bottom: -30, right: 40, child: Icon(Icons.monetization_on, size: 70, color: Colors.purpleAccent.withOpacity(0.13))),
        
          Align(
            alignment: Alignment.center,
            child: FadeTransition(
              opacity: _entranceController,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        width: 380,
                        padding: EdgeInsets.symmetric(horizontal: 38, vertical: 48),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(38),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.shade900.withOpacity(0.12),
                              blurRadius: 40,
                              offset: Offset(0, 12),
                            ),
                          ],
                          border: Border.all(color: Colors.white.withOpacity(0.09)),
                        ),
                        child: BlocConsumer<ConverterBloc, ConverterState>(
                          listener: (context, state) {
                         
                            if (!_isConvertPressed) return;
                            if (state.status == ConverterStatus.success) {
                              _isConvertPressed = false; 
                              context.push(RoutePaths.result);
                            } else if (state.status == ConverterStatus.error && state.errorMessage != null) {
                              _isConvertPressed = false;
                              context.push(RoutePaths.error, extra: state.errorMessage);
                            }
                          },
                          builder: (context, state) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FadeTransition(
                                  opacity: _fieldAnim,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Amount',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white.withOpacity(0.95),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: TextField(
                                          controller: _controller,
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Enter amount',
                                            hintStyle: TextStyle(color: Colors.white,),
                                            labelText: 'Amount (${state.fromCurrency})',
                                            labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                          ),
                                          style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                          onChanged: (v) {
                                           
                                            final value = double.tryParse(v) ?? 0;
                                            context.read<ConverterBloc>().add(AmountChanged(value));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 35),
                                FadeTransition(
                                  opacity: _chipsAnim,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CurrencyChip(
                                        currencyCode: state.fromCurrency,
                                        label: 'From',
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 28),
                                      CurrencyChip(
                                        currencyCode: state.toCurrency,
                                        label: 'To',
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 40),
                                ScaleTransition(
  scale: _buttonAnim,
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 19),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple.shade600,
        elevation: 14,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      onPressed: state.status == ConverterStatus.loading
          ? null // disable when loading
          : () {
              final amount = double.tryParse(_controller.text.trim()) ?? 0;
              if (amount <= 0 || amount >= 100000) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Enter amount between 0 and 100,000'))
                );
                return;
              }
              _isConvertPressed = true;
              context.read<ConverterBloc>().add(AmountChanged(amount));
              context.read<ConverterBloc>().add(const ConvertRequested());
            },
      child: state.status == ConverterStatus.loading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
              ),
            )
          : Text('Convert'),
    ),
  ),
)

                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
