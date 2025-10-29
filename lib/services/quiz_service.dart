import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizverse/models/quiz_model.dart';

class QuizService {
  Future<List<QuizModel>> fetchQuizData({
    required int amount,
    required String category,
    required String difficulty,
  }) async {
    final baseUrl = 'https://opentdb.com';
    // format URL Open Trivia DB
    final url = Uri.parse(
      '$baseUrl/api.php?amount=$amount&category=$category&difficulty=$difficulty&type=multiple',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['response_code'] == 0) {
        List questions = data['results'];
        return questions.map((v) => QuizModel.fromJson(v)).toList();
      } else {
        throw Exception('No questions found for these settings');
      }
    } else {
      throw Exception('FETCH API FALIED!');
    }
  }
}
