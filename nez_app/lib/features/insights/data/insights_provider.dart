import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/api_client.dart';
import 'insights_model.dart';

/// Fetches real reading stats from GET /users/me/insights.
final insightsProvider = FutureProvider.autoDispose<InsightsData>((ref) async {
  final client = ref.read(apiClientProvider).client;
  final response = await client.get('/users/me/insights');
  return InsightsData.fromJson(response.data as Map<String, dynamic>);
});
