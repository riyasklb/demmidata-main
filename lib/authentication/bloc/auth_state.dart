import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final String userId;
  const Authenticated({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class Unauthenticated extends AuthState {
  final String? errorMessage;
  final bool isRegister;
  final bool isPasswordVisible;
  
  const Unauthenticated({
    this.errorMessage,
    this.isRegister = false,
    this.isPasswordVisible = false,
  });

  Unauthenticated copyWith({
    String? errorMessage,
    bool? isRegister,
    bool? isPasswordVisible,
  }) {
    return Unauthenticated(
      errorMessage: errorMessage ?? this.errorMessage,
      isRegister: isRegister ?? this.isRegister,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }

  @override
  List<Object?> get props => [errorMessage, isRegister, isPasswordVisible];
}


