// lib/views/home/quiz_view.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quizverse/controllers/auth_controller.dart';
import 'package:quizverse/models/quiz_model.dart';
import 'package:quizverse/services/database_service.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class QuizView extends StatefulWidget {
  final List<QuizModel> questions;
  const QuizView({super.key, required this.questions});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int _curIndex = 0;
  String? selectedAnswer;
  final Map<int, String?> _userAnswers = {};
  late List<String> _shuffledAnswers;

  final DatabaseService _databaseService = DatabaseService();
  final AuthController _authController = AuthController();
  Position? _currentPosition;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.questions.isNotEmpty) {
      _setupQuestion();
    }
    _getCurrentLocation();
  }

  void _setupQuestion() {
    final q = widget.questions[_curIndex];
    _shuffledAnswers = [q.correctAnswer, ...q.incorrectAnswers];
    _shuffledAnswers.shuffle();
    selectedAnswer = _userAnswers[_curIndex];
  }

  void nextQuestion() {
    if (_curIndex < widget.questions.length - 1) {
      setState(() {
        _curIndex++;
        _setupQuestion();
      });
    }
  }

  void prevQuestion() {
    if (_curIndex > 0) {
      setState(() {
        _curIndex--;
        _setupQuestion();
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Layanan lokasi dimatikan. Aktifkan untuk menyimpan lokasi kuis.',
            ),
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak permanen, kami tidak bisa meminta izin lagi.',
            ),
          ),
        );
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        debugPrint(
          "Location obtained: ${position.latitude}, ${position.longitude}",
        );
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan lokasi: ${e.toString()}')),
        );
      }
    }
  }

  void submitQuiz() async {
    setState(() => _isSubmitting = true);
    int score = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (_userAnswers[i] == widget.questions[i].correctAnswer) {
        score++;
      }
    }

    if (_currentPosition == null) {
      await _getCurrentLocation();
    }

    String? address;
    if (_currentPosition != null) {
      try {
        // Panggil package geocoding
        List<geocoding.Placemark> placemarks = await geocoding
            .placemarkFromCoordinates(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          // Buat format alamat yang rapi (bisa disesuaikan)
          address =
              "${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}";
          // Hilangkan "null" atau "Kecamatan " yang tidak perlu jika ada
          address = address
              .replaceAll("null, ", "")
              .replaceAll("Kecamatan ", "");
          debugPrint("Address obtained: $address");
        }
      } catch (e) {
        debugPrint("Error getting address from geocoding: $e");
        address = null; // Gagal mendapatkan alamat
      }
    }

    try {
      final String? userIdString = await _authController.getLoggedInUserId();
      if (userIdString != null && widget.questions.isNotEmpty) {
        final int userId = int.parse(userIdString);
        final firstQuestion = widget.questions.first;

        await _databaseService.saveQuizResult(
          userId: userId,
          category: firstQuestion.category,
          difficulty: firstQuestion.difficulty,
          score: score,
          totalQuestions: widget.questions.length,
          latitude: _currentPosition?.latitude,
          longitude: _currentPosition?.longitude,
          address: address,
        );
        debugPrint("Quiz result saved successfully!");
      } else {
        debugPrint(
          "User ID not found or questions empty, couldn't save history.",
        );
      }
    } catch (e) {
      debugPrint("Error saving quiz result: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan riwayat: ${e.toString()}')),
        );
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }

    // Dialog skor
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false, // User harus klik OK
      builder: (context) => AlertDialog(
        title: const Text("Kuis Selesai!"),
        content: Text("Skor Anda: $score dari ${widget.questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke halaman Home
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerTile(String answer) {
    final bool isSelected = selectedAnswer == answer;
    final theme = Theme.of(context);

    return Card(
      // CardTheme akan dipakai dari global
      elevation: isSelected ? 4.0 : 1.5,
      color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.primaryColor : Colors.grey.shade300,
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedAnswer = answer;
            _userAnswers[_curIndex] = answer;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answer,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Tampilkan ikon centang jika dipilih
              if (isSelected)
                Icon(Icons.check_circle, color: theme.primaryColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Gagal memuat pertanyaan. Silakan coba lagi.'),
        ),
      );
    }

    final q = widget.questions[_curIndex];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Soal ${_curIndex + 1} dari ${widget.questions.length}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kontainer Pertanyaan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                q.question,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Pilihan Jawaban
            ..._shuffledAnswers.map((answer) {
              return _buildAnswerTile(answer);
            }),
          ],
        ),
      ),
      // Tombol Navigasi Bawah
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tombol Kembali
            ElevatedButton.icon(
              // Disable jika sedang submit ATAU di soal pertama
              onPressed: (_isSubmitting || _curIndex == 0)
                  ? null
                  : prevQuestion,
              icon: const Icon(Icons.navigate_before),
              label: const Text("Kembali"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.primaryColor,
                side: BorderSide(color: theme.primaryColor),
                disabledBackgroundColor: Colors.grey.shade200,
              ),
            ),

            // Tombol Lanjut / Selesai
            ElevatedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : // Disable jika sedang submit
                    (_curIndex < widget.questions.length - 1
                        ? nextQuestion
                        : submitQuiz),
              icon:
                  _isSubmitting // Tampilkan loading jika sedang submit
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Icon(
                      _curIndex < widget.questions.length - 1
                          ? Icons.navigate_next
                          : Icons.check,
                    ),
              label: Text(
                _isSubmitting
                    ? "Menyimpan..."
                    : (_curIndex < widget.questions.length - 1
                          ? "Lanjut"
                          : "Selesai"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
