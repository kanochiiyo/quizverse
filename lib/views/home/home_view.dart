import 'package:flutter/material.dart';
import 'package:quizverse/controllers/quiz_controller.dart';
import 'package:quizverse/models/quiz_model.dart';
import 'package:quizverse/views/home/quiz_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final QuizController _controller = QuizController();

  // default pilihan user
  String selectedCategory = '9'; // General Knowledge
  String selectedDifficulty = 'easy';
  int selectedAmount = 10;

  bool isLoading = false;

  // list kategori dari API (static dulu)
  final List<Map<String, String>> categories = [
    {'id': '9', 'name': 'General Knowledge'},
    {'id': '11', 'name': 'Entertainment: Film'},
    {'id': '12', 'name': 'Entertainment: Music'},
    {'id': '17', 'name': 'Science & Nature'},
    {'id': '21', 'name': 'Sports'},
    {'id': '31', 'name': 'Entertaintment: Japanese Anime & Manga'},
    {'id': '19', 'name': 'Science: Mathematics'},
  ];

  final List<Map<String, String>> difficulties = [
    {'id': 'easy', 'name': 'Mudah'},
    {'id': 'medium', 'name': 'Sedang'},
    {'id': 'hard', 'name': 'Sulit'},
  ];

  final List<int> amountOptions = [5, 10, 15, 20];

  Future<void> startQuiz() async {
    setState(() => isLoading = true);
    try {
      List<QuizModel> questions = await _controller.loadQuestions(
        amount: selectedAmount,
        category: selectedCategory,
        difficulty: selectedDifficulty,
      );

      debugPrint('GET DATA SUCCESS: GOT ${questions.length} QUESTIONS!');

      if (!mounted)
        return; // kalo widgetnya dah ilang duluan padahal blm selesai load
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizView(questions: questions)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('GET DATA FAILED: $e')));
    } finally {
      // Hanya set isLoading = false jika widget masih ada
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Trivia Quiz'), centerTitle: true),
      // Kita pakai ListView agar bisa di-scroll jika layar kecil
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Kategori ---
            const Text('Kategori'),
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat['id'],
                  child: Text(cat['name']!),
                );
              }).toList(),
              // Nonaktifkan saat loading
              onChanged: isLoading
                  ? null
                  : (val) {
                      setState(() => selectedCategory = val!);
                    },
            ),
            const SizedBox(height: 20),

            // --- Kesulitan ---
            const Text('Kesulitan'),
            DropdownButton<String>(
              value: selectedDifficulty,
              isExpanded: true,
              items: difficulties.map((diff) {
                return DropdownMenuItem(
                  value: diff['id']!,
                  child: Text(diff['name']!),
                );
              }).toList(),
              // Nonaktifkan saat loading
              onChanged: isLoading
                  ? null
                  : (val) {
                      setState(() => selectedDifficulty = val!);
                    },
            ),
            const SizedBox(height: 20),

            // --- Jumlah Soal (DIGANTI DARI SLIDER) ---
            const Text('Jumlah Soal'),
            DropdownButton<int>(
              value: selectedAmount, // Tipe datanya <int>
              isExpanded: true,
              items: amountOptions.map((amount) {
                // Pakai list baru
                return DropdownMenuItem(
                  value: amount,
                  child: Text('$amount soal'),
                );
              }).toList(),
              // Nonaktifkan saat loading
              onChanged: isLoading
                  ? null
                  : (val) {
                      setState(() => selectedAmount = val!);
                    },
            ),
            const SizedBox(height: 30),

            // --- Tombol Mulai ---
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                onPressed: isLoading ? null : startQuiz,
                child: isLoading
                    ? const SizedBox(
                        height: 20, // Beri ukuran agar rapi
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, // Warna indicator
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('Mulai Kuis'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
