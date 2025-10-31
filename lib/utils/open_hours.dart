import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class OpenHours {
  OpenHours._();
  static bool _inited = false;

  static const String zoneId = 'Asia/Jakarta';
  static const Map<int, Map<String, int>> _schedule = {
    1: {'open': 8, 'close': 21},
    2: {'open': 8, 'close': 21},
    3: {'open': 8, 'close': 21},
    4: {'open': 8, 'close': 21},
    5: {'open': 8, 'close': 22},
    6: {'open': 6, 'close': 22},
    7: {'open': 6, 'close': 22},
  };

  static void ensureInit() {
    if (_inited) return;
    tzdata.initializeTimeZones();
    _inited = true;
  }

  static Map<String, int> todayHours() {
    ensureInit();
    final loc = tz.getLocation(zoneId);
    final now = tz.TZDateTime.now(loc);
    return _schedule[now.weekday] ?? {'open': 8, 'close': 21};
  }

  static bool isOpenNow() {
    ensureInit();
    final loc = tz.getLocation(zoneId);
    final now = tz.TZDateTime.now(loc);
    final h = todayHours();
    final open = tz.TZDateTime(
      loc,
      now.year,
      now.month,
      now.day,
      h['open']!,
      0,
    );
    final close = tz.TZDateTime(
      loc,
      now.year,
      now.month,
      now.day,
      h['close']!,
      0,
    );
    return now.isAfter(open) && now.isBefore(close);
  }

  static String todayLabel() {
    ensureInit();
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final loc = tz.getLocation(zoneId);
    final now = tz.TZDateTime.now(loc);
    return days[now.weekday - 1];
  }
}
