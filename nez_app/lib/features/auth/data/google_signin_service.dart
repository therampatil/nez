import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

// Web OAuth 2.0 client ID — from Firebase Console → Authentication → Sign-in method → Google → Web SDK configuration
const _webClientId =
    '105308862911-9frla7nrl8cptnveb6vol8pckopgh2ju.apps.googleusercontent.com';

/// Service for Google Sign-In authentication
class GoogleSignInService {
  GoogleSignInService()
    : _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // serverClientId is required on Android to receive an ID token
        serverClientId: _webClientId,
      );

  final GoogleSignIn _googleSignIn;

  /// Sign in with Google and return the ID token.
  /// Returns null only if the user explicitly cancelled.
  /// Throws on actual errors so the caller can surface a message.
  Future<GoogleSignInResult?> signInWithGoogle() async {
    try {
      // Sign out first to always show the account picker
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // User dismissed the picker — not an error
        debugPrint('[GoogleSignInService] User cancelled sign-in');
        return null;
      }

      debugPrint('[GoogleSignInService] Signed in as ${account.email}');

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      final String? accessToken = auth.accessToken;

      debugPrint('[GoogleSignInService] idToken present: ${idToken != null}');
      debugPrint(
        '[GoogleSignInService] accessToken present: ${accessToken != null}',
      );

      if (idToken == null) {
        throw Exception(
          'Google returned no ID token. '
          'Ensure the SHA-1 fingerprint is registered in Firebase Console '
          'and Google Sign-In is enabled under Authentication → Sign-in method.',
        );
      }

      return GoogleSignInResult(
        idToken: idToken,
        accessToken: accessToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on Exception {
      rethrow; // let AuthService/AuthNotifier handle and show the message
    } catch (e) {
      debugPrint('[GoogleSignInService] Sign-in error: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('[GoogleSignInService] Sign-out error: $e');
    }
  }

  /// Check if user is currently signed in to Google
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      debugPrint('[GoogleSignInService] isSignedIn error: $e');
      return false;
    }
  }
}

/// Result from Google Sign-In
class GoogleSignInResult {
  const GoogleSignInResult({
    required this.idToken,
    required this.accessToken,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String idToken;
  final String? accessToken;
  final String email;
  final String? displayName;
  final String? photoUrl;
}
