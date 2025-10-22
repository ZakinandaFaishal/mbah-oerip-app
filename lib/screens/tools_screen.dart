import 'package:flutter/material.dart';
import '../widgets/currency_converter_widget.dart';
import '../widgets/time_converter_widget.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konverter'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: const [
          TimeConverterWidget(),
          SizedBox(height: 16),
          CurrencyConverterWidget(),
        ],
      ),
    );
  }
}