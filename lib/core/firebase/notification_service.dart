/// PawTable Firebase Cloud Messaging (FCM) notification service
///
/// Handles push notification registration, permission management,
/// message handling, and topic subscription for PawTable.
///
/// Topics used:
/// - notifications/general — All users (announcements, maintenance)
/// - notifications/pets/{userId} — User-specific reminders
/// - notifications/pets/{userId}/pets/{petId} — Pet-specific alerts
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// PawTable notification service
///
/// Manages Firebase Cloud Messaging registration, permission requests,
/// and local notification scheduling for reminders and alerts.
class NotificationService {
  NotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // =========================================================================
  // INITIALIZATION
  // =========================================================================

  /// Initialize Firebase Cloud Messaging
  ///
  /// Registers for push notifications, sets up message handlers,
  /// and configures local notifications.
  Future<void> initialize() async {
    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Set up message handlers
    _setupMessageHandlers();

    // Get FCM token
    final token = await _messaging.getToken();
    debugPrint('[NotificationService] FCM token: $token');

    // Handle token refresh
    _messaging.onTokenRefresh.listen((token) {
      debugPrint('[NotificationService] FCM token refreshed: $token');
    });
  }

  // =========================================================================
  // PERMISSIONS
  // =========================================================================

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request permissions (iOS requires user permission)
    await _messaging.requestPermission(
      announcement: false,
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('[NotificationService] Notification permissions requested');
  }

  // =========================================================================
  // LOCAL NOTIFICATIONS
  // =========================================================================

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse:
          _onNotificationTappedBackground,
    );
  }

  /// Show a local notification (for reminders)
  Future<void> showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pawtable_reminders',
      'PawTable Reminders',
      channelDescription:
          'Reminders for feeding, medication, and vaccinations',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'reminder',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title ?? 'PawTable',
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule a notification at a specific date/time
  Future<void> scheduleNotification({
    required int id,
    required DateTime scheduledDate,
    String? title,
    String? body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pawtable_reminders',
      'PawTable Reminders',
      channelDescription:
          'Reminders for feeding, medication, and vaccinations',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title ?? 'PawTable',
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) {
    return _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() {
    return _localNotifications.cancelAll();
  }

  // =========================================================================
  // PUSH NOTIFICATIONS
  // =========================================================================

  /// Subscribe to a Firebase topic
  Future<void> subscribeToTopic(String topic) {
    return _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a Firebase topic
  Future<void> unsubscribeFromTopic(String topic) {
    return _messaging.unsubscribeFromTopic(topic);
  }

  /// Subscribe to all notification topics for a user
  Future<void> subscribeUserTopics(String userId) {
    return Future.wait([
      subscribeToTopic('notifications/general'),
      subscribeToTopic('notifications/pets/$userId'),
    ]);
  }

  /// Unsubscribe from all notification topics for a user
  Future<void> unsubscribeUserTopics(String userId) {
    return Future.wait([
      unsubscribeFromTopic('notifications/general'),
      unsubscribeFromTopic('notifications/pets/$userId'),
    ]);
  }

  /// Subscribe to pet-specific notification topics
  Future<void> subscribePetTopics(String userId, String petId) {
    return subscribeToTopic('notifications/pets/$userId/pets/$petId');
  }

  /// Unsubscribe from pet-specific notification topics
  Future<void> unsubscribePetTopics(String userId, String petId) {
    return unsubscribeFromTopic('notifications/pets/$userId/pets/$petId');
  }

  // =========================================================================
  // MESSAGE HANDLERS
  // =========================================================================

  /// Set up Firebase message handlers
  void _setupMessageHandlers() {
    // Background message handler (runs when app is in background)
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // User tapped notification while app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);
  }

  /// Handle background message (app is in background or terminated)
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    debugPrint(
      '[NotificationService] Background message received: '
      '${message.messageId}',
    );
    debugPrint('  Notification: ${message.notification?.title}');
    debugPrint('  Data: ${message.data}');
  }

  /// Handle foreground message (app is in foreground)
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
      '[NotificationService] Foreground message received: '
      '${message.messageId}',
    );
    debugPrint('  Notification: ${message.notification?.title}');
    debugPrint('  Body: ${message.notification?.body}');
    debugPrint('  Data: ${message.data}');

    // Show local notification for foreground messages
    if (message.notification != null) {
      showLocalNotification(
        id: message.messageId.hashCode,
        title: message.notification!.title,
        body: message.notification!.body,
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification tap (app was in background)
  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint(
      '[NotificationService] Notification tapped: ${message.messageId}',
    );
    debugPrint('  Data: ${message.data}');

    // Navigate to appropriate screen based on payload
    // This would use the router from go_router
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
      '[NotificationService] Local notification tapped: ${response.id}',
    );
    debugPrint('  Payload: ${response.payload}');
  }

  /// Handle local notification tap (background)
  static void _onNotificationTappedBackground(
      NotificationResponse response) {
    debugPrint(
      '[NotificationService] Local notification tapped (bg): ${response.id}',
    );
    debugPrint('  Payload: ${response.payload}');
  }

  // =========================================================================
  // PUSH TOKEN MANAGEMENT
  // =========================================================================

  /// Get the current FCM token
  Future<String?> getToken() {
    return _messaging.getToken();
  }

  /// Check if push notifications are enabled
  Future<NotificationSettings> getPermissionStatus() {
    return _messaging.getNotificationSettings();
  }

  /// Delete the FCM token (unregister from push)
  Future<void> deleteToken() {
    return _messaging.deleteToken();
  }

  // =========================================================================
  // REMINDER SCHEDULING
  // =========================================================================

  /// Schedule a feeding reminder
  Future<void> scheduleFeedingReminder({
    required String reminderId,
    required DateTime scheduledTime,
    required String petName,
  }) async {
    await scheduleNotification(
      id: reminderId.hashCode,
      scheduledDate: scheduledTime,
      title: 'Time to feed $petName!',
      body: 'Your pet is due for their next meal.',
      payload: '{"type":"feeding_reminder","petName":"$petName"}',
    );
  }

  /// Schedule a medication reminder
  Future<void> scheduleMedicationReminder({
    required String reminderId,
    required DateTime scheduledTime,
    required String petName,
    required String medicationName,
  }) async {
    await scheduleNotification(
      id: reminderId.hashCode,
      scheduledDate: scheduledTime,
      title: 'Medication time for $petName!',
      body: 'Give $petName their $medicationName.',
      payload:
          '{"type":"medication_reminder","petName":"$petName","medication":"$medicationName"}',
    );
  }

  /// Schedule a vaccination due reminder
  Future<void> scheduleVaccinationReminder({
    required String reminderId,
    required DateTime scheduledTime,
    required String petName,
    required String vaccineName,
  }) async {
    await scheduleNotification(
      id: reminderId.hashCode,
      scheduledDate: scheduledTime,
      title: 'Vaccination due for $petName!',
      body: "$petName's $vaccineName vaccination is due.",
      payload:
          '{"type":"vaccination_reminder","petName":"$petName","vaccine":"$vaccineName"}',
    );
  }

  /// Schedule a weight check reminder
  Future<void> scheduleWeightReminder({
    required String reminderId,
    required DateTime scheduledTime,
    required String petName,
  }) async {
    await scheduleNotification(
      id: reminderId.hashCode,
      scheduledDate: scheduledTime,
      title: 'Weight check for $petName!',
      body: "Time to log $petName's weight.",
      payload: '{"type":"weight_reminder","petName":"$petName"}',
    );
  }

  /// Cancel a feeding reminder
  Future<void> cancelFeedingReminder(String reminderId) {
    return cancelNotification(reminderId.hashCode);
  }

  /// Cancel a medication reminder
  Future<void> cancelMedicationReminder(String reminderId) {
    return cancelNotification(reminderId.hashCode);
  }

  /// Cancel a vaccination reminder
  Future<void> cancelVaccinationReminder(String reminderId) {
    return cancelNotification(reminderId.hashCode);
  }

  /// Cancel a weight reminder
  Future<void> cancelWeightReminder(String reminderId) {
    return cancelNotification(reminderId.hashCode);
  }
}

/// Background message handler entry point (required by Firebase)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    '[NotificationService] Background handler: ${message.messageId}',
  );
  debugPrint('  Notification: ${message.notification?.title}');
  debugPrint('  Data: ${message.data}');
}
