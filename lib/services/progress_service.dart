import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static Future<void> markWordAsLearned(int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> learned = prefs.getStringList('learnedWords') ?? [];
    if (!learned.contains(wordId.toString())) {
      learned.add(wordId.toString());
      await prefs.setStringList('learnedWords', learned);
    }
  }

  static Future<List<int>> getLearnedWordIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('learnedWords') ?? []).map(int.parse).toList();
  }

  static Future<void> incrementCorrectAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('quizCorrectCount') ?? 0;
    await prefs.setInt('quizCorrectCount', count + 1);
  }

  static Future<void> incrementWrongAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('quizWrongCount') ?? 0;
    await prefs.setInt('quizWrongCount', count + 1);
  }

  static Future<Map<String, int>> getQuizStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'correct': prefs.getInt('quizCorrectCount') ?? 0,
      'wrong': prefs.getInt('quizWrongCount') ?? 0,
    };
  }

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('learnedWords');
    await prefs.remove('quizCorrectCount');
    await prefs.remove('quizWrongCount');
  }
}
