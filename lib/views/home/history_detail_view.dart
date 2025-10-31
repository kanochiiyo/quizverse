import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quizverse/models/quiz_model.dart';

class HistoryDetailView extends StatefulWidget {
  // Halaman ini menerima satu baris data dari tabel quiz_history
  final Map<String, dynamic> historyItem;

  const HistoryDetailView({super.key, required this.historyItem});

  @override
  State<HistoryDetailView> createState() => _HistoryDetailViewState();
}

class _HistoryDetailViewState extends State<HistoryDetailView> {
  List<QuizModel> _questions = [];
  Map<String, String?> _userAnswers = {}; // Kunci adalah String ("0", "1", dst)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _parseHistoryData();
  }

  void _parseHistoryData() {
    // Siapkan data sementara
    List<QuizModel> tempQuestions = [];
    Map<String, String?> tempAnswers = {};

    // 1. Ambil dan decode JSON pertanyaan
    final String? questionsJson = widget.historyItem['quiz_data_json'];
    if (questionsJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(questionsJson);
        tempQuestions = decodedList
            .map((item) => QuizModel.fromJson(item))
            .toList();
      } catch (e) {
        debugPrint("Gagal decode questions JSON: $e");
      }
    }

    // 2. Ambil dan decode JSON jawaban pengguna
    final String? answersJson = widget.historyItem['user_answers_json'];
    if (answersJson != null) {
      try {
        final Map<String, dynamic> decodedMap = jsonDecode(answersJson);
        tempAnswers = decodedMap.map((key, value) {
          return MapEntry(key, value as String?);
        });
      } catch (e) {
        debugPrint("Gagal decode answers JSON: $e");
      }
    }

    // 3. Panggil setState SATU KALI setelah semua data siap
    setState(() {
      _questions = tempQuestions;
      _userAnswers = tempAnswers;
      _isLoading = false; // Matikan loading
    });
  }

  // Widget helper untuk menampilkan tile jawaban
  Widget _buildAnswerTile(String answer, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(answer)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Ambil info utama dari riwayat
    final category = widget.historyItem['category'] ?? 'Detail Riwayat';
    final score = widget.historyItem['score'];
    final total = widget.historyItem['total_questions'];

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                // Ambil jawaban pengguna dari map.
                // Ingat, kuncinya sekarang adalah String ("0", "1", "2", ...)
                final userAnswer = _userAnswers[index.toString()];
                final isCorrect = userAnswer == question.correctAnswer;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pertanyaan ${index + 1} dari ${total ?? _questions.length}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.question,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tampilkan jawaban pengguna
                        Text(
                          "Jawaban Anda:",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (userAnswer == null)
                          _buildAnswerTile(
                            "(Tidak dijawab)",
                            Colors.grey,
                            Icons.help_outline,
                          )
                        else if (isCorrect)
                          _buildAnswerTile(
                            userAnswer,
                            Colors.green,
                            Icons.check_circle_outline,
                          )
                        else
                          _buildAnswerTile(
                            userAnswer,
                            Colors.red,
                            Icons.cancel_outlined,
                          ),

                        // Tampilkan jawaban yang benar (jika jawaban pengguna salah DAN tidak kosong)
                        if (!isCorrect && userAnswer != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            "Jawaban Benar:",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildAnswerTile(
                            question.correctAnswer,
                            Colors.green,
                            Icons.check_circle_outline,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
