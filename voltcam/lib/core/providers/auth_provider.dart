import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';

/// State representation for Authentication.
class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier managing user authentication state.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void setUser(UserModel user) {
    state = AuthState(
      user: user,
      isAuthenticated: true,
      isLoading: false,
      error: null,
    );
  }

  void login(String email, String displayName, {String? role, String? preferredZoneId}) {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulate auth login state update
    final user = UserModel(
      uid: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      role: role ?? 'user',
      preferredZoneId: preferredZoneId,
      createdAt: DateTime.now(),
    );

    state = AuthState(
      user: user,
      isAuthenticated: true,
      isLoading: false,
      error: null,
    );
  }

  void logout() {
    state = const AuthState(
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
    );
  }

  void setError(String errorMessage) {
    state = state.copyWith(error: errorMessage, isLoading: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Riverpod provider for Authentication state management.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
