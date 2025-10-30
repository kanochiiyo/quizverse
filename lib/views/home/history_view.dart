import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:quizverse/controllers/auth_controller.dart'; // To get user ID
import 'package:quizverse/services/database_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseService _dbHelper = DatabaseService();
  final AuthController _authController = AuthController();
  List<Map<String, dynamic>> _quizHistory = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return; // Check if the widget is still in the tree

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? userIdString = await _authController.getLoggedInUserId();
      if (userIdString != null) {
        final int userId = int.parse(userIdString);
        final history = await _dbHelper.getQuizHistory(userId);
        if (!mounted) return; // Check again after await
        setState(() {
          _quizHistory = history;
          _isLoading = false;
        });
      } else {
        // Handle case where user ID is not found (shouldn't happen if logged in)
        if (!mounted) return;
        setState(() {
          _errorMessage = "Tidak dapat memuat riwayat: User tidak ditemukan.";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Gagal memuat riwayat: ${e.toString()}";
        _isLoading = false;
      });
      debugPrint("Error loading history: $e");
    }
  }

  // Helper function to format the date string
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Tanggal tidak diketahui';
    try {
      final dateTime = DateTime.parse(dateString);
      // Format: Hari, Tanggal Bulan Tahun Jam:Menit (e.g., Sen, 30 Okt 2025 10:30)
      return DateFormat('EEE, d MMM yyyy HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  // Helper function to capitalize the first letter
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Kuis'),
        automaticallyImplyLeading: false, // Remove default back button
      ),
      body: _buildBody(), // Use a helper function for the body
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_quizHistory.isEmpty) {
      return const Center(child: Text('Belum ada riwayat kuis.'));
    }

    // Display history using ListView.builder
    return ListView.builder(
      itemCount: _quizHistory.length,
      itemBuilder: (context, index) {
        final historyItem = _quizHistory[index];
        final score = historyItem['score'] as int?;
        final totalQuestions = historyItem['total_questions'] as int?;
        final category = historyItem['category'] as String?;
        final difficulty = historyItem['difficulty'] as String?;
        final date = historyItem['quiz_date'] as String?;
        final latitude = historyItem['latitude'] as double?;
        final longitude = historyItem['longitude'] as double?;
        final address = historyItem['address'] as String?;

        final theme = Theme.of(context);

        return Padding(
          padding: EdgeInsetsGeometry.all(12),
          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading: Icon(
                Icons.history_edu,
                color: theme.primaryColor,
                size: 36, // Sedikit lebih besar
              ),
              title: Text(
                category ?? 'Kategori Tidak Diketahui',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Kesulitan: ${difficulty != null ? capitalize(difficulty) : '?'}',
                  ),
                  Text(_formatDate(date)),

                  // --- TAMPILAN LOKASI BARU ---
                  if (address != null && address.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 4),
                          // Tampilkan alamat
                          Expanded(
                            child: Text(
                              address,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  // Fallback jika alamat null tapi ada Lat/Long
                  else if (latitude != null && longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  // --- AKHIR TAMPILAN LOKASI BARU ---
                ],
              ),
              trailing: Chip(
                label: Text(
                  '${score ?? '?'} / ${totalQuestions ?? '?'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                // --- GANTI WARNA CHIP ---
                backgroundColor: theme.primaryColor, // <-- WARNA BARU
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ),
          ),
        );
      },
    );
  }
}
