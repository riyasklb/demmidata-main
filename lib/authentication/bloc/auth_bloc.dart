import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../../services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  StreamSubscription<String?>? _authSub;

  AuthBloc({required this.authService}) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);

    _authSub = authService.userIdStream.listen((userId) {
      if (userId != null) {
        add(const _InternalAuthenticated());
      } else {
        add(const _InternalUnauthenticated());
      }
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final userId = authService.currentUserId;
    if (userId != null) {
      emit(Authenticated(userId: userId));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await authService.signIn(email: event.email, password: event.password);
    result.when(
      success: (userId) => emit(Authenticated(userId: userId)),
      failure: (message) => emit(Unauthenticated(errorMessage: message)),
    );
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await authService.signUp(email: event.email, password: event.password);
    result.when(
      success: (userId) => emit(Authenticated(userId: userId)),
      failure: (message) => emit(Unauthenticated(errorMessage: message)),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await authService.signOut();
    emit(const Unauthenticated());
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}

// Internal events to sync with stream without exposing to UI
class _InternalAuthenticated extends AuthEvent {
  const _InternalAuthenticated();
}

class _InternalUnauthenticated extends AuthEvent {
  const _InternalUnauthenticated();
}


