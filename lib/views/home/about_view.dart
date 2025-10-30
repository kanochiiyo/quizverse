import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        automaticallyImplyLeading: false,
        // AppBar otomatis pakai tema
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Padding konsisten
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Card Informasi Aplikasi ---
            Card(
              // Otomatis pakai CardTheme
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 28,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'QuizVerse',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Versi 1.0.0',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aplikasi kuis trivia seru untuk menguji dan menambah pengetahuanmu dalam berbagai kategori!',
                      style: TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Card Informasi Developer (DIUBAH) ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 28,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Developer',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // --- GANTI DENGAN LISTTILE ---
                    ListTile(
                      leading: Icon(
                        Icons.account_circle,
                        color: colorScheme.secondary,
                      ),
                      title: const Text('Nama'),
                      subtitle: const Text('Andini Andaresta'),
                      dense: true,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.numbers,
                        color: colorScheme.secondary,
                      ),
                      title: const Text('NIM'),
                      subtitle: const Text('124230084'),
                      dense: true,
                    ),
                    // --- AKHIR PERUBAHAN ---
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Card Kesan & Pesan ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 28,
                          color: Colors.teal, // Tetap teal, cocok
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Kesan & Pesan',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "BAGUS B NYA BOORIED",
                      textAlign: TextAlign.justify,
                      style: textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
