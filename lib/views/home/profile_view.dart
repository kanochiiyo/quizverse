import 'package:flutter/material.dart';
import 'package:quizverse/controllers/auth_controller.dart';
import 'package:quizverse/views/auth/login_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController _authController = AuthController();
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await _authController.getLoggedInUsername();
    if (mounted) {
      setState(() {
        _username = username ?? 'Pengguna';
      });
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        automaticallyImplyLeading: false,
      ),
      // Gunakan ListView agar bisa scroll jika konten bertambah
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const SizedBox(height: 20),
          // Avatar lebih besar
          CircleAvatar(
            radius: 60, // Lebih besar
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 70, // Ikon lebih besar
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Tampilkan Username
          Text(
            _username ?? 'Memuat...',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Anggota QuizVerse', // Tambahkan subtitle
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          // Tambahkan Divider
          const Divider(height: 60, thickness: 0.5, indent: 20, endIndent: 20),

          // Tombol Logout
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              // Tombol logout kita buat beda (merah)
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
