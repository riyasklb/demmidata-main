import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../bloc/converter_bloc.dart';
import '../bloc/converter_event.dart';
import '../bloc/converter_state.dart';
import '../models/currency_model.dart';
import '../../../routes/route_paths.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_event.dart';

class CurrencySelectorScreen extends StatelessWidget {
  const CurrencySelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CurrencySelectorContent();
  }
}

class _CurrencySelectorContent extends StatefulWidget {
  const _CurrencySelectorContent();

  @override
  State<_CurrencySelectorContent> createState() => _CurrencySelectorContentState();
}

class _CurrencySelectorContentState extends State<_CurrencySelectorContent>
    with TickerProviderStateMixin {
  late final AnimationController _swapController;
  late final AnimationController _contentController;

  @override
  void initState() {
    super.initState();
    _swapController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _swapController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal[400]!, Colors.indigo[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Decorative circles
          _buildDecorativeCircles(),
          // Main content
          SafeArea(
            child: BlocBuilder<ConverterBloc, ConverterState>(
              builder: (context, state) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _contentController, 
                    curve: const Interval(0.08, 1.00)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGlassmorphismCard(context, state),
                        const SizedBox(height: 21),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          left: -40,
          top: 60,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.11),
            ),
          ),
        ),
        Positioned(
          right: -50,
          bottom: 2,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellowAccent.withOpacity(0.13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphismCard(BuildContext context, ConverterState state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
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
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogoutButton(context),
              _buildCurrencySection(
                context, 
                'From', 
                state.fromCurrency, 
                (code) => context.read<ConverterBloc>().add(FromCurrencySelected(code)),
                const Interval(0.2, 0.46)
              ),
              _buildSwapButton(context),
              _buildCurrencySection(
                context, 
                'To', 
                state.toCurrency, 
                (code) => context.read<ConverterBloc>().add(ToCurrencySelected(code)),
                const Interval(0.55, 0.86)
              ),
              const SizedBox(height: 34),
              _buildNextButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        tooltip: 'Logout',
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: () {
          context.read<AuthBloc>().add(const LogoutRequested());
          context.go(RoutePaths.login);
        },
      ),
    );
  }

  Widget _buildCurrencySection(
    BuildContext context, 
    String title, 
    String selectedCurrency, 
    void Function(String) onCurrencySelected,
    Interval animationInterval
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white
          )
        ),
        const SizedBox(height: 8),
        AnimatedCurrencyChips(
          selected: selectedCurrency,
          onSelected: onCurrencySelected,
          animation: CurvedAnimation(
            parent: _contentController,
            curve: animationInterval
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSwapButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _swapController,
          builder: (_, __) => IconButton(
            onPressed: () {
              _swapController.forward(from: 0);
              context.read<ConverterBloc>().add(const SwapCurrencies());
            },
            icon: Transform.rotate(
              angle: _swapController.value * 3.1416, // 180°
              child: const Icon(
                Icons.swap_horiz,
                size: 32, 
                color: Colors.white
              ),
            ),
            tooltip: 'Swap currencies',
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Center(
      child: Hero(
        tag: 'next_button',
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 68),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22)
            ),
            backgroundColor: Colors.tealAccent.shade100,
            elevation: 12,
            shadowColor: Colors.tealAccent,
          ),
          onPressed: () => context.push(RoutePaths.amount),
          child: const Text(
            'Next',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Colors.indigo
            )
          ),
        ),
      ),
    );
  }
}

class AnimatedCurrencyChips extends StatelessWidget {
  final String selected;
  final void Function(String code) onSelected;
  final Animation<double> animation;

  const AnimatedCurrencyChips({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        for (final currency in supportedCurrencies)
          _buildCurrencyChip(context, currency),
      ],
    );
  }

  Widget _buildCurrencyChip(BuildContext context, Currency currency) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final index = supportedCurrencies.indexOf(currency);
        final start = index * 0.07;
        final end = start + 0.34;
        final visibleAnim = CurvedAnimation(
          parent: animation,
          curve: Interval(start, end, curve: Curves.easeOut)
        );
        final isSelected = selected == currency.code;
        
        return FadeTransition(
          opacity: visibleAnim,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.9, 
              end: isSelected ? 1.09 : 1.0
            ).animate(visibleAnim),
            child: ChoiceChip(
              label: Text(
                currency.code,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.indigo[900] : Colors.blueGrey,
                  fontSize: isSelected ? 16 : 15,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(currency.code),
              selectedColor: Colors.tealAccent.shade100,
              backgroundColor: Colors.white.withOpacity(0.18),
              shape: const StadiumBorder(
                side: BorderSide(color: Colors.white30)
              ),
              elevation: isSelected ? 6 : 1,
              shadowColor: Colors.tealAccent,
            ),
          ),
        );
      },
    );
  }
}
