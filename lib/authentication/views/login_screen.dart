import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../routes/route_paths.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRegister = false;
  bool _obscure = true;

  late AnimationController _bgController;
  late AnimationController _formController;
  late Animation<double> _logoAnim;
  late Animation<double> _headerAnim;
  late Animation<double> _fieldsAnim;
  late Animation<double> _buttonAnim;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _formController = AnimationController(
      duration: Duration(milliseconds: 1400),
      vsync: this,
    )..forward();

    _logoAnim = CurvedAnimation(parent: _formController, curve: Interval(0.0, 0.3, curve: Curves.easeOut));
    _headerAnim = CurvedAnimation(parent: _formController, curve: Interval(0.25, 0.5, curve: Curves.easeOut));
    _fieldsAnim = CurvedAnimation(parent: _formController, curve: Interval(0.4, 0.7, curve: Curves.easeOut));
    _buttonAnim = CurvedAnimation(parent: _formController, curve: Interval(0.65, 1.0, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bgController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(color: Colors.blueGrey
              // gradient: LinearGradient(
              //   // colors: [
              //   //   Color.lerp(Colors.blueAccent, Colors.purpleAccent, _bgController.value)!,
              //   //   Color.lerp(Colors.cyan, Colors.deepPurple, _bgController.value)!,
              //   // ],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                context.go(RoutePaths.selector);
              }
              if (state is Unauthenticated && state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    ScaleTransition(
                      scale: _logoAnim,
                      child: Icon(Icons.flight_takeoff, size: 60, color: Colors.white.withOpacity(0.8)),
                    ),
                    FadeTransition(
                      opacity: _headerAnim,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 350),
                        child: Text(
                          _isRegister ? 'Create Account' : 'Welcome Back',
                          key: ValueKey(_isRegister),
                          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizeTransition(
                      sizeFactor: _fieldsAnim,
                      axis: Axis.vertical,
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.13),
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: Icon(Icons.mail_outline, color: Colors.white70),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.13),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _buttonAnim,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          elevation: 8,
                        ),
                        child: isLoading
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple))
                            : Text(_isRegister ? 'Register' : 'Login', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    FadeTransition(
                      opacity: _buttonAnim,
                      child: TextButton(
                        onPressed: isLoading ? null : () => setState(() => _isRegister = !_isRegister),
                        child: Text(
                          _isRegister ? 'Have an account? Login' : 'New here? Create an account',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid email and 6+ char password')));
      return;
    }
    final bloc = context.read<AuthBloc>();
    if (_isRegister) {
      bloc.add(RegisterRequested(email: email, password: password));
    } else {
      bloc.add(LoginRequested(email: email, password: password));
    }
  }
}
