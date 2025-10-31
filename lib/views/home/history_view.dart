import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:quizverse/controllers/auth_controller.dart'; // To get user ID
import 'package:quizverse/services/database_service.dart';
import 'package:quizverse/views/home/history_detail_view.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseService _dbHelper = DatabaseService();
  final AuthController _authController = AuthController();

  // Controller untuk search bar
  final TextEditingController _searchController = TextEditingController();
  // List untuk menyimpan semua riwayat asli dari DB
  List<Map<String, dynamic>> _quizHistory = [];
  // List untuk menyimpan hasil filter yang akan ditampilkan
  List<Map<String, dynamic>> _filteredHistory = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();

    // Tambahkan listener ke search controller.
    // Setiap kali teks berubah, panggil _filterHistory.
    _searchController.addListener(() {
      _filterHistory(_searchController.text);
    });
  }

  // dispose controller saat widget tidak lagi digunakan
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        if (!mounted) return;
        setState(() {
          _quizHistory = history; // Simpan data asli
          _filteredHistory = history; // Awalnya, tampilkan semua data
          _isLoading = false;
        });
      } else {
        // Case where user ID is not found
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

  // Fungsi untuk memfilter riwayat berdasarkan query pencarian
  void _filterHistory(String query) {
    final lowerCaseQuery = query.toLowerCase();

    final filteredList = _quizHistory.where((item) {
      final category = (item['category'] as String?)?.toLowerCase() ?? '';
      final difficulty = (item['difficulty'] as String?)?.toLowerCase() ?? '';
      final address = (item['address'] as String?)?.toLowerCase() ?? '';

      return category.contains(lowerCaseQuery) ||
          difficulty.contains(lowerCaseQuery) ||
          address.contains(lowerCaseQuery);
    }).toList();

    // Update state list yang akan ditampilkan
    setState(() {
      _filteredHistory = filteredList;
    });
  }

  // Helper function to format the date string
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Tanggal tidak diketahui';
    try {
      final isoUtcString = dateString.replaceFirst(' ', 'T') + "Z";
      final dateTime = DateTime.parse(isoUtcString);
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
        automaticallyImplyLeading: false, // Remove back button
      ),

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kategori, kesulitan, atau lokasi...',
                prefixIcon: const Icon(Icons.search),
                // Tambahkan tombol clear (X)
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          // _filterHistory('') akan otomatis terpanggil oleh listener
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
            ),
          ),

          Expanded(
            child: _buildBody(), // Panggil helper function
          ),
        ],
      ),
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

    if (_filteredHistory.isEmpty) {
      return const Center(
        child: Text('Tidak ada riwayat yang cocok dengan pencarian.'),
      );
    }

    return ListView.builder(
      itemCount: _filteredHistory.length,
      itemBuilder: (context, index) {
        final historyItem = _filteredHistory[index];

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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
              onTap: () {
                // Cek jika data JSON ada (untuk data lama)
                if (historyItem['quiz_data_json'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HistoryDetailView(historyItem: historyItem),
                    ),
                  );
                } else {
                  // Jika data JSON-nya null (untuk riwayat lama)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Detail untuk riwayat ini tidak tersedia.'),
                      backgroundColor: Colors.grey[700],
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
