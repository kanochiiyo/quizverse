import 'package:flutter/material.dart';
import 'package:quizverse/controllers/auth_controller.dart'; // Import AuthController
import 'package:quizverse/views/auth/login_view.dart'; // Import LoginView untuk navigasi setelah logout

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController _authController = AuthController();
  String? _username;
  // Tambahkan state untuk path gambar profil jika diperlukan
  // String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    // Tambahkan fungsi untuk load gambar profil jika ada
  }

  Future<void> _loadUsername() async {
    final username = await _authController.getLoggedInUsername();
    if (mounted) {
      setState(() {
        _username = username ?? 'Pengguna'; // Default jika null
      });
    }
  }

  Future<void> _logout() async {
    // Tampilkan dialog konfirmasi sebelum logout
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Batal
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Ya, logout
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Jika user konfirmasi logout
    if (confirmLogout == true) {
      try {
        await _authController.logout();
        if (mounted) {
          // Navigasi kembali ke halaman Login dan hapus semua halaman sebelumnya
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginView()),
            (Route<dynamic> route) => false, // Hapus semua route
          );
        }
      } catch (e) {
        // Handle error jika logout gagal (meskipun jarang terjadi)
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        automaticallyImplyLeading: false, // Hilangkan tombol back default
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Placeholder Gambar Profil
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                // Tampilkan gambar jika ada, jika tidak, tampilkan ikon
                // backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                child: /*_profileImagePath == null ?*/ Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey[600],
                ) /*: null*/,
              ),
              const SizedBox(height: 20),

              // Tampilkan Username
              Text(
                _username ??
                    'Memuat...', // Tampilkan 'Memuat...' saat username belum ada
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 40),

              // Tombol Logout
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Warna tombol logout
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
