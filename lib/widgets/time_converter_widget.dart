import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class RestaurantTimingWidget extends StatefulWidget {
  const RestaurantTimingWidget({super.key});

  @override
  State<RestaurantTimingWidget> createState() => _RestaurantTimingWidgetState();
}

class _RestaurantTimingWidgetState extends State<RestaurantTimingWidget> {
  late DateTime _now;
  final openingTime = const TimeOfDay(hour: 10, minute: 0); // 10:00 AM
  final closingTime = const TimeOfDay(hour: 22, minute: 0); // 10:00 PM

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
    });
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  bool get _isRestaurantOpen {
    final now = TimeOfDay.fromDateTime(_now);
    return now.hour >= openingTime.hour && now.hour < closingTime.hour;
  }

  String _getEstimatedDeliveryTime() {
    if (!_isRestaurantOpen) return 'Restoran Tutup';
    return 'Estimasi Pengiriman: ${_formatTime(_now.add(const Duration(minutes: 45)))}';
  }

  String _getEstimatedPreparationTime() {
    if (!_isRestaurantOpen) return '-';
    return '20-30 menit';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Info Waktu",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _isRestaurantOpen ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isRestaurantOpen ? "BUKA" : "TUTUP",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Jam Operasional
            const Text(
              "Jam Operasional:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "${openingTime.format(context)} - ${closingTime.format(context)} WIB",
            ),
            const SizedBox(height: 12),

            // Waktu Saat Ini
            const Text(
              "Waktu Saat Ini:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_formatTime(_now)),
            const SizedBox(height: 12),

            // Estimasi Pengiriman
            const Text(
              "Estimasi Pengiriman:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_getEstimatedDeliveryTime()),
            const SizedBox(height: 12),

            // Estimasi Waktu Persiapan
            const Text(
              "Waktu Persiapan:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_getEstimatedPreparationTime()),

            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Perbarui Waktu"),
                onPressed: _updateTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
