import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OpeningHoursCard extends StatelessWidget {
  final bool isOpen;
  final String dayLabel;
  final int openHour;
  final int closeHour;

  const OpeningHoursCard({
    super.key,
    required this.isOpen,
    required this.dayLabel,
    required this.openHour,
    required this.closeHour,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isOpen ? Colors.green : Colors.red;
    final now = DateFormat('HH:mm').format(DateTime.now());
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isOpen ? Icons.access_time_filled : Icons.lock_clock,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Buka $dayLabel',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${openHour.toString().padLeft(2, '0')}:00 - ${closeHour.toString().padLeft(2, '0')}:00 WIB',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sekarang: $now WIB',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOpen ? 'Buka' : 'Tutup',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
