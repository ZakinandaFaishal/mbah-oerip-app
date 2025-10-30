import 'package:flutter/material.dart';

class AddressSection extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onDetect;
  final ValueChanged<String> onChanged;
  const AddressSection({
    super.key,
    required this.controller,
    required this.loading,
    required this.onDetect,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alamat Pengiriman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Masukkan alamat pengiriman',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: loading ? null : onDetect,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.my_location),
            label: const Text('Deteksi Lokasi Otomatis'),
          ),
        ),
      ],
    );
  }
}
