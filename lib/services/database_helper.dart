import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'quizrealm.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Buat tabel users saat database pertama kali dibuat
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        quiz_date TEXT DEFAULT CURRENT_TIMESTAMP,
        latitude REAL, 
        longitude REAL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  //  Quiz History
  Future<void> saveQuizResult({
    required int userId,
    required String category,
    required String difficulty,
    required int score,
    required int totalQuestions,
    double? latitude, 
    double? longitude,
  }) async {
    final db = await database;
    await db.insert('quiz_history', {
      'user_id': userId,
      'category': category,
      'difficulty': difficulty,
      'score': score,
      'total_questions': totalQuestions,
      'latitude': latitude,
      'longitude': longitude,
      // quiz_date akan diisi otomatis oleh DEFAULT CURRENT_TIMESTAMP
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getQuizHistory(int userId) async {
    final db = await database;
    // Ambil data diurutkan dari yang terbaru
    return await db.query(
      'quiz_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'quiz_date DESC',
    );
  }
  // Quiz History
}
