// lib/views/auth/login_view.dart
import 'package:flutter/material.dart';
import 'package:quizverse/buttom_navbar.dart';
import 'package:quizverse/controllers/auth_controller.dart'; // Import AuthController (versi simpel)
import 'package:quizverse/views/auth/register_view.dart'; // Import RegisterPage
import 'package:quizverse/views/home/home_view.dart'; // Import HomePage/HomeView

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController =
      AuthController(); // Buat instance controller

  // State dikelola di dalam ViewState
  bool _isLoading = false; // Untuk loading check status awal & login
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Panggil pengecekan saat init
  }

  // Cek status login awal
  void _checkLoginStatus() async {
    setState(() {
      _isLoading = true;
    }); // Tampilkan loading awal
    try {
      bool loggedIn = await _authController.checkInitialLoginStatus();
      if (mounted) {
        if (loggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          );
        } else {
          // Tetap di halaman login jika belum login
          setState(() {
            _isLoading = false;
          }); // Sembunyikan loading awal
        }
      }
    } catch (e) {
      print("Error checking login status: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memeriksa status login.";
        });
      }
    }
  }

  // Fungsi yang dipanggil saat tombol login ditekan
  void _login() async {
    // Validasi input dasar di view
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Username dan Password tidak boleh kosong!";
      });
      return;
    }

    setState(() {
      _isLoading = true; // Mulai loading login
      _errorMessage = null; // Hapus error lama
    });

    try {
      // Panggil fungsi login di controller
      await _authController.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // Cek mounted sebelum navigasi
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
      );
    } catch (e) {
      // Tangkap error dari service/controller
      // Cek mounted sebelum setState
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString(); // Tampilkan error
      });
    } finally {
      // Cek mounted sebelum setState
      if (mounted) {
        setState(() {
          _isLoading = false;
        }); // Sembunyikan loading login
      }
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definisikan warna tema
    const Color primaryBrown = Color(0xFF3E2723);
    const Color secondaryBrown = Color(0xFF795548);
    const Color lightBrown = Color(0xFF8D6E63);
    const Color borderBrown = Color(0xFFA1887F);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          // Tampilkan loading awal atau form login
          child:
              _isLoading &&
                  _usernameController.text.isEmpty &&
                  _errorMessage ==
                      null // Cek kondisi loading awal
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: secondaryBrown),
                    SizedBox(height: 15),
                    Text("Memeriksa status login..."),
                  ],
                )
              : Column(
                  // Tampilkan form
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'quizverse Login',
                      style: TextStyle(
                        fontSize: 28,
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
                        prefixIcon: const Icon(
                          Icons.person,
                          color: secondaryBrown,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide: const BorderSide(color: borderBrown),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide: const BorderSide(
                            color: lightBrown,
                            width: 2,
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      cursorColor: lightBrown,
                      style: const TextStyle(color: primaryBrown),
                      enabled: !_isLoading, // Disable saat loading login
                    ),
                    const SizedBox(height: 16),
                    // --- Password ---
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(color: lightBrown),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: secondaryBrown,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide: const BorderSide(color: borderBrown),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide: const BorderSide(
                            color: lightBrown,
                            width: 2,
                          ),
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
                      enabled: !_isLoading, // Disable saat loading login
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
                    // --- Tombol Login ---
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Panggil fungsi _login
                      // Disable HANYA jika sedang loading login (bukan cek awal)
                      onPressed: _isLoading ? null : _login,
                      child:
                          _isLoading // Tampilkan loading kecil jika sedang proses login
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Login", style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 15),
                    // --- Tombol ke Register ---
                    TextButton(
                      // Disable jika sedang loading apapun
                      onPressed: _isLoading ? null : _goToRegister,
                      child: const Text(
                        'Belum punya akun? Daftar di sini',
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
