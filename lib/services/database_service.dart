import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'quizverse.db');

    // Tetap di versi 1, tidak perlu onUpgrade
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
        duration INTEGER NOT NULL,
        quiz_date TEXT DEFAULT CURRENT_TIMESTAMP,
        latitude REAL, 
        longitude REAL,
        address TEXT,
        quiz_data_json TEXT,
        user_answers_json TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  //  Quiz History
  Future<int> saveQuizResult({
    required int userId,
    required String category,
    required String difficulty,
    required int score,
    required int duration,
    required int totalQuestions,
    double? latitude,
    double? longitude,
    String? address,
    String? quizDataJson,
    String? userAnswersJson,
  }) async {
    final db = await database;

    // Kita return ID dari data yang baru di-insert
    return await db.insert('quiz_history', {
      'user_id': userId,
      'category': category,
      'difficulty': difficulty,
      'score': score,
      'duration': duration,
      'total_questions': totalQuestions,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'quiz_data_json': quizDataJson,
      'user_answers_json': userAnswersJson,
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

  Future<Map<String, dynamic>?> getHistoryItemById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quiz_history',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}
