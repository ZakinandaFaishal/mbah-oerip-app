import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'orders_channel';
  static const String _channelName = 'Order Notifications';
  static const String _channelDesc = 'Notifications for order updates';

  Future<void> init() async {
    // gunakan small icon monochrome
    const androidInit = AndroidInitializationSettings('@drawable/splash_logo');
    const settings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(channel);

    // Izin Android 13+
    try {
      await (androidImpl as dynamic)?.requestNotificationsPermission();
    } catch (_) {
      try {
        await (androidImpl as dynamic)?.requestPermission();
      } catch (_) {}
    }
  }

  Future<void> showOrderSuccess({
    required String orderId,
    required int totalInIDR,
  }) async {
    final idr = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/splash_logo', // small icon putih
      largeIcon: DrawableResourceAndroidBitmap(
        'splash_logo',
      ), // logo berwarna (opsional)
      styleInformation: BigTextStyleInformation(''),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      'Pesanan Anda berhasil dibuat',
      'ID: $orderId • Total: ${idr.format(totalInIDR)}',
      const NotificationDetails(android: android),
      payload: orderId,
    );
  }
}
