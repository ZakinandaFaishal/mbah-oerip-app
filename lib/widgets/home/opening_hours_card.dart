import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../../services/location_services.dart';
import '../../theme.dart';

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
  static const _baseZoneId = 'Asia/Jakarta';

  final LocationService _locService = LocationService();

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

  List<({String label, tz.TZDateTime baseWib, tz.TZDateTime userLocal})>
  _mealRecommendations(String userZoneId) {
    final userLoc = tz.getLocation(userZoneId);

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

    List<({String label, int hh, int mm})> meals = const [
      (label: 'Sarapan', hh: 8, mm: 0),
      (label: 'Makan Siang', hh: 12, mm: 30),
      (label: 'Makan Malam', hh: 19, mm: 0),
    ];

    final todayUser = tz.TZDateTime.now(userLoc);
    final results =
        <({String label, tz.TZDateTime baseWib, tz.TZDateTime userLocal})>[];

    for (final m in meals) {
      var userT = tz.TZDateTime(
        userLoc,
        todayUser.year,
        todayUser.month,
        todayUser.day,
        m.hh,
        m.mm,
      );
      if (userT.isBefore(todayUser)) {
        userT = userT.add(const Duration(days: 1));
      }
      var baseT = tz.TZDateTime.from(userT, _baseLoc);

      final open = openOf(baseT);
      final close = closeOf(baseT);
      if (baseT.isBefore(open)) {
        baseT = open;
      } else if (!baseT.isBefore(close)) {
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (info.address == null || info.address!.isEmpty)
                        ? 'Zona Anda: ${info.label}'
                        : 'Lokasi: ${info.address} • Zona: ${info.label}',
                    style: TextStyle(
                      color: AppTheme.textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rekomendasi Sarapan / Siang / Malam
                  ...mealRecs.map(
                    (e) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      color: AppTheme.goldPale.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppTheme.accentOrange.withOpacity(0.3),
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.event_available,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                        title: Text(
                          '${e.label}: ${fmt(e.userLocal)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        subtitle: Text(
                          'WIB: ${DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(e.baseWib)}',
                          style: TextStyle(
                            color: AppTheme.textColor.withOpacity(0.6),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppTheme.accentOrange,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.primaryOrange,
                              content: Text(
                                'Dipilih: ${e.label} • ${fmt(e.userLocal)}',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Divider(color: AppTheme.accentOrange.withOpacity(0.2)),
                  const SizedBox(height: 12),

                  Text(
                    'Pilih Lokasi Manual',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.my_location, color: AppTheme.primaryOrange,),
                    label: const Text('Gunakan Lokasi Saat Ini'),
                    onPressed: () async {
                      final reInfo = await _locService.detectUserTimeZone(
                        context,
                      );
                      await applyZone(ctx, reInfo.zoneId);
                    },
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets.map((z) {
                      final selected = currentZoneId == z['id'];
                      return ChoiceChip(
                        label: Text(z['label']!),
                        selected: selected,
                        selectedColor: AppTheme.accentOrange.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color: selected
                              ? AppTheme.primaryOrange
                              : AppTheme.textColor,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                        onSelected: (_) => applyZone(ctx, z['id']!),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: AppTheme.accentOrange.withOpacity(0.2)),
                  const SizedBox(height: 12),

                  Text(
                    'Atur Jadwal Anda Sendiri',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          (withinManual()
                                  ? AppTheme.accentOrange
                                  : AppTheme.primaryRed)
                              .withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            (withinManual()
                                    ? AppTheme.accentOrange
                                    : AppTheme.primaryRed)
                                .withOpacity(.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          withinManual()
                              ? Icons.check_circle
                              : Icons.error_outline,
                          color: withinManual()
                              ? AppTheme.accentOrange
                              : AppTheme.primaryRed,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            withinManual()
                                ? 'Waktu pilihan Anda sesuai jam operasional outlet.'
                                : 'Di luar jam operasional outlet (WIB). Silakan pilih waktu lain.',
                            style: TextStyle(
                              color: withinManual()
                                  ? AppTheme.accentOrange
                                  : AppTheme.primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Waktu Anda: ${fmt(manualLocal)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  Text(
                    'WIB: ${DateFormat('EEE, dd MMM yyyy • HH:mm', 'id_ID').format(manualWib)}',
                    style: TextStyle(
                      color: AppTheme.textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Pilih Waktu Ini'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.primaryOrange,
                          content: Text('Dipilih: ${fmt(manualLocal)}'),
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
    final statusColor = widget.isOpen
        ? AppTheme.accentOrange
        : AppTheme.primaryRed;
    final nowJakarta = DateFormat('HH:mm').format(DateTime.now());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.goldPale.withOpacity(0.5),
              AppTheme.backgroundWhite,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.isOpen ? Icons.access_time_filled : Icons.lock_clock,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jam Buka ${widget.dayLabel}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.openHour.toString().padLeft(2, '0')}:00 - ${widget.closeHour.toString().padLeft(2, '0')}:00 WIB',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sekarang: $nowJakarta WIB',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.isOpen ? 'Buka' : 'Tutup',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppTheme.accentOrange.withOpacity(0.2)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text('Jadwalkan Reservasi Anda'),
                onPressed: _openSchedulePanel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
