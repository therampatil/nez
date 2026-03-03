import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';
import '../data/auth_state.dart';
import '../../../shared/services/api_client.dart';

/// Global Riverpod provider for authentication state.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final notifier = AuthNotifier(
    authService: AuthService(dio: apiClient.client),
  );
  // Wire global 401 handling: any non-auth 401 triggers auto-logout.
  apiClient.onUnauthorized = () => notifier.onSessionExpired();
  return notifier;
});

/// Tracks whether the user just signed up and needs to set preferences.
final needsPreferencesProvider = StateProvider<bool>((ref) => false);

/// Manages authentication lifecycle: boot check, signup, login, logout.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required AuthService authService})
    : _authService = authService,
      super(const AuthState()) {
    _tryRestoreSession();
  }

  final AuthService _authService;

  // ── Boot: attempt silent login from stored token ───────────

  Future<void> _tryRestoreSession() async {
    final token = await _authService.getStoredToken();
    if (token == null) {
      state = state.copyWith(isLoading: false);
      return;
    }
    try {
      final user = await _authService.fetchCurrentUser();
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        email: user['email'] as String?,
        userId: user['id'] as int?,
        username: user['username'] as String?,
        clearError: true,
      );
    } on DioException {
      // Token expired or invalid — clear it silently.
      await _authService.clearToken();
      state = state.copyWith(isLoading: false);
    }
  }

  // ── Signup ─────────────────────────────────────────────────

  Future<void> signup({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authService.signup(
        email: email,
        password: password,
      );

      if (result.needsEmailVerification) {
        // Standard path: user must verify email before logging in.
        // Store the password temporarily so we can auto-login after verification.
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          needsEmailVerification: true,
          pendingVerificationEmail: result.email,
          pendingVerificationPassword: password,
          clearError: true,
        );
        return;
      }

      // Legacy / future path: backend returned token immediately.
      final user = await _authService.fetchCurrentUser();
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        email: user['email'] as String?,
        userId: user['id'] as int?,
        username: user['username'] as String?,
        clearError: true,
      );
    } on DioException catch (e) {
      debugPrint('[AuthNotifier] signup DioException: ${e.type} ${e.message}');
      state = state.copyWith(isLoading: false, errorMessage: _extractError(e));
    } catch (e) {
      debugPrint('[AuthNotifier] signup unexpected error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  // ── Resend verification email ───────────────────────────────

  Future<String?> resendVerification(String email) async {
    try {
      await _authService.resendVerification(email: email);
      return null; // success
    } on DioException catch (e) {
      return _extractError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Clear the pending-verification state (e.g. user wants to go back to signup).
  void clearPendingVerification() {
    state = state.copyWith(
      needsEmailVerification: false,
      clearPendingVerification: true,
      clearError: true,
    );
  }

  /// Called from the verify-email screen after the user confirms they clicked
  /// the link. Attempts to log in with the stored credentials.
  /// Returns null on success, or an error message string on failure.
  Future<String?> loginAfterVerification() async {
    final email = state.pendingVerificationEmail;
    final password = state.pendingVerificationPassword;

    if (email == null || password == null) {
      return 'Session expired. Please log in manually.';
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.login(email: email, password: password);
      final user = await _authService.fetchCurrentUser();
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        needsEmailVerification: false,
        email: user['email'] as String?,
        userId: user['id'] as int?,
        username: user['username'] as String?,
        clearPendingVerification: true,
        clearError: true,
      );
      return null; // success
    } on DioException catch (e) {
      final msg = _extractError(e);
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return msg;
    } catch (e) {
      final msg = 'Unexpected error: $e';
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return msg;
    }
  }

  // ── Login ──────────────────────────────────────────────────

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.login(email: email, password: password);
      final user = await _authService.fetchCurrentUser();
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        email: user['email'] as String?,
        userId: user['id'] as int?,
        username: user['username'] as String?,
        clearError: true,
      );
    } on DioException catch (e) {
      debugPrint('[AuthNotifier] login DioException: ${e.type} ${e.message}');
      state = state.copyWith(isLoading: false, errorMessage: _extractError(e));
    } catch (e) {
      debugPrint('[AuthNotifier] login unexpected error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  // ── Google Sign-In ─────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final token = await _authService.signInWithGoogle();
      if (token == null) {
        // User cancelled the picker — reset loading silently
        state = state.copyWith(isLoading: false);
        return;
      }
      final user = await _authService.fetchCurrentUser();
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        email: user['email'] as String?,
        userId: user['id'] as int?,
        username: user['username'] as String?,
        clearError: true,
      );
    } on DioException catch (e) {
      debugPrint(
        '[AuthNotifier] Google sign-in DioException: ${e.type} ${e.message}',
      );
      state = state.copyWith(isLoading: false, errorMessage: _extractError(e));
    } catch (e) {
      debugPrint('[AuthNotifier] Google sign-in error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ── Update username ────────────────────────────────────────

  /// PATCH /users/me — saves a new display name to the backend.
  Future<String?> updateUsername(Dio dio, String newName) async {
    try {
      final response = await dio.patch(
        '/users/me',
        data: {'username': newName.trim()},
      );
      final updated = response.data['username'] as String?;
      state = state.copyWith(username: updated);
      return null; // no error
    } on DioException catch (e) {
      return _extractError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── Change password ────────────────────────────────────────

  /// POST /auth/change-password
  Future<String?> changePassword(
    Dio dio,
    String current,
    String newPass,
  ) async {
    try {
      await dio.post(
        '/auth/change-password',
        data: {'current_password': current, 'new_password': newPass},
      );
      return null; // success
    } on DioException catch (e) {
      return _extractError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── Change email ───────────────────────────────────────────

  /// POST /auth/change-email — requires current password to verify identity.
  Future<String?> changeEmail(Dio dio, String newEmail, String password) async {
    try {
      final response = await dio.post(
        '/auth/change-email',
        data: {'new_email': newEmail.trim(), 'password': password},
      );
      final updatedEmail = response.data['email'] as String?;
      if (updatedEmail != null) {
        state = state.copyWith(email: updatedEmail);
      }
      return null; // success
    } on DioException catch (e) {
      return _extractError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── Delete account ─────────────────────────────────────────

  /// DELETE /users/me — permanently deletes the account.
  Future<String?> deleteAccount(Dio dio) async {
    try {
      await dio.delete('/users/me');
      await _authService.clearToken();
      state = const AuthState(isLoading: false);
      return null; // success
    } on DioException catch (e) {
      return _extractError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── Profile photo (local) ──────────────────────────────────

  void updateProfilePhoto(String assetPath) {
    state = state.copyWith(profilePhoto: assetPath);
  }

  // ── Logout ─────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(isLoading: false);
  }

  // ── Handle 401 from interceptor ────────────────────────────

  /// Called by the Dio interceptor when a 401 is received.
  Future<void> onSessionExpired() async {
    await _authService.clearToken();
    state = const AuthState(
      isLoading: false,
      errorMessage: 'Session expired. Please log in again.',
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  void clearError() => state = state.copyWith(clearError: true);

  String _extractError(DioException e) {
    // Connection / timeout errors — no response from server.
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Unable to reach the server. Check your connection.';
    }
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) {
      return data['detail'] as String;
    }
    return 'Something went wrong. Please try again.';
  }
}
