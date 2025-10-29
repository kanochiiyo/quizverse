import 'package:flutter/material.dart';

// Class tetap StatelessWidget
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil ThemeData untuk styling
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Placeholder teks Lorem Ipsum
    const String loremIpsum =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Card Informasi Aplikasi (Tetap Sama) ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            const SizedBox(height: 25),

            // --- Card Informasi Developer (Tetap Sama) ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                    _buildDeveloperInfoRow(
                      Icons.account_circle,
                      'Nama',
                      'Kanochiiyo',
                    ),
                    const SizedBox(height: 10),
                    _buildDeveloperInfoRow(
                      Icons.school,
                      'Institusi',
                      'UPN Veteran Yogyakarta',
                    ),
                    const SizedBox(height: 10),
                    _buildDeveloperInfoRow(
                      Icons.code,
                      'Proyek',
                      'Pemrograman Aplikasi Mobile (TAI)',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25), // Jarak ke card baru
            // --- Card Kesan & Pesan (Baru) ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      // Baris untuk Ikon dan Judul
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 28,
                          color: Colors.teal,
                        ), // Ikon kesan/pesan
                        const SizedBox(width: 10),
                        Text(
                          'Kesan & Pesan', // Judul Card
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15), // Jarak ke teks
                    Text(
                      loremIpsum, // Tampilkan teks placeholder
                      textAlign: TextAlign.justify, // Ratakan teks kiri-kanan
                      style: textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Colors.black87,
                      ), // Styling teks
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), // Jarak di bawah card terakhir
          ],
        ),
      ),
    );
  }

  // Helper widget (tetap sama)
  Widget _buildDeveloperInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[800])),
        ),
      ],
    );
  }
}
