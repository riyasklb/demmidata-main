import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/converter_bloc.dart';
import '../bloc/converter_state.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/route_paths.dart';



class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade500,
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
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (state.status == ConverterStatus.error) {
          return Center(
            child: Text(
              state.errorMessage ?? 'Error',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          );
        }
        if (state.status != ConverterStatus.success) {
          return Center(child: Text('No result yet', style: TextStyle(color: Colors.white70, fontSize: 18)));
        }

        final value = state.convertedValue ?? 0;
        final rate = state.rate ?? 0;
        final time = state.fetchedAt != null ? TimeOfDay.fromDateTime(state.fetchedAt!) : null;

        return Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 340,
                  padding: EdgeInsets.symmetric(vertical: 36, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.shade900.withOpacity(0.13),
                        blurRadius: 26,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Converted Amount',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: value),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, child) {
                          return Text(
                            '${val.toStringAsFixed(2)} ${state.toCurrency}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.indigo.shade700, blurRadius: 24)],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 24),

                      // Show both currencies & flags
               Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'From',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        Text(
          state.fromCurrency,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white,
        size: 20,
      ),
    ),
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'To',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        Text(
          state.toCurrency,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ],
),


                      SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _InfoTile(
                            icon: Icons.trending_up,
                            label: 'Rate',
                            value: rate.toStringAsFixed(5),
                            bg: Colors.deepPurple.shade200,
                          ),
                          SizedBox(width: 12),
                          if (time != null)
                            _InfoTile(
                              icon: Icons.access_time,
                              label: 'Time',
                              value: time.format(context),
                              bg: Colors.indigo.shade200,
                            ),
                        ],
                      ),
                      if (state.isCached || state.isStale)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 7, horizontal: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.warning_amber, color: Colors.amber, size: 20),
                                SizedBox(width: 7),
                                Text(
                                  state.isStale
                                      ? 'Rate is older than 5 minutes'
                                      : 'Cached rate',
                                  style: TextStyle(
                                      color: Colors.amber.shade900,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 340,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple.shade600,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 9,
                      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    onPressed: () => context.go(RoutePaths.selector),
                    child: Text('Start Over'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Currency and flag tile widget
class _FlagCurrencyTile extends StatelessWidget {
  final String flag;
  final String code;
  final String label;
  const _FlagCurrencyTile({
    required this.flag,
    required this.code,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (flag.isNotEmpty)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              image: DecorationImage(
                image: AssetImage(flag),
                fit: BoxFit.cover,
              ),
            ),
          ),
        SizedBox(height: 7),
        Text(
          '$code',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            letterSpacing: 0.5,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

// Tile for rate/time
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color bg;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.white),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: Colors.white70)),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }
}
