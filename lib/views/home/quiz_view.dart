import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quizverse/controllers/auth_controller.dart';
import 'package:quizverse/models/quiz_model.dart';
import 'package:quizverse/services/database_helper.dart';

class QuizView extends StatefulWidget {
  // Data dari HomeView dan bikin constructor
  final List<QuizModel> questions;
  const QuizView({super.key, required this.questions});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int _curIndex = 0;
  String? selectedAnswer;
  // Penampungan untuk jawaban user (menggunakan map, key:value) dan tempat untuk jawaban yang sudah diacak
  final Map<int, String?> _userAnswers = {};
  late List<String> _shuffledAnswers;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthController _authController = AuthController();
  Position? _currentPosition;
  

  @override
  void initState() {
    super.initState();
    // Pertama kali widget dibuat langsung panggil _setupQuestion
    _setupQuestion();
    _getCurrentLocation();
  }

  void _setupQuestion() {
    final q = widget.questions[_curIndex];
    _shuffledAnswers = [q.correctAnswer, ...q.incorrectAnswers];
    _shuffledAnswers.shuffle();

    selectedAnswer = _userAnswers[_curIndex];
  }

  void nextQuestion() {
    setState(() {
      _curIndex++;
      _setupQuestion();
    });
  }

  void prevQuestion() {
    setState(() {
      _curIndex--;
      _setupQuestion();
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users to enable the location services.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Layanan lokasi dimatikan. Aktifkan untuk menyimpan lokasi kuis.',
            ),
          ),
        );
      }
      return; // Tidak menghentikan kuis, hanya tidak dapat lokasi
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true). According to Android guidelines
        // your App should show an explanatory UI now.
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
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

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Akurasi sedang cukup
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

    int score = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (_userAnswers[i] == widget.questions[i].correctAnswer) {
        score++;
      }
    }

    if (_currentPosition == null) {
      await _getCurrentLocation();
    }

    // Save history quiz
    try {
      final String? userIdString = await _authController.getLoggedInUserId();
      if (userIdString != null && widget.questions.isNotEmpty) {
        final int userId = int.parse(userIdString);
        final firstQuestion = widget.questions.first; // Ambil info dari soal pertama

        await _dbHelper.saveQuizResult(
          userId: userId,
          // Ambil nama kategori dari API response jika ada, atau gunakan ID jika tidak
          // Misalnya kita simpan nama kategori jika ada di model:
          category: firstQuestion.category, // Asumsi QuizModel punya nama kategori
          difficulty: firstQuestion.difficulty,
          score: score,
          totalQuestions: widget.questions.length,
          latitude: _currentPosition?.latitude, 
          longitude: _currentPosition?.longitude,
        );
         debugPrint("Quiz result saved successfully!"); // Optional logging
      } else {
        debugPrint("User ID not found or questions empty, couldn't save history.");
      }
    } catch (e) {
      debugPrint("Error saving quiz result: $e");
      // Tampilkan pesan error ke user jika perlu
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Gagal menyimpan riwayat: ${e.toString()}'))
        );
      }
    }

    // Dialog skor
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("You did great!"),
        content: Text("Skor: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_curIndex];

    if (widget.questions.isEmpty) {
      return const Center(child: Text('Belum ada pertanyaan'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Soal ${_curIndex + 1} dari ${widget.questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(q.question),
            const SizedBox(height: 30),
            Column(
              children: _shuffledAnswers.map((answer) {
                return RadioListTile<String>(
                  title: Text(answer),
                  value: answer,
                  // Variabel yang menyimpan pilihan user
                  groupValue: selectedAnswer,
                  onChanged: (value) {
                    setState(() {
                      selectedAnswer = value;
                      _userAnswers[_curIndex] = value;
                    });
                  },
                );
              }).toList(),
            ),
            // Text(q.correctAnswer),
            // Text(q.incorrectAnswers[0]),
            // const SizedBox(height: 30),
            // Text(q.incorrectAnswers[1]),
            // const SizedBox(height: 30),
            // Text(q.incorrectAnswers[2]),
            const SizedBox(height: 30),
            Row(
              children: [
                if (_curIndex > 0)
                  ElevatedButton(
                    onPressed: prevQuestion,
                    child: const Icon(Icons.arrow_back_ios),
                  ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: _curIndex < widget.questions.length - 1
                      ? nextQuestion
                      : submitQuiz,
                  child: Icon(
                    _curIndex < widget.questions.length - 1
                        ? Icons.arrow_forward_ios
                        : Icons.send,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
