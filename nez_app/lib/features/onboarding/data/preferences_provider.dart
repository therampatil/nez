import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/api_client.dart';
import 'preferences_service.dart';

/// Riverpod provider for [PreferencesService].
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PreferencesService(dio: apiClient.client);
});

/// State: the user's saved categories (loaded from the backend).
class PreferencesNotifier extends StateNotifier<AsyncValue<List<String>>> {
  PreferencesNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final PreferencesService _service;

  /// Load preferences from the backend.
  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final cats = await _service.fetchPreferences();
      state = AsyncValue.data(cats);
    } catch (e, st) {
      debugPrint('[PreferencesNotifier] load error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Save new preferences to the backend and update local state.
  Future<void> save(List<String> categories) async {
    try {
      await _service.savePreferences(categories);
      state = AsyncValue.data(categories);
    } catch (e, st) {
      debugPrint('[PreferencesNotifier] save error: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

/// Global provider for the user's saved category preferences.
final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, AsyncValue<List<String>>>((ref) {
      final service = ref.read(preferencesServiceProvider);
      return PreferencesNotifier(service);
    });
