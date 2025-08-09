import 'dart:ui';
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

  @override
  void initState() {
    super.initState();
    final amount = context.read<ConverterBloc>().state.amount;
    if (amount > 0) _controller.text = amount.toString();
    _entranceController = AnimationController(vsync: this, duration: Duration(milliseconds: 1100))..forward();
    _fieldAnim = CurvedAnimation(parent: _entranceController, curve: Interval(0.0, 0.40, curve: Curves.easeOut));
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
      // Animated gradient background
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.tealAccent.shade100, Colors.indigo.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Abstract shapes for accent
          Positioned(top: 60, left: -32, child: CircleAvatar(radius: 38, backgroundColor: Colors.white.withOpacity(0.11))),
          Positioned(bottom: -20, right: -20, child: CircleAvatar(radius: 58, backgroundColor: Colors.indigo.withOpacity(0.13))),
          Align(
            alignment: Alignment.center,
            child: FadeTransition(
              opacity: _entranceController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: 370,
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 34),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.12),
                            blurRadius: 24,
                            offset: Offset(0, 16),
                          ),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated entry for field
                              SlideTransition(
                                position: Tween<Offset>(begin: Offset(0, 0.16), end: Offset.zero).animate(_fieldAnim),
                                child: TextField(
                                  controller: _controller,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Amount (${state.fromCurrency})',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.13),
                                  ),
                                  style: TextStyle(fontSize: 18, color: Colors.indigo[900]),
                                  onChanged: (v) {
                                    final value = double.tryParse(v) ?? 0;
                                    context.read<ConverterBloc>().add(AmountChanged(value));
                                  },
                                ),
                              ),
                              SizedBox(height: 28),
                              FadeTransition(
                                opacity: _chipsAnim,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _AnimatedChip(label: 'From: ${state.fromCurrency}'),
                                    SizedBox(width: 10),
                                    Icon(Icons.arrow_forward, color: Colors.indigo[900], size: 22),
                                    SizedBox(width: 10),
                                    _AnimatedChip(label: 'To: ${state.toCurrency}'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30),
                              ScaleTransition(
                                scale: _buttonAnim,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: Colors.indigo.shade600,
                                      foregroundColor: Colors.tealAccent,
                                      elevation: 11,
                                      shadowColor: Colors.indigo.shade300,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    onPressed: () {
                                      final amount = double.tryParse(_controller.text.trim()) ?? 0;
                                      if (amount <= 0 || amount >= 100000) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Enter amount between 0 and 100,000')));
                                        return;
                                      }
                                      context.read<ConverterBloc>().add(AmountChanged(amount));
                                      context.read<ConverterBloc>().add(const ConvertRequested());
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      child: Text('Convert',
                                          style: TextStyle(
                                              fontSize: 19,
                                              letterSpacing: 0.3,
                                              fontWeight: FontWeight.w600)),
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
            ),
          ),
        ],
      ),
    );
  }
}

// Chip with animation (can be further customized)
class _AnimatedChip extends StatelessWidget {
  final String label;
  const _AnimatedChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 410),
      builder: (context, scale, _) => Transform.scale(
        scale: scale,
        child: Chip(
          label: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[900])),
          backgroundColor: Colors.tealAccent.withOpacity(0.18),
          elevation: 6,
        ),
      ),
    );
  }
}
