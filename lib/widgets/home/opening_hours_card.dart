import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../../services/location_services.dart';

class OpeningHoursCard extends StatefulWidget {
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
  State<OpeningHoursCard> createState() => _OpeningHoursCardState();
}

class _OpeningHoursCardState extends State<OpeningHoursCard> {
  static const _baseZoneId = 'Asia/Jakarta'; // WIB outlet

  final LocationService _locService = LocationService();

  // Jadwal outlet per hari (WIB)
  final Map<int, Map<String, int>> _schedule = const {
    1: {'open': 8, 'close': 21},
    2: {'open': 8, 'close': 21},
    3: {'open': 8, 'close': 21},
    4: {'open': 8, 'close': 21},
    5: {'open': 8, 'close': 22},
    6: {'open': 6, 'close': 22},
    7: {'open': 6, 'close': 22},
  };

  late tz.Location _baseLoc;
  late tz.Location _userLoc;

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    _baseLoc = tz.getLocation(_baseZoneId);
    // default user: WIB
    _userLoc = tz.getLocation('Asia/Jakarta');
  }

  Map<String, int> _hoursForBaseDate(tz.TZDateTime baseDt) =>
      _schedule[baseDt.weekday] ?? const {'open': 8, 'close': 21};

  bool _isWithinOpenHours(tz.TZDateTime baseDt) {
    final h = _hoursForBaseDate(baseDt);
    final open = tz.TZDateTime(
      _baseLoc,
      baseDt.year,
      baseDt.month,
      baseDt.day,
      h['open']!,
      0,
    );
    final close = tz.TZDateTime(
      _baseLoc,
      baseDt.year,
      baseDt.month,
      baseDt.day,
      h['close']!,
      0,
    );
    return baseDt.isAfter(open) && baseDt.isBefore(close);
  }

  // Catatan: fungsi rekomendasi slot per 30 menit digantikan dengan rekomendasi sarapan/siang/malam

  // Rekomendasi waktu makan (Sarapan, Siang, Malam) berdasarkan zona user
  // Menyesuaikan ke jam operasional outlet (WIB). Jika di luar jam, digeser ke
  // jam buka terdekat (atau ke hari berikutnya).
  List<({String label, tz.TZDateTime baseWib, tz.TZDateTime userLocal})>
  _mealRecommendations(String userZoneId) {
    final userLoc = tz.getLocation(userZoneId);
    // final nowBase = tz.TZDateTime.now(_baseLoc); // tidak digunakan

    tz.TZDateTime openOf(tz.TZDateTime d) => tz.TZDateTime(
      _baseLoc,
      d.year,
      d.month,
      d.day,
      _hoursForBaseDate(d)['open']!,
      0,
    );
    tz.TZDateTime closeOf(tz.TZDateTime d) => tz.TZDateTime(
      _baseLoc,
      d.year,
      d.month,
      d.day,
      _hoursForBaseDate(d)['close']!,
      0,
    );

    // target default (WIB) untuk 3 waktu makan
    // Sarapan 08:00, Siang 12:30, Malam 19:00 pada zona pengguna, lalu konversi ke WIB
    List<({String label, int hh, int mm})> meals = const [
      (label: 'Sarapan', hh: 8, mm: 0),
      (label: 'Makan Siang', hh: 12, mm: 30),
      (label: 'Makan Malam', hh: 19, mm: 0),
    ];

    final todayUser = tz.TZDateTime.now(userLoc);
    final results =
        <({String label, tz.TZDateTime baseWib, tz.TZDateTime userLocal})>[];

    for (final m in meals) {
      // waktu target di zona user
      var userT = tz.TZDateTime(
        userLoc,
        todayUser.year,
        todayUser.month,
        todayUser.day,
        m.hh,
        m.mm,
      );
      // jika sudah lewat, pakai hari berikutnya
      if (userT.isBefore(todayUser)) {
        userT = userT.add(const Duration(days: 1));
      }
      // konversi ke WIB (base)
      var baseT = tz.TZDateTime.from(userT, _baseLoc);

      // sesuaikan dengan jam operasional di WIB
      final open = openOf(baseT);
      final close = closeOf(baseT);
      if (baseT.isBefore(open)) {
        baseT = open;
      } else if (!baseT.isBefore(close)) {
        // geser ke hari berikutnya pada jam buka
        final next = baseT.add(const Duration(days: 1));
        baseT = openOf(next);
      }

      final fixedUser = tz.TZDateTime.from(baseT, userLoc);
      results.add((label: m.label, baseWib: baseT, userLocal: fixedUser));
    }

    return results;
  }

  Future<void> _openSchedulePanel() async {
    final info = await _locService.detectUserTimeZone(context);
    _userLoc = tz.getLocation(info.zoneId);

    List<({String label, tz.TZDateTime baseWib, tz.TZDateTime userLocal})>
    mealRecs = _mealRecommendations(info.zoneId);

    if (!mounted) return;
    tz.TZDateTime manualLocal = mealRecs.first.userLocal;
    tz.TZDateTime manualWib = tz.TZDateTime.from(manualLocal, _baseLoc);

    String fmt(tz.TZDateTime dt) =>
        DateFormat('EEE, dd MMM yyyy • HH:mm', 'id_ID').format(dt);
    bool withinManual() =>
        _isWithinOpenHours(tz.TZDateTime.from(manualLocal, _baseLoc));

    // Daftar preset lokasi manual (tanpa input teks)
    final presets = <Map<String, String>>[
      {'label': 'WIB (Jakarta)', 'id': 'Asia/Jakarta'},
      {'label': 'WITA (Makassar)', 'id': 'Asia/Makassar'},
      {'label': 'WIT (Jayapura)', 'id': 'Asia/Jayapura'},
      {'label': 'London', 'id': 'Europe/London'},
      {'label': 'Jepang (Tokyo)', 'id': 'Asia/Tokyo'},
    ];
    String currentZoneId = info.zoneId;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        Future<void> applyZone(BuildContext ctx, String zoneId) async {
          _userLoc = tz.getLocation(zoneId);
          currentZoneId = zoneId;
          mealRecs = _mealRecommendations(zoneId);
          manualLocal = mealRecs.first.userLocal;
          manualWib = tz.TZDateTime.from(manualLocal, _baseLoc);
          (ctx as Element).markNeedsBuild();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (ctx, controller) {
              return ListView(
                controller: controller,
                children: [
                  const Text(
                    'Rekomendasi Waktu Reservasi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (info.address == null || info.address!.isEmpty)
                        ? 'Zona Anda: ${info.label}'
                        : 'Lokasi: ${info.address} • Zona: ${info.label}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),

                  // Rekomendasi Sarapan / Siang / Malam
                  ...mealRecs.map(
                    (e) => Card(
                      elevation: 0.5,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(
                          Icons.event_available,
                          color: Colors.green,
                        ),
                        title: Text('${e.label}: ${fmt(e.userLocal)}'),
                        subtitle: Text(
                          'WIB: ${DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(e.baseWib)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Dipilih: ${e.label} • ${fmt(e.userLocal)} '
                                '(${DateFormat('HH:mm', 'id_ID').format(e.baseWib)} WIB)',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  // PILIHAN MANUAL TANPA INPUT TEKS
                  const Text(
                    'Pilih Lokasi Manual',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),

                  // Tombol: pakai lokasi saat ini (deteksi ulang)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.my_location),
                    label: const Text('Gunakan Lokasi Saat Ini'),
                    onPressed: () async {
                      final reInfo = await _locService.detectUserTimeZone(
                        context,
                      );
                      await applyZone(ctx, reInfo.zoneId);
                    },
                  ),
                  const SizedBox(height: 8),

                  // ChoiceChip preset zona
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets.map((z) {
                      final selected = currentZoneId == z['id'];
                      return ChoiceChip(
                        label: Text(z['label']!),
                        selected: selected,
                        onSelected: (_) => applyZone(ctx, z['id']!),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Atur jadwal sendiri
                  const Text(
                    'Atur Jadwal Anda Sendiri',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.event),
                          label: Text(
                            DateFormat(
                              'EEE, dd MMM yyyy',
                              'id_ID',
                            ).format(manualLocal),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(
                                manualLocal.year,
                                manualLocal.month,
                                manualLocal.day,
                              ),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 180),
                              ),
                            );
                            if (picked != null) {
                              manualLocal = tz.TZDateTime(
                                _userLoc,
                                picked.year,
                                picked.month,
                                picked.day,
                                manualLocal.hour,
                                manualLocal.minute,
                              );
                              manualWib = tz.TZDateTime.from(
                                manualLocal,
                                _baseLoc,
                              );
                              (ctx as Element).markNeedsBuild();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            DateFormat('HH:mm', 'id_ID').format(manualLocal),
                          ),
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: manualLocal.hour,
                                minute: manualLocal.minute,
                              ),
                            );
                            if (t != null) {
                              manualLocal = tz.TZDateTime(
                                _userLoc,
                                manualLocal.year,
                                manualLocal.month,
                                manualLocal.day,
                                t.hour,
                                t.minute,
                              );
                              manualWib = tz.TZDateTime.from(
                                manualLocal,
                                _baseLoc,
                              );
                              (ctx as Element).markNeedsBuild();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Validasi + konversi hasil manual
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: withinManual()
                          ? Colors.green.withOpacity(.08)
                          : Colors.red.withOpacity(.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (withinManual() ? Colors.green : Colors.red)
                            .withOpacity(.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          withinManual()
                              ? Icons.check_circle
                              : Icons.error_outline,
                          color: withinManual() ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            withinManual()
                                ? 'Waktu pilihan Anda sesuai jam operasional outlet.'
                                : 'Di luar jam operasional outlet (WIB). Silakan pilih waktu lain.',
                            style: TextStyle(
                              color: withinManual()
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waktu Anda: ${fmt(manualLocal)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'WIB: ${DateFormat('EEE, dd MMM yyyy • HH:mm', 'id_ID').format(manualWib)}',
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Pilih Waktu Ini'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Dipilih: ${fmt(manualLocal)} '
                            '(${DateFormat('HH:mm', 'id_ID').format(manualWib)} WIB)',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.isOpen ? Colors.green : Colors.red;
    final nowJakarta = DateFormat('HH:mm').format(DateTime.now());

    // tampilkan header/info jam buka + tombol panel
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
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.isOpen ? Icons.access_time_filled : Icons.lock_clock,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jam Buka ${widget.dayLabel}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.openHour.toString().padLeft(2, '0')}:00 - ${widget.closeHour.toString().padLeft(2, '0')}:00 WIB',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sekarang: $nowJakarta WIB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.isOpen ? 'Buka' : 'Tutup',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text('Jadwalkan Reservasi Anda'),
                onPressed: _openSchedulePanel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange.shade800,
                  side: BorderSide(color: Colors.orange.shade300),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
