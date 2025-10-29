import 'package:flutter/material.dart';
import 'package:quizverse/controllers/quiz_controller.dart';
import 'package:quizverse/models/quiz_model.dart';
import 'package:quizverse/views/home/quiz_view.dart';
// Import service konversi
import 'package:quizverse/services/conversion_service.dart';
// Import intl jika belum ada, untuk NumberFormat (opsional, tergantung service)
// import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final QuizController _controller = QuizController();
  // Buat instance ConversionService
  final ConversionService _conversionService = ConversionService();

  // default pilihan user
  String selectedCategory = '9'; // General Knowledge
  String selectedDifficulty = 'easy';
  int selectedAmount = 10;

  bool isLoading = false; // Loading untuk proses 'Mulai Kuis'

  // Today Fact
  String? dailyFact; // Menyimpan teks fakta
  bool isLoadingFact = true; // Status loading untuk fakta
  String factError = ''; // Menyimpan pesan error jika gagal load fakta

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

  @override
  void initState() {
    super.initState();
    // Fakta hanya akan diperbarui setiap kali halaman HomeView() dibuat ulang dari awal. 
    // Antara setelah login atau aplikasinya diclose
    _loadDailyFact(); 
  }

  Future<void> _loadDailyFact() async {
    if (!mounted) return;
    setState(() {
      isLoadingFact = true; // Mulai loading
      factError = ''; // Hapus error sebelumnya
    });

    try {
      // Panggil fungsi getRandomFact dari service
      final fact = await _conversionService.getRandomFact();
      // Jika widget masih terpasang, update state dengan fakta baru
      if (mounted) {
        setState(() {
          dailyFact = fact;
          isLoadingFact = false; // Selesai loading
        });
      }
    } catch (e) {
      // Jika terjadi error saat mengambil fakta
      if (mounted) {
        setState(() {
          // Simpan pesan error untuk ditampilkan
          factError = e.toString().replaceFirst("Exception: ", "");
          dailyFact = null; // Pastikan tidak ada fakta lama yang ditampilkan
          isLoadingFact = false; // Selesai loading (meskipun error)
        });
      }
    }
  }

  Future<void> startQuiz() async {
    // --- Fungsi Lama: Memulai Kuis ---
    setState(() => isLoading = true); // Mulai loading untuk kuis
    try {
      List<QuizModel> questions = await _controller.loadQuestions(
        amount: selectedAmount,
        category: selectedCategory,
        difficulty: selectedDifficulty,
      );

      debugPrint('GET DATA SUCCESS: GOT ${questions.length} QUESTIONS!');

      if (!mounted)
        return; // kalo widgetnya dah ilang duluan padahal blm selesai load
      // Navigasi ke halaman kuis dengan data pertanyaan
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizView(questions: questions)),
      );
    } catch (e) {
      // Jika gagal memuat pertanyaan kuis
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('GET DATA FAILED: $e')));
    } finally {
      // Hanya set isLoading = false jika widget masih ada
      if (mounted) {
        setState(() => isLoading = false); // Selesai loading kuis
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuizVerse'),
        centerTitle: true,
      ), // Judul AppBar
      // Bungkus dengan SingleChildScrollView agar bisa discroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Dropdown jadi full width
          children: [
            // --- Kategori ---
            const Text('Kategori'),
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true, //Dropdown jadi full width
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat['id'],
                  child: Text(cat['name']!),
                );
              }).toList(),
              // Nonaktifkan dropdown saat loading kuis ATAU loading fakta
              onChanged: isLoading || isLoadingFact
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
              // Nonaktifkan dropdown saat loading kuis ATAU loading fakta
              onChanged: isLoading || isLoadingFact
                  ? null
                  : (val) {
                      setState(() => selectedDifficulty = val!);
                    },
            ),
            const SizedBox(height: 20),

            // --- Jumlah Soal ---
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
              // Nonaktifkan dropdown saat loading kuis ATAU loading fakta
              onChanged: isLoading || isLoadingFact
                  ? null
                  : (val) {
                      setState(() => selectedAmount = val!);
                    },
            ),
            const SizedBox(height: 30),

            // --- Widget Fakta Hari Ini ---
            _buildDailyFactWidget(), // Panggil widget untuk menampilkan fakta
            const SizedBox(height: 30),

            // --- Tombol Mulai ---
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ), // Ukuran teks tombol
                ),
                // Nonaktifkan tombol saat loading kuis ATAU loading fakta
                onPressed: isLoading || isLoadingFact ? null : startQuiz,
                child:
                    isLoading // Tampilkan indikator loading jika isLoading true
                    ? const SizedBox(
                        height: 20, // Beri ukuran agar rapi
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, // Warna indicator
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Mulai Kuis',
                      ), // Teks tombol jika tidak loading
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Baru: Membangun Tampilan Fakta Hari Ini ---
  Widget _buildDailyFactWidget() {
    Widget content; // Widget yang akan ditampilkan di dalam Card

    if (isLoadingFact) {
      // Tampilan saat loading fakta
      content = const Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ), // Indikator loading kecil
            SizedBox(width: 15),
            Text(
              "Memuat fakta menarik...",
              style: TextStyle(color: Colors.grey),
            ), // Teks loading
          ],
        ),
      );
    } else if (factError.isNotEmpty) {
      // Tampilan jika terjadi error saat load fakta
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[700],
              size: 20,
            ), // Ikon warning
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                factError,
                style: TextStyle(color: Colors.orange[800]),
              ),
            ), // Tampilkan pesan error
            IconButton(
              // Tombol untuk mencoba load fakta lagi
              icon: Icon(Icons.refresh, color: Colors.grey[600]),
              iconSize: 22,
              tooltip: "Coba lagi", // Teks saat hover
              onPressed: _loadDailyFact, // Panggil fungsi load fakta lagi
              splashRadius: 20, // Efek saat ditekan
            ),
          ],
        ),
      );
    } else if (dailyFact != null) {
      // Tampilan jika fakta berhasil dimuat
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Ratakan teks ke kiri
          children: [
            const Text(
              "💡 Fakta Hari Ini:", // Judul bagian fakta
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigoAccent,
              ), // Styling judul
            ),
            const SizedBox(height: 6),
            Text(
              dailyFact!,
              style: TextStyle(color: Colors.black87),
            ), // Tampilkan teks fakta
          ],
        ),
      );
    } else {
      // Jika tidak loading, tidak error, tapi fakta = null (sebagai fallback)
      content = const SizedBox.shrink(); // Tampilkan widget kosong
    }

    // Bungkus konten dengan Card untuk tampilan yang lebih rapi
    return Card(
      elevation: 1.5, // Sedikit bayangan
      margin: const EdgeInsets.symmetric(vertical: 10.0), // Jarak atas-bawah
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Sudut melengkung
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 0.5,
        ), // Border tipis (opsional)
      ),
      child: content, // Masukkan widget konten yang sudah dibuat di atas
    );
  }
}
