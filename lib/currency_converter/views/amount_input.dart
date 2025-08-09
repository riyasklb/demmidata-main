import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart'; // Add to pubspec
import '../bloc/converter_bloc.dart';
import '../bloc/converter_event.dart';
import '../bloc/converter_state.dart';
import '../../routes/route_paths.dart';

class AmountInputScreen extends StatefulWidget {
  const AmountInputScreen({super.key});
  @override
  State<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends State<AmountInputScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late final AnimationController _entryController;
  late final Animation<double> _fieldAnim, _chipsAnim, _buttonAnim;

  @override
  void initState() {
    super.initState();
    final amount = context.read<ConverterBloc>().state.amount;
    if (amount > 0) _controller.text = amount.toString();
    _entryController = AnimationController(vsync: this, duration: Duration(milliseconds: 1100))..forward();
    _fieldAnim = CurvedAnimation(parent: _entryController, curve: Interval(0.0, 0.45, curve: Curves.easeOut));
    _chipsAnim = CurvedAnimation(parent: _entryController, curve: Interval(0.3, 0.7, curve: Curves.easeOut));
    _buttonAnim = CurvedAnimation(parent: _entryController, curve: Interval(0.65, 1.0, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _entryController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.tealAccent.shade100],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
          ),
          // Subtle glass-like overlay
          Positioned(
            top: 80, left: 16, right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: BlocConsumer<ConverterBloc, ConverterState>(
                    listener: (context, state) {
                      if (state.status == ConverterStatus.success || state.status == ConverterStatus.loading) {
                        context.push(RoutePaths.result);
                      } else if (state.status == ConverterStatus.error && state.errorMessage != null) {
                        context.push(RoutePaths.error, extra: state.errorMessage);
                      }
                    },
                    builder: (context, state) {
                      return Column(mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated icon/header
                       
                       
                       
                          // Staggered entry: Amount input
                          SlideTransition(
                            position: Tween<Offset>(begin: Offset(0, 0.16), end: Offset.zero).animate(_fieldAnim),
                            child: TextField(
                              controller: _controller,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Amount (${state.fromCurrency})',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.14),
                              ),
                              style: TextStyle(fontSize: 18, color: Colors.indigo[900]),
                              onChanged: (v) {
                                final value = double.tryParse(v) ?? 0;
                                context.read<ConverterBloc>().add(AmountChanged(value));
                              },
                            ),
                          ),
                          SizedBox(height: 22),
                          // Currency chips with animated entry
                          FadeTransition(
                            opacity: _chipsAnim,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Chip(
                                  label: Text('From: ${state.fromCurrency}',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                                  ),
                                  backgroundColor: Colors.tealAccent.withOpacity(0.16),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward, color: Colors.indigo),
                                SizedBox(width: 10),
                                Chip(
                                  label: Text('To: ${state.toCurrency}',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                                  ),
                                  backgroundColor: Colors.tealAccent.withOpacity(0.16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Animated Hero convert button
                          Hero(
                            tag: 'convert_button',
                            child: ScaleTransition(
                              scale: _buttonAnim,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.tealAccent,
                                    elevation: 9,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                  ),
                                  onPressed: () {
                                    final amount = double.tryParse(_controller.text.trim()) ?? 0;
                                    if (amount <= 0 || amount >= 100000) {
                                      // Simple shake micro-animation (optional)
                                      ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(content: Text('Enter amount between 0 and 100,000')));
                                      return;
                                    }
                                    context.read<ConverterBloc>().add(AmountChanged(amount));
                                    context.read<ConverterBloc>().add(const ConvertRequested());
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Text('Convert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
