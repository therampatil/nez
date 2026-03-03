import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Live Railway backend URL — works on all platforms (emulator, device, web).
const String _baseUrl = 'https://nez-backend-production.up.railway.app';

/// Riverpod provider — single Dio-based API client for the entire app.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Central HTTP client.
///
/// • Reads the stored JWT on every request and attaches `Authorization: Bearer`.
/// • If the backend returns 401, the error interceptor invokes [onUnauthorized]
///   so the auth layer can clear state and redirect to the login screen.
class ApiClient {
  ApiClient({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  final Dio _dio;
  final FlutterSecureStorage _storage;

  Dio get client => _dio;

  static const _tokenKey = 'nez_access_token';

  /// Callback invoked when any request receives a 401 Unauthorized response.
  /// Set this from the auth layer to trigger auto-logout + redirect.
  void Function()? onUnauthorized;

  /// Attach Bearer token to every outgoing request (if one exists).
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Skip auto-logout for login/signup endpoints — those 401s are
          // "wrong password" errors, not expired-session errors.
          final path = error.requestOptions.path;
          final isAuthEndpoint =
              path.startsWith('/auth/login') || path.startsWith('/auth/signup');
          if (!isAuthEndpoint) {
            onUnauthorized?.call();
          }
        }
        handler.next(error);
      },
    );
  }
}
