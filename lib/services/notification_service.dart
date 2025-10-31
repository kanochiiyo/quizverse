import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quizverse/services/database_service.dart';
import 'package:quizverse/services/navigation_service.dart';
import 'package:quizverse/views/home/history_detail_view.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // Properti untuk onClick
      onDidReceiveNotificationResponse: onNotificationTap,
    );
  }

  // Callback handler saat notifikasi di-klik
  @pragma('vm:entry-point') // Wajib untuk callback background
  static void onNotificationTap(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;

    if (payload == null) return;

    // Cek jika ini adalah notifikasi hasil kuis
    if (payload.startsWith('history_id_')) {
      try {
        // 1. Ambil ID dari payload
        final int historyId = int.parse(payload.split('_').last);

        // 2. Ambil data lengkap dari database
        // Kita perlu inisialisasi DB Service lagi karena ini
        // mungkin berjalan di background (isolate)
        final dbService = DatabaseService();
        await dbService.database; // Pastikan database terbuka

        final historyItem = await dbService.getHistoryItemById(historyId);

        if (historyItem != null) {
          // 3. Navigasi ke Halaman Detail
          NavigationService.navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => HistoryDetailView(historyItem: historyItem),
            ),
          );
        }
      } catch (e) {
        debugPrint("Error handling notification tap: $e");
        // Fallback: buka halaman utama jika gagal
        // NavigationService.navigatorKey.currentState?.push(...);
      }
    }
    // ... (else if untuk reminder, jika ada) ...
  }

  // Notification permission (Android 13+)
  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // Fungsi spesifik untuk notifikasi hasil kuis
  Future<void> showQuizResultNotification(
    int historyId,
    int score,
    int totalQuestions,
  ) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'quiz_result_channel', // ID Channel
          'Hasil Kuis', // Nama Channel
          channelDescription: 'Notifikasi yang muncul setelah kuis selesai.',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );

    await flutterLocalNotificationsPlugin.show(
      historyId, // ID Notifikasi (statis untuk hasil kuis)
      "Kuis Selesai!",
      "Skor Anda: $score dari $totalQuestions. Klik untuk melihat riwayat.",
      notificationDetails,
      // Payload ini yang akan diterima 'onNotificationTap'
      payload: 'history_id_$historyId',
    );
  }
}
