import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final Box _feedbackBox = Hive.box('feedback');

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      // Simpan feedback ke Hive. Gunakan timestamp sebagai key unik.
      _feedbackBox.put(
        DateTime.now().toIso8601String(),
        _feedbackController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terima kasih atas saran & kesannya!')),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saran & Kesan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sampaikan saran dan kesan Anda untuk mata kuliah Pemrograman Aplikasi Mobile.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _feedbackController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Ketik di sini...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mohon isi saran dan kesan Anda.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('KIRIM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}