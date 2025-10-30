// lib/views/auth/login_view.dart
import 'package:flutter/material.dart';
import 'package:quizverse/buttom_navbar.dart';
import 'package:quizverse/controllers/auth_controller.dart';
import 'package:quizverse/views/auth/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = AuthController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    setState(() {
      _isLoading = true;
    });
    try {
      bool loggedIn = await _authController.checkInitialLoginStatus();
      if (mounted) {
        if (loggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
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

  void _login() async {
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Username dan Password tidak boleh kosong!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authController.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
    // Ambil warna dari Tema, BUKAN define lokal
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Tampilan loading awal yang lebih bersih
    if (_isLoading &&
        _usernameController.text.isEmpty &&
        _errorMessage == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 15),
              const Text("Memeriksa status login..."),
            ],
          ),
        ),
      );
    }

    // Tampilan Form Login
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Beri padding lebih
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tambahkan Ikon
              Icon(
                Icons.quiz, // Ikon kuis
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'QuizVerse Login', // Ganti nama agar konsisten
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // --- Username ---
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  prefixIcon: Icon(Icons.person),
                ),
                // Style dan border diambil dari tema global
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              // --- Password ---
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
              // --- Error Message ---
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: colorScheme.error, // Gunakan warna error dari tema
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              // --- Tombol Login ---
              ElevatedButton(
                // Style diambil dari tema global
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Login"),
              ),
              const SizedBox(height: 16),
              // --- Tombol ke Register ---
              TextButton(
                onPressed: _isLoading ? null : _goToRegister,
                child: Text(
                  'Belum punya akun? Daftar di sini',
                  style: TextStyle(color: colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
