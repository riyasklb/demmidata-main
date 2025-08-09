import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart'; // add to pubspec
import '../bloc/converter_bloc.dart';
import '../bloc/converter_state.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/route_paths.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Animated background gradient
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade600, Colors.tealAccent.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Abstract shape for depth
          Positioned(
            top: 36, right: -24,
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orangeAccent.withOpacity(0.13),
              ),
            ),
          ),
          SafeArea(child: _ResultBody()),
        ],
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConverterBloc, ConverterState>(
      buildWhen: (p, c) => p.status != c.status || p.convertedValue != c.convertedValue,
      builder: (context, state) {
        if (state.status == ConverterStatus.loading) {
          return Center(child:CircularProgressIndicator()); // Replace with your asset
        }
        if (state.status == ConverterStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              //  Lottie.asset('assets/error.json', height: 90), // Optional error animation
                SizedBox(height: 12),
                Text(state.errorMessage ?? 'Error', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }
        if (state.status != ConverterStatus.success) {
          return Center(child: Text('No result yet'));
        }

        final value = state.convertedValue ?? 0;
        final rate = state.rate ?? 0;
        final time = state.fetchedAt != null ? TimeOfDay.fromDateTime(state.fetchedAt!) : null;

        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: 380,
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: Colors.indigoAccent.withOpacity(0.19), blurRadius: 16, offset: Offset(0, 6)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (state.isStale)
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange.shade900),
                            SizedBox(width: 7),
                            Text('This rate is older than 5 minutes.',
                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.orange.shade900),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 18),
                    // Animated success icon
               //     Lottie.asset('assets/success.json', height: 59), // Use your own asset or icon
                    SizedBox(height: 14),
                    Text('Converted Amount', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                    SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: value),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutBack,
                      builder: (context, val, child) {
                        return Transform.scale(
                          scale: 1 + (val == value ? 0.09 : 0.0),
                          child: Text(
                            '${val.toStringAsFixed(2)} ${state.toCurrency}',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo[900],
                              shadows: [Shadow(color: Colors.tealAccent, blurRadius: 14)],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 18),
                    AnimatedRow(
                      state: state,
                      time: time,
                      rate: rate,
                    ),
                    SizedBox(height: 34),
                    Hero(
                      tag: 'result_next_button',
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.tealAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                          elevation: 8,
                        ),
                        onPressed: () => context.go(RoutePaths.selector),
                        child: Text('Start Over', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Animates the chips for rate info
class AnimatedRow extends StatelessWidget {
  final ConverterState state;
  final TimeOfDay? time;
  final double rate;
  const AnimatedRow({required this.state, required this.time, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        AnimatedChip(label: 'Rate: ${rate.toStringAsFixed(5)}'),
        SizedBox(width: 9),
        if (time != null)
          AnimatedChip(label: 'At: ${time!.format(context)}'),
        SizedBox(width: 9),
        if (state.isCached) AnimatedChip(label: 'Cached'),
      ],
    );
  }
}

class AnimatedChip extends StatelessWidget {
  final String label;
  const AnimatedChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0), duration: Duration(milliseconds: 400),
      builder: (context, scale, _) => Transform.scale(
        scale: scale,
        child: Chip(
          label: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.white.withOpacity(0.17),
          labelStyle: TextStyle(color: Colors.indigo),
          shape: StadiumBorder(),
        ),
      ),
    );
  }
}
