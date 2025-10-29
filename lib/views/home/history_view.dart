import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Kuis'),
        automaticallyImplyLeading: false, // Hilangkan tombol back default
      ),
      body: const Center(
        child: Text('Halaman Riwayat Kuis (Belum Dikembangkan)'),
      ),
    );
  }
}
