import  'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/logger_setup.dart';

// ─── State ───────────────────────────────────────────────────────────────────
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// ─── ViewModel ───────────────────────────────────────────────────────────────
class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final AuthRepository _authRepository;

  AuthViewModel(this._loginUseCase, this._authRepository)
      : super(const AuthState());

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _loginUseCase(email: email, password: password);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
      appLogger.i('[Auth] Login successful');
      return true;
    } catch (e) {
      final message = e.toString().replaceAll('Exception:', '').trim();
      state = state.copyWith(isLoading: false, error: message);
      appLogger.e('[Auth] Login failed: $message');
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState();
    appLogger.i('[Auth] Logged out');
  }
}
