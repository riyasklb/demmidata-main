import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../../services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  StreamSubscription<String?>? _authSub;

  AuthBloc({required this.authService}) : super(const Unauthenticated()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ToggleAuthMode>(_onToggleAuthMode);
    on<ClearError>(_onClearError);
    on<_InternalAuthenticated>(_onInternalAuthenticated);
    on<_InternalUnauthenticated>(_onInternalUnauthenticated);

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

  void _onTogglePasswordVisibility(TogglePasswordVisibility event, Emitter<AuthState> emit) {
    if (state is Unauthenticated) {
      final currentState = state as Unauthenticated;
      emit(currentState.copyWith(isPasswordVisible: !currentState.isPasswordVisible));
    }
  }

  void _onToggleAuthMode(ToggleAuthMode event, Emitter<AuthState> emit) {
    if (state is Unauthenticated) {
      final currentState = state as Unauthenticated;
      emit(currentState.copyWith(isRegister: !currentState.isRegister));
    }
  }

  void _onClearError(ClearError event, Emitter<AuthState> emit) {
    if (state is Unauthenticated) {
      final currentState = state as Unauthenticated;
      emit(currentState.copyWith(errorMessage: null));
    }
  }

  Future<void> _onInternalAuthenticated(_InternalAuthenticated event, Emitter<AuthState> emit) async {
    final userId = authService.currentUserId;
    if (userId != null) {
      emit(Authenticated(userId: userId));
    }
  }

  Future<void> _onInternalUnauthenticated(_InternalUnauthenticated event, Emitter<AuthState> emit) async {
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


