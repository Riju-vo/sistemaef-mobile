import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/storage/in_memory_token.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

enum AuthStatus { bootstrapping, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  const AuthState({required this.status, this.user, this.error});

  const AuthState.bootstrapping() : this(status: AuthStatus.bootstrapping);
  const AuthState.unauthenticated([String? error])
      : this(status: AuthStatus.unauthenticated, error: error);
  const AuthState.authenticated(AuthUser user)
      : this(status: AuthStatus.authenticated, user: user);
}

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorage(const FlutterSecureStorage());
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthController(this._ref) : super(const AuthState.bootstrapping()) {
    bootstrap();
  }

  AuthRepository get _repo => _ref.read(authRepositoryProvider);
  SecureTokenStorage get _storage => _ref.read(secureTokenStorageProvider);

  Future<void> bootstrap() async {
    final refreshToken = await _storage.readRefreshToken();
    if (!mounted) return;

    if (refreshToken == null || refreshToken.isEmpty) {
      state = const AuthState.unauthenticated();
      return;
    }

    final result = await _repo.refresh(refreshToken);
    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      final session = result.data!;
      _ref.read(inMemoryAccessTokenProvider.notifier).state = session.accessToken;
      await _storage.saveRefreshToken(session.refreshToken);
      if (!mounted) return;
      state = AuthState.authenticated(session.user);
      return;
    }

    await clearSession();
  }

  Future<void> login(String email, String password) async {
    final result = await _repo.login(email, password);
    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      final session = result.data!;
      _ref.read(inMemoryAccessTokenProvider.notifier).state = session.accessToken;
      await _storage.saveRefreshToken(session.refreshToken);
      if (!mounted) return;
      state = AuthState.authenticated(session.user);
      return;
    }

    state = const AuthState.unauthenticated('Credenciales invalidas');
  }

  Future<bool> refresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (!mounted) return false;

    if (refreshToken == null || refreshToken.isEmpty) {
      await clearSession();
      return false;
    }

    final result = await _repo.refresh(refreshToken);
    if (!mounted) return false;

    if (result.isSuccess && result.data != null) {
      final session = result.data!;
      _ref.read(inMemoryAccessTokenProvider.notifier).state = session.accessToken;
      await _storage.saveRefreshToken(session.refreshToken);
      if (!mounted) return false;
      state = AuthState.authenticated(session.user);
      return true;
    }

    await clearSession();
    return false;
  }

  Future<void> logout() async {
    await _repo.logout();
    await clearSession();
  }

  Future<void> clearSession() async {
    _ref.read(inMemoryAccessTokenProvider.notifier).state = null;
    await _storage.clear();
    if (!mounted) return;
    state = const AuthState.unauthenticated();
  }
}
