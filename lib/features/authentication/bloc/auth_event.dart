import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  const RegisterRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// UI State Management Events
class TogglePasswordVisibility extends AuthEvent {
  const TogglePasswordVisibility();
}

class ToggleAuthMode extends AuthEvent {
  const ToggleAuthMode();
}

class ClearError extends AuthEvent {
  const ClearError();
}


