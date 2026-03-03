import 'package:equatable/equatable.dart';

/// Immutable auth state — used by [AuthNotifier].
class AuthState extends Equatable {
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = true, // true on app boot while checking token
    this.email,
    this.userId,
    this.username,
    this.profilePhoto,
    this.errorMessage,
    this.needsEmailVerification = false,
    this.pendingVerificationEmail,
    this.pendingVerificationPassword,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final String? email;
  final int? userId;
  final String? username;

  /// Asset path of the chosen profile photo.
  final String? profilePhoto;
  final String? errorMessage;

  /// True after manual signup — user must verify their email before logging in.
  final bool needsEmailVerification;

  /// The email address that is awaiting verification (so screens can display it).
  final String? pendingVerificationEmail;

  /// The password stored temporarily so the verify screen can auto-login
  /// once the user confirms their email has been verified.
  final String? pendingVerificationPassword;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? email,
    int? userId,
    String? username,
    String? profilePhoto,
    String? errorMessage,
    bool clearError = false,
    bool clearEmail = false,
    bool clearUsername = false,
    bool? needsEmailVerification,
    String? pendingVerificationEmail,
    String? pendingVerificationPassword,
    bool clearPendingVerification = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      email: clearEmail ? null : (email ?? this.email),
      userId: userId ?? this.userId,
      username: clearUsername ? null : (username ?? this.username),
      profilePhoto: profilePhoto ?? this.profilePhoto,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      needsEmailVerification:
          needsEmailVerification ?? this.needsEmailVerification,
      pendingVerificationEmail: clearPendingVerification
          ? null
          : (pendingVerificationEmail ?? this.pendingVerificationEmail),
      pendingVerificationPassword: clearPendingVerification
          ? null
          : (pendingVerificationPassword ?? this.pendingVerificationPassword),
    );
  }

  @override
  List<Object?> get props => [
    isAuthenticated,
    isLoading,
    email,
    userId,
    username,
    profilePhoto,
    errorMessage,
    needsEmailVerification,
    pendingVerificationEmail,
    pendingVerificationPassword,
  ];
}
