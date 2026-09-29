import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService._internal();

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    try {
      await _notifications.initialize(initializationSettings);
      _initialized = true;
    } catch (_) {}
  }

  Future<void> showCaptureNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'snapnote_capture',
        'Capture Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
      );
    } catch (_) {}
  }

  Future<void> showReminderNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'snapnote_reminders',
        'Reminder Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    try {
      await _notifications.show(
        id,
        '⏰ Reminder: $title',
        body,
        notificationDetails,
      );
    } catch (_) {}
  }
}
