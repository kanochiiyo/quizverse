import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quizverse/views/auth/login_view.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:quizverse/services/notification_service.dart';
import 'package:quizverse/services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  tz.initializeTimeZones();
  Intl.defaultLocale = 'id_ID';

  try {
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    print("Default location set to: ${tz.local.name}");
  } catch (e) {
    print("Error setting default location: $e. Using default UTC.");
    tz.setLocalLocation(tz.UTC);
  }

  // Inisialisasi Notifikasi (Anda sudah punya ini)
  await NotificationService().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00695C);
    const Color lightPrimaryColor = Color(0xFF00897B);
    const Color accentColor = Color(0xFF4DB6AC);
    const Color backgroundColor = Color(0xFFF5F5F5);

    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'QuizVerse',
      theme: ThemeData(
        fontFamily: 'Inter',
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
          background: backgroundColor,
          error: Colors.redAccent,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20, // Ukuran font default AppBar
            fontWeight: FontWeight.w600, // Semi-bold
          ),
        ),

        // Tema untuk Tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Tema untuk Input Field (Login/Register)
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.black54),
          prefixIconColor: lightPrimaryColor,
          suffixIconColor: lightPrimaryColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),

        // Tema untuk Bottom Nav Bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),

        useMaterial3: true,
      ),
      home: LoginView(),
    );
  }
}
