import 'package:flutter/material.dart';
import 'package:quizverse/views/auth/login_view.dart';
import 'package:timezone/data/latest.dart' as tz; 
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  try {
    // Menggunakan zona waktu sistem operasi sebagai default jika memungkinkan
    // String systemTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    // tz.setLocalLocation(tz.getLocation(systemTimeZone));
    // Jika tidak bisa atau ingin paksa WIB:
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    print("Default location set to: ${tz.local.name}"); // Debugging
  } catch (e) {
    print("Error setting default location: $e. Using default UTC.");
    // Fallback ke UTC jika gagal
    tz.setLocalLocation(tz.UTC);
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizRealm',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginView(),
    );
  }
}
