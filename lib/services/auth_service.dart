import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<String?> get userIdStream => _auth.authStateChanges().map((u) => u?.uid);

  Future<AuthResult> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return AuthResult.success(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(e.message ?? 'Login failed');
    } catch (_) {
      return AuthResult.failure('Login failed');
    }
  }

  Future<AuthResult> signUp({required String email, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return AuthResult.success(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(e.message ?? 'Registration failed');
    } catch (_) {
      return AuthResult.failure('Registration failed');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class AuthResult {
  final String? userId;
  final String? errorMessage;
  final bool isSuccess;

  AuthResult._(this.userId, this.errorMessage, this.isSuccess);

  factory AuthResult.success(String userId) => AuthResult._(userId, null, true);
  factory AuthResult.failure(String message) => AuthResult._(null, message, false);

  void when({required void Function(String userId) success, required void Function(String message) failure}) {
    if (isSuccess && userId != null) {
      success(userId!);
    } else {
      failure(errorMessage ?? 'Unknown error');
    }
  }
}


