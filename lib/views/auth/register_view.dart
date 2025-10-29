// lib/views/auth/register_page.dart
import 'package:flutter/material.dart';
import 'package:quizverse/controllers/auth_controller.dart'; 

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthController _authController =
      AuthController(); // Instance controller

  // State dikelola di ViewState
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Fungsi yang dipanggil saat tombol Register ditekan
  void _register() async {
    // Hapus pesan error sebelumnya
    setState(() {
      _errorMessage = null;
    });

    // Validasi input di view
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "Semua field harus diisi!";
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Konfirmasi password tidak cocok!";
      });
      return;
    }
    if (password.length < 6) {
      // Validasi panjang password
      setState(() {
        _errorMessage = "Password minimal 6 karakter!";
      });
      return;
    }

    // Mulai loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil fungsi register di controller
      await _authController.register(username: username, password: password);

      // Cek mounted sebelum interaksi context/navigasi
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green, // Feedback positif
        ),
      );
      Navigator.pop(context); // Kembali ke login setelah berhasil
    } catch (e) {
      // Tangkap error dari service/controller
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString(); // Tampilkan error
      });
    } finally {
      // Pastikan setState dipanggil hanya jika widget masih ada
      if (mounted) {
        setState(() {
          _isLoading = false;
        }); // Sembunyikan loading
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definisikan warna tema
    const Color primaryBrown = Color(0xFF3E2723);
    const Color secondaryBrown = Color(0xFF795548);
    const Color lightBrown = Color(0xFF8D6E63);
    const Color borderBrown = Color(0xFFA1887F);

    return Scaffold(
      // AppBar agar ada tombol kembali otomatis
      appBar: AppBar(
        title: const Text('Buat Akun QuizRealm'),
        backgroundColor: primaryBrown, // Sesuaikan warna AppBar
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Registrasi Akun Baru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBrown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // --- Username ---
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: const TextStyle(color: lightBrown),
                  prefixIcon: const Icon(Icons.person, color: secondaryBrown),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: const BorderSide(color: borderBrown),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: const BorderSide(color: lightBrown, width: 2),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                cursorColor: lightBrown,
                style: const TextStyle(color: primaryBrown),
                enabled: !_isLoading, // Disable saat loading
              ),
              const SizedBox(height: 16),
              // --- Password ---
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: lightBrown),
                  prefixIcon: const Icon(Icons.lock, color: secondaryBrown),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: const BorderSide(color: borderBrown),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: const BorderSide(color: lightBrown, width: 2),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: secondaryBrown,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                cursorColor: lightBrown,
                style: const TextStyle(color: primaryBrown),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              // --- Confirm Password ---
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Konfirmasi Password",
                  labelStyle: const TextStyle(color: lightBrown),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: secondaryBrown,
                  ), // Icon berbeda sedikit
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: const BorderSide(color: borderBrown),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    borderSide: const BorderSide(color: lightBrown, width: 2),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: secondaryBrown,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                cursorColor: lightBrown,
                style: const TextStyle(color: primaryBrown),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              // --- Error Message ---
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              // --- Tombol Register ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Panggil _register saat ditekan
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Register", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 15),
              // --- Tombol Kembali ke Login ---
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.pop(context), // Kembali ke login
                child: const Text(
                  'Sudah punya akun? Login di sini',
                  style: TextStyle(color: secondaryBrown),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
