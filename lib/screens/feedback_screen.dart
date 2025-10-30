import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  late Box _feedbackBox;
  StreamSubscription? _sub;
  List<MapEntry<dynamic, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _initBox();
  }

  Future<void> _initBox() async {
    // Box sudah dibuka di main.dart, tapi aman-kan jika belum
    if (!Hive.isBoxOpen('feedback')) {
      _feedbackBox = await Hive.openBox('feedback');
    } else {
      _feedbackBox = Hive.box('feedback');
    }
    _reloadEntries();

    // Dengarkan perubahan agar list otomatis ter-update
    _sub = _feedbackBox.watch().listen((_) => _reloadEntries());
  }

  void _reloadEntries() {
    final map = _feedbackBox.toMap();
    // Urutkan dari terbaru (key timestamp ISO) ke lama
    final list = map.entries.toList()
      ..sort((a, b) => (b.key as String).compareTo(a.key as String));
    setState(() => _entries = list);
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      final key = DateTime.now().toIso8601String();
      _feedbackBox.put(key, _feedbackController.text.trim());

      _feedbackController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terima kasih atas saran & kesannya!')),
      );
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saran & Kesan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _feedbackController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Saran & kesan untuk Pemrograman Aplikasi Mobile',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mohon isi saran dan kesan Anda.';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('KIRIM'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Riwayat Saran & Kesan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text('Belum ada masukan.'))
                  : ListView.separated(
                      itemCount: _entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final e = _entries[i];
                        final ts = e.key as String;
                        final txt = e.value as String;
                        final dt = DateTime.tryParse(ts);
                        return ListTile(
                          title: Text(txt),
                          subtitle: dt == null
                              ? null
                              : Text(
                                  '${dt.day.toString().padLeft(2, '0')}-'
                                  '${dt.month.toString().padLeft(2, '0')}-'
                                  '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
                                  '${dt.minute.toString().padLeft(2, '0')}',
                                ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _feedbackBox.delete(ts),
                            tooltip: 'Hapus',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
