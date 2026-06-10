import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/token_storage.dart';
import '../../data/repositories/auth_repository.dart';

// 인증 상태
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  AuthState({required this.status, this.errorMessage});

  AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthViewModel(this._repository)
      : super(AuthState(status: AuthStatus.initial));

  Future<void> checkAuthStatus() async {
    final hasToken = await TokenStorage.hasToken();
    state = AuthState(
      status: hasToken ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
  }

  Future<bool> login(String email, String password) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      await _repository.login(email, password);
      state = AuthState(status: AuthStatus.authenticated);
      return true;
    } on DioException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: DioClient.extractError(e),
      );
      return false;
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      await _repository.signup(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      state = AuthState(status: AuthStatus.unauthenticated);
      return true;
    } on DioException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: DioClient.extractError(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

// Providers
final authRepositoryProvider = Provider((ref) => AuthRepository());

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authRepositoryProvider));
});
