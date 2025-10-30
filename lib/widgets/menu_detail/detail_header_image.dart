import 'package:flutter/material.dart';

class DetailHeaderImage extends StatelessWidget {
  final String imageUrl;
  const DetailHeaderImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 300,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey, size: 60),
      ),
    );
  }
}
