// lib/views/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:quizverse/controllers/quiz_controller.dart';
import 'package:quizverse/models/quiz_model.dart';
import 'package:quizverse/models/category_model.dart';
import 'package:quizverse/views/home/quiz_view.dart';
import 'package:quizverse/services/conversion_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final QuizController _controller = QuizController();
  final ConversionService _conversionService = ConversionService();

  // Ini sudah benar (nullable)
  String? selectedCategory;
  bool isLoadingCategories = true;
  String? categoryError;
  List<CategoryModel> categories = [];

  String selectedDifficulty = 'easy';
  int selectedAmount = 10;

  bool isLoading = false;
  String? dailyFact;
  bool isLoadingFact = true;
  String factError = '';

  final List<Map<String, String>> difficulties = [
    {'id': 'easy', 'name': 'Mudah'},
    {'id': 'medium', 'name': 'Sedang'},
    {'id': 'hard', 'name': 'Sulit'},
  ];

  final List<int> amountOptions = [5, 10, 15, 20];

  @override
  void initState() {
    super.initState();

    _loadDailyFact();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    setState(() {
      isLoadingCategories = true;
      categoryError = null;
    });

    try {
      final fetchedCategories = await _controller.loadCategories();
      if (!mounted) return;
      setState(() {
        categories = fetchedCategories;

        if (categories.isNotEmpty) {
          selectedCategory = categories.first.id.toString();
        }
        isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        categoryError = e.toString().replaceFirst("Exception: ", "");
        isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadDailyFact() async {
    if (!mounted) return;
    setState(() {
      isLoadingFact = true;
      factError = '';
    });

    try {
      final fact = await _conversionService.getRandomFact();
      if (mounted) {
        setState(() {
          dailyFact = fact;
          isLoadingFact = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          factError = e.toString().replaceFirst("Exception: ", "");
          dailyFact = null;
          isLoadingFact = false;
        });
      }
    }
  }

  Future<void> startQuiz() async {
    // Pengecekan ini sudah benar
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih kategori terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      List<QuizModel> questions = await _controller.loadQuestions(
        amount: selectedAmount,
        category: selectedCategory!, // '!' aman di sini karena sudah dicek null
        difficulty: selectedDifficulty,
      );

      debugPrint('GET DATA SUCCESS: GOT ${questions.length} QUESTIONS!');

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizView(questions: questions)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat kuis: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildDropdownContainer<T>({
    required String label,
    // --- PERBAIKAN DI SINI ---
    required T? value, // Tambahkan '?' untuk mengizinkan nilai null
    // --- SELESAI PERBAIKAN ---
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    bool disabled = false,
  }) {
    Widget dropdownWidget;

    if (items.isEmpty) {
      String text = "Memuat...";
      if (categoryError != null) text = "Gagal memuat";
      if (disabled) text = "-";

      dropdownWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    } else {
      dropdownWidget = DropdownButton<T>(
        value: value,
        isExpanded: true,
        items: items,
        onChanged: disabled ? null : onChanged,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: disabled ? Colors.grey : Theme.of(context).primaryColor,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: disabled ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: disabled ? Colors.grey : Colors.black54,
            ),
          ),
          dropdownWidget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverallLoading =
        isLoading || isLoadingFact || isLoadingCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mulai Kuis Baru'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdownContainer<String>(
              label: 'Pilih Kategori',
              value: selectedCategory, // value sekarang (String?)
              items: categoryError != null
                  ? []
                  : categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id.toString(),
                        child: Text(
                          cat.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
              onChanged: (val) {
                setState(() => selectedCategory = val!);
              },
              disabled: isOverallLoading,
            ),
            if (categoryError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Row(
                  children: [
                    Text(
                      categoryError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      onPressed: _loadCategories,
                      splashRadius: 16,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _buildDropdownContainer<String>(
              label: 'Pilih Kesulitan',
              value: selectedDifficulty, // value (String)
              items: difficulties.map((diff) {
                return DropdownMenuItem(
                  value: diff['id']!,
                  child: Text(
                    diff['name']!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedDifficulty = val!);
              },
              disabled: isOverallLoading,
            ),
            const SizedBox(height: 16),
            _buildDropdownContainer<int>(
              label: 'Pilih Jumlah Soal',
              value: selectedAmount, // value (int)
              items: amountOptions.map((amount) {
                return DropdownMenuItem(
                  value: amount,
                  child: Text(
                    '$amount soal',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedAmount = val!);
              },
              disabled: isOverallLoading,
            ),
            const SizedBox(height: 24),
            _buildDailyFactWidget(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isOverallLoading ? null : startQuiz,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('Mulai Kuis'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyFactWidget() {
    final theme = Theme.of(context);
    Widget content;

    if (isLoadingFact) {
      content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              "Memuat fakta menarik...",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    } else if (factError.isNotEmpty) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                factError,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.grey[600]),
              iconSize: 22,
              tooltip: "Coba lagi",
              onPressed: _loadDailyFact,
              splashRadius: 20,
            ),
          ],
        ),
      );
    } else if (dailyFact != null) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "💡 Fakta Hari Ini:",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dailyFact!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    } else {
      content = const SizedBox.shrink();
    }

    return Card(color: Colors.white, child: content);
  }
}
