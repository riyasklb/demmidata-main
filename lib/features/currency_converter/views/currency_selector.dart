// currency_selector_improved.dart
import 'dart:ui';

import 'package:currency_converter/data/models/currency_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/converter_bloc.dart';
import '../bloc/converter_event.dart';

import '../../../routes/route_paths.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_event.dart';



class CurrencySelectorScreen extends StatefulWidget {
  const CurrencySelectorScreen({super.key});

  @override
  State<CurrencySelectorScreen> createState() => _CurrencySelectorScreenState();
}

class _CurrencySelectorScreenState extends State<CurrencySelectorScreen>
    with TickerProviderStateMixin {
  late final AnimationController _contentController;
  late final AnimationController _swapController;

  String? _fromCode;
  String? _toCode;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _swapController.dispose();
    super.dispose();
  }

  // Helper: builds a nice dropdown form field with label + icon.
  Widget _currencyDropdown({
    required String label,
    required String? currentValue,
    required ValueChanged<String?> onChanged,
    required Animation<double> entrance,
  }) {
    return FadeTransition(
      opacity: entrance,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Material(
            color: Colors.white.withOpacity(0.06),
            elevation: 0,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                value: currentValue,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                dropdownColor: Colors.indigo[900],
                icon:
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: supportedCurrencies.map<DropdownMenuItem<String>>((c) {
                  // If your Currency model has code & name use them:
                  final code = (c.code ?? c.toString()) as String;
                  final label = (c.name ?? c.code ?? c.toString()) as String;
                  return DropdownMenuItem(
                    value: code,
                    child: Row(
                      children: [
                        // small spacer for potential flag
                        // You can replace this with flag widget if available.
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$code  —  $label',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                isExpanded: true,
                iconEnabledColor: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Entrance animations with small stagger
    final fromAnim = CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOut));
    final toAnim = CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.45, 0.9, curve: Curves.easeOut));

    final maxWidth = MediaQuery.of(context).size.width * 0.92;
    final cardWidth = maxWidth > 600 ? 600.0 : maxWidth;

    return Scaffold(
      // Keep background gradient subtle and modern
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 97, 64, 155),
                  Colors.indigo.shade700
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // soft abstract blobs
          Positioned(
            left: -80,
            top: 40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigoAccent.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: -120,
            bottom: -40,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigoAccent.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: CurvedAnimation(
                    parent: _contentController, curve: Curves.easeIn),
                child: SizedBox(
                  width: cardWidth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.11),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.11),
                              blurRadius: 18,
                              spreadRadius: 4,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top bar: title + logout
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Select currencies',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Logout',
                                    onPressed: () {
                                      context
                                          .read<AuthBloc>()
                                          .add(const LogoutRequested());
                                      context.go(RoutePaths.login);
                                    },
                                    icon: const Icon(Icons.logout,
                                        color: Colors.white70),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                          
                              // From dropdown
                              _currencyDropdown(
                                label: 'From',
                                currentValue: _fromCode ??
                                    context.select((ConverterBloc b) =>
                                        b.state.fromCurrency),
                                onChanged: (val) {
                                  setState(() => _fromCode = val);
                                  if (val != null) {
                                    context
                                        .read<ConverterBloc>()
                                        .add(FromCurrencySelected(val));
                                  }
                                },
                                entrance: fromAnim,
                              ),
                          
                              // swap button centered with animated rotation
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: AnimatedBuilder(
                                  animation: _swapController,
                                  builder: (context, child) {
                                    final angle = _swapController.value * 3.1416;
                                    return Transform.rotate(
                                      angle: angle,
                                      child: child,
                                    );
                                  },
                                  child: FloatingActionButton.small(
                                    onPressed: () {
                                      // rotate quickly and notify bloc
                                      _swapController
                                          .forward(from: 0)
                                          .then((_) => _swapController.reverse());
                                      context
                                          .read<ConverterBloc>()
                                          .add(const SwapCurrencies());
                                      // Also swap local values for immediate UI feedback
                                      final tmp = _fromCode;
                                      setState(() {
                                        _fromCode = _toCode;
                                        _toCode = tmp;
                                      });
                                    },
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.indigo[900],
                                    child: const Icon(Icons.swap_horiz),
                                  ),
                                ),
                              ),
                          
                              // To dropdown
                              _currencyDropdown(
                                label: 'To',
                                currentValue: _toCode ??
                                    context.select(
                                        (ConverterBloc b) => b.state.toCurrency),
                                onChanged: (val) {
                                  setState(() => _toCode = val);
                                  if (val != null) {
                                    context
                                        .read<ConverterBloc>()
                                        .add(ToCurrencySelected(val));
                                  }
                                },
                                entrance: toAnim,
                              ),
                          
                              const SizedBox(height: 22),
                          
                              // Next button with hero and elevation
                              Row(
                                children: [
                                  Expanded(
                                    child: Hero(
                                      tag: 'next_button',
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          backgroundColor:
                                              Colors.white,
                                          elevation: 1,
                                          shadowColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          // ensure bloc and UI values are synced
                                          final from = _fromCode ??
                                              context
                                                  .read<ConverterBloc>()
                                                  .state
                                                  .fromCurrency;
                                          final to = _toCode ??
                                              context
                                                  .read<ConverterBloc>()
                                                  .state
                                                  .toCurrency;
                                          if (from != null) {
                                            context
                                                .read<ConverterBloc>()
                                                .add(FromCurrencySelected(from));
                                          }
                                          if (to != null) {
                                            context
                                                .read<ConverterBloc>()
                                                .add(ToCurrencySelected(to));
                                          }
                                          context.push(RoutePaths.amount);
                                        },
                                        child: const Text(
                                          'Next',
                                          style: TextStyle(
                                            color: Colors.indigo,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
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
