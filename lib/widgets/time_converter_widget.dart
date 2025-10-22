import 'package:flutter/material.dart';
// Note: timezone package is not available in the provided tool list.
// The code below is a conceptual implementation. 
// For actual use, you'd need the 'timezone' package.
// For now, we will simulate the time conversion.

class TimeConverterWidget extends StatefulWidget {
  const TimeConverterWidget({super.key});

  @override
  State<TimeConverterWidget> createState() => _TimeConverterWidgetState();
}

class _TimeConverterWidgetState extends State<TimeConverterWidget> {
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now().toUtc(); // Start with UTC time
    });
  }
  
  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // Simulated time zone offsets from UTC
    final timeWIB = _now.add(const Duration(hours: 7));
    final timeWITA = _now.add(const Duration(hours: 8));
    final timeWIT = _now.add(const Duration(hours: 9));
    final timeLondon = _now.add(const Duration(hours: 1)); // Assuming BST (UTC+1)

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Konversi Waktu", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ListTile(
              title: const Text("WIB (Jakarta)"),
              trailing: Text(_formatTime(timeWIB), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              title: const Text("WITA (Makassar)"),
              trailing: Text(_formatTime(timeWITA), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              title: const Text("WIT (Jayapura)"),
              trailing: Text(_formatTime(timeWIT), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              title: const Text("London (GMT/BST)"),
              trailing: Text(_formatTime(timeLondon), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh Waktu"),
                onPressed: _updateTime,
              ),
            )
          ],
        ),
      ),
    );
  }
}