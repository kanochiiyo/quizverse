import 'package:flutter/material.dart';
import 'package:quizverse/models/quiz_model.dart';

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

  @override
  void initState() {
    super.initState();
    // Pertama kali widget dibuat langsung panggil _setupQuestion
    _setupQuestion();
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

  void submitQuiz() {
    int score = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (_userAnswers[i] == widget.questions[i].correctAnswer) {
        score++;
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
