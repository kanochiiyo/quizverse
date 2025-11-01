import 'package:flutter/material.dart';
import 'package:quizverse/controllers/auth_controller.dart';
import 'package:quizverse/views/auth/login_view.dart';
import 'package:quizverse/services/database_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController _authController = AuthController();
  final DatabaseService _databaseService = DatabaseService();
  String? _username;
  bool _isLoadingStats = true;
  int _totalQuizzes = 0;
  String _avgScoreString = "0%";
  String _timePlayedString = "0m";

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadStats();
  }

  Future<void> _loadUsername() async {
    final username = await _authController.getLoggedInUsername();
    if (mounted) {
      setState(() {
        _username = username ?? 'Pengguna';
      });
    }
  }

  Future<void> _loadStats() async {
    if (mounted) setState(() => _isLoadingStats = true);

    try {
      final String? userIdString = await _authController.getLoggedInUserId();
      if (userIdString == null) return;

      final history = await _databaseService.getQuizHistory(
        int.parse(userIdString),
      );
      if (!mounted) return;

      if (history.isEmpty) {
        setState(() {
          _isLoadingStats = false;
        });
        return;
      }

      // Hitung berdasarkan ada berapa data history quiz
      final totalQuizzes = history.length;
      // Hitung berdasarkan durasi di tiap data history quiz
      final totalDurationSeconds = history.fold<int>(
        0,
        (sum, item) => sum + (item['duration'] as int? ?? 0),
      );
      final duration = Duration(seconds: totalDurationSeconds);

      String timePlayed;
      if (duration.inHours > 0) {
        timePlayed =
            "${duration.inHours}j ${duration.inMinutes.remainder(60)}m";
      } else {
        timePlayed = "${duration.inMinutes}m";
      }

      int totalScore = 0;
      int totalQuestions = 0;

      for (var item in history) {
        totalScore += (item['score'] as int? ?? 0);
        // Hitung berapa skor yang didapat dari tiap data
        // Hitung berapa soal yang dikerjakan dari tiap data
        totalQuestions += (item['total_questions'] as int? ?? 0);
      }

      // Hitung rata-ratanya dan jadikan persen
      final avgScore = (totalQuestions > 0)
          ? (totalScore / totalQuestions) * 100
          : 0.0;
      final avgScoreString = "${avgScore.toStringAsFixed(0)}%";

      setState(() {
        _totalQuizzes = totalQuizzes;
        _timePlayedString = timePlayed;
        _avgScoreString = avgScoreString;
        _isLoadingStats = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
      debugPrint("Gagal load stats: $e");
    }
  }

  Future<void> _logout() async {
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      try {
        await _authController.logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginView()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
        }
      }
    }
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        color: color.withAlpha(26),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withAlpha(77)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
              Text(
                _isLoadingStats ? "..." : value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Statistik Kuis",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              context,
              icon: Icons.quiz,
              label: "Total Kuis",
              value: _totalQuizzes.toString(),
              color: theme.primaryColor,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              context,
              icon: Icons.check_circle_outline,
              label: "Rata-rata Skor",
              value: _avgScoreString,
              color: Colors.amber.shade800,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              context,
              icon: Icons.timer,
              label: "Waktu Bermain",
              value: _timePlayedString,
              color: Colors.blue.shade700,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        automaticallyImplyLeading: false,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const SizedBox(height: 20),

          CircleAvatar(
            radius: 60,
            backgroundColor: theme.primaryColor.withAlpha(26),
            child: Icon(Icons.person, size: 70, color: theme.primaryColor),
          ),
          const SizedBox(height: 16),

          Text(
            _username ?? 'Memuat...',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),
          _buildStatsSection(context),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _logout,
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
