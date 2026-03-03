import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'google_signin_service.dart';

/// Result of a manual email/password signup.
class SignupResult {
  const SignupResult({
    required this.needsEmailVerification,
    required this.email,
    this.accessToken,
  });

  /// True when the backend sent a 201 with needs_verification=true.
  /// False (legacy/future) when a token is returned immediately.
  final bool needsEmailVerification;
  final String email;

  /// Non-null only when the backend immediately returns a JWT (e.g. for
  /// pre-verified users or if the verification step is disabled in future).
  final String? accessToken;
}

/// Pure data service — handles JWT auth API calls and secure token persistence.
/// No UI, no providers, no navigation.
class AuthService {
  AuthService({required Dio dio, FlutterSecureStorage? storage})
    : _dio = dio,
      _storage = storage ?? const FlutterSecureStorage(),
      _googleSignInService = GoogleSignInService();

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final GoogleSignInService _googleSignInService;

  static const _tokenKey = 'nez_access_token';

  // ── Token persistence ──────────────────────────────────────

  Future<String?> getStoredToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  // ── API calls ──────────────────────────────────────────────

  /// Register a new user. Returns a [SignupResult] describing next steps.
  ///
  /// When [SignupResult.needsEmailVerification] is true the user must verify
  /// their email before they can log in — no token is stored yet.
  Future<SignupResult> signup({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/signup',
      data: {'email': email, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    final needsVerification = data['needs_verification'] as bool? ?? false;

    if (needsVerification) {
      return SignupResult(
        needsEmailVerification: true,
        email: data['email'] as String? ?? email,
      );
    }

    // Legacy / future path: token returned immediately.
    final token = data['access_token'] as String;
    await saveToken(token);
    return SignupResult(
      needsEmailVerification: false,
      email: email,
      accessToken: token,
    );
  }

  /// Request a new verification email for [email].
  Future<void> resendVerification({required String email}) async {
    await _dio.post('/auth/resend-verification', data: {'email': email});
  }

  /// Authenticate an existing user. Returns the raw access token string.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final token = response.data['access_token'] as String;
    await saveToken(token);
    return token;
  }

  /// Fetch the current user's profile (requires a valid stored token).
  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final response = await _dio.get('/users/me');
    return response.data as Map<String, dynamic>;
  }

  /// Clear local session. Backend tokens are stateless so nothing to revoke.
  Future<void> logout() async {
    await clearToken();
    await _googleSignInService.signOut();
  }

  /// Sign in with Google and authenticate with backend.
  /// Returns null silently if the user cancelled the picker.
  Future<String?> signInWithGoogle() async {
    final result = await _googleSignInService.signInWithGoogle();
    if (result == null) return null;

    final response = await _dio.post(
      '/auth/google',
      data: {
        'id_token': result.idToken,
        'email': result.email,
        'name': result.displayName ?? result.email.split('@').first,
      },
    );

    final token = response.data['access_token'] as String;
    await saveToken(token);
    return token;
  }
}
