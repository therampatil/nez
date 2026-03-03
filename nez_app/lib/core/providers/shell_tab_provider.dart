import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks which bottom-nav tab the MainShell should show.
/// Any screen (e.g. ImpactScreen) can write to this to trigger a tab switch
/// after popping back to the shell.
final shellTabProvider = StateProvider<int>((ref) => 0);
