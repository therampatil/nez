import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_model.dart';

// ──────────────────────────────────────────────
// NOTIFICATIONS PROVIDER
// ──────────────────────────────────────────────

/// Holds the list of notifications; supports marking as read and clear-all.
class NotificationsNotifier extends Notifier<List<NezNotification>> {
  @override
  List<NezNotification> build() => List.from(mockNotifications);

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  void delete(String id) {
    state = [
      for (final n in state)
        if (n.id != id) n,
    ];
  }

  void clearAll() {
    state = [];
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<NezNotification>>(
      NotificationsNotifier.new,
    );

/// Count of unread notifications.
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});
