// Nama file: lib/bottom_navbar.dart

import 'package:flutter/material.dart';
// Import halaman-halaman yang akan ditampilkan
import 'package:quizverse/views/home/home_view.dart';
import 'package:quizverse/views/home/history_view.dart'; // Pastikan file ini ada
import 'package:quizverse/views/home/profile_view.dart'; // Pastikan file ini ada
import 'package:quizverse/views/home/about_view.dart'; // Pastikan file ini ada

// Ubah nama class dari MainScreen menjadi BottomNavBar
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

// Ubah nama state class
class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0; // Indeks halaman yang aktif

  // Daftar halaman/widget yang akan ditampilkan (tetap sama)
  static const List<Widget> _widgetOptions = <Widget>[
    HomeView(), // Indeks 0: Halaman utama (kuis)
    HistoryPage(), // Indeks 1: Halaman riwayat
    ProfilePage(), // Indeks 2: Halaman profil
    AboutPage(), // Indeks 3: Halaman tentang/saran
  ];

  // Fungsi yang dipanggil saat item navigasi ditekan (tetap sama)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update indeks halaman aktif
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body menampilkan widget sesuai _selectedIndex (tetap sama)
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      // Bottom Navigation Bar (tetap sama)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Tentang',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
