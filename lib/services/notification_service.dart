import '../models/todo_model.dart';

class NotificationService {
  static bool _initialized = false;
  static bool _enabled = true;

  // Initialize notifications
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  // Check if notifications are enabled
  Future<bool> isNotificationEnabled() async {
    return _enabled;
  }

  // Set notification enabled
  Future<void> setNotificationEnabled(bool enabled) async {
    _enabled = enabled;
  }

  // Schedule notification for todo (placeholder - no actual notifications)
  Future<void> scheduleTodoNotification(TodoModel todo) async {
    // Notifications not available in minimal build
  }

  // Cancel notification
  Future<void> cancelTodoNotification(String todoId) async {}

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {}
}
