import 'dart:convert';
import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quizverse/controllers/auth_controller.dart';
import 'package:quizverse/models/quiz_model.dart';
import 'package:quizverse/services/database_service.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:quizverse/services/notification_service.dart';

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
  Position? _currentPosition;
  bool _isSubmitting = false;
  late DateTime _quizStartTime;
  Timer? _questionTimer;
  static const int _maxDurationPerQuestion = 10;
  int _timerSecond = _maxDurationPerQuestion;
  final DatabaseService _databaseService = DatabaseService();
  final AuthController _authController = AuthController();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    if (widget.questions.isNotEmpty) {
      _setupQuestion();
    }
    _quizStartTime = DateTime.now();
    _startQuestionTimer();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
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
      _startQuestionTimer();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
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
    final quizDuration = DateTime.now().difference(_quizStartTime);
    final int durationInSeconds = quizDuration.inSeconds;
    _questionTimer?.cancel();

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
        List<geocoding.Placemark> placemarks = await geocoding
            .placemarkFromCoordinates(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          address =
              "${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}";
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

    // Ambil data quiz JSON ketika user selesai
    String? questionsJson;
    try {
      // 1. Ubah List<QuizModel> menjadi List<Map> menggunakan method toJson()
      List<Map<String, dynamic>> questionsMap = widget.questions
          .map((q) => q.toJson())
          .toList();
      // 2. Encode List<Map> menjadi satu String JSON
      questionsJson = jsonEncode(questionsMap);
    } catch (e) {
      debugPrint("Gagal encode questions ke JSON: $e");
    }

    String? answersJson;
    try {
      final Map<String, String?> stringKeyedAnswers = _userAnswers.map((
        key,
        value,
      ) {
        return MapEntry(key.toString(), value);
      });
      answersJson = jsonEncode(stringKeyedAnswers);
    } catch (e) {
      debugPrint("Gagal encode user answers ke JSON: $e");
    }

    try {
      final String? userIdString = await _authController.getLoggedInUserId();
      if (userIdString != null && widget.questions.isNotEmpty) {
        final int newHistoryId = await _databaseService.saveQuizResult(
          userId: int.parse(userIdString),
          category: widget.questions.first.category,
          difficulty: widget.questions.first.difficulty,
          score: score,
          duration: durationInSeconds,
          totalQuestions: widget.questions.length,
          latitude: _currentPosition?.latitude,
          longitude: _currentPosition?.longitude,
          address: address,
          quizDataJson: questionsJson,
          userAnswersJson: answersJson,
        );
        debugPrint("Quiz result saved successfully! History ID: $newHistoryId");

        await NotificationService().showQuizResultNotification(
          newHistoryId,
          score,
          widget.questions.length,
        );
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

    _confettiController.play();

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

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              'Soal ${_curIndex + 1} dari ${widget.questions.length}',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // <-- Semua konten kuis masuk ke dalam children Column ini
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- WIDGET TIMER ---
                LinearProgressIndicator(
                  value:
                      _timerSecond /
                      _maxDurationPerQuestion, // Persentase sisa waktu
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  minHeight: 10, // Agar lebih tebal
                ),
                const SizedBox(height: 8),
                Text(
                  "Waktu Tersisa: $_timerSecond detik",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _timerSecond <= 10
                        ? Colors.redAccent
                        : theme.primaryColor, // Warna merah jika <= 10 detik
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign:
                      TextAlign.center, // <-- Saya tambahkan ini agar rapi
                ),

                const SizedBox(
                  height: 16,
                ), // <-- Kasih jarak dari timer ke soal
                // --- KONTENER PERTANYAAN (PINDAHKAN KE SINI) ---
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

                // --- PILIHAN JAWABAN (PINDAHKAN KE SINI) ---
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tombol Kembali
                ElevatedButton.icon(
                  onPressed: _isSubmitting
                      ? null
                      : (_curIndex < widget.questions.length - 1
                            ? nextQuestion
                            : submitQuiz),
                  icon: _isSubmitting
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
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, // Menyebar
            shouldLoop: false,
            numberOfParticles: 20,
            gravity: 0.3,
            emissionFrequency: 0.05,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }

  void _startQuestionTimer() {
    // Reset detik
    _timerSecond = _maxDurationPerQuestion;
    // Batalkan timer sebelumnya jika ada
    _questionTimer?.cancel();

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_timerSecond > 0) {
        // Jika timer masih berjalan, panggil setState HANYA untuk update UI timer
        setState(() {
          _timerSecond--;
        });
      } else {
        // Jika timer sudah 0:
        // 1. Batalkan timer
        timer.cancel();

        // 2. Panggil _handleTimeout() DI LUAR setState()
        // Ini akan memanggil submitQuiz() dengan aman tanpa mengunci UI
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    // Tandai sebagai tidak dijawab (null)
    _userAnswers.putIfAbsent(_curIndex, () => null);

    if (_curIndex < widget.questions.length - 1) {
      nextQuestion(); // Pindah ke soal berikutnya
    } else {
      submitQuiz(); // Langsung submit jika ini soal terakhir
    }
  }

  // Pastikan timer dibatalkan saat pindah halaman
  @override
  void dispose() {
    _questionTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }
}
