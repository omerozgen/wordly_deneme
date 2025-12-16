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

  // Favori metodları
  static Future<void> addToFavorites(int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favoriteWords') ?? [];
    if (!favorites.contains(wordId.toString())) {
      favorites.add(wordId.toString());
      await prefs.setStringList('favoriteWords', favorites);
    }
  }

  static Future<void> removeFromFavorites(int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favoriteWords') ?? [];
    favorites.remove(wordId.toString());
    await prefs.setStringList('favoriteWords', favorites);
  }

  static Future<List<int>> getFavoriteWordIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('favoriteWords') ?? []).map(int.parse).toList();
  }

  static Future<bool> isFavorite(int wordId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favoriteWords') ?? [];
    return favorites.contains(wordId.toString());
  }

  // Günlük aktivite ve streak metodları
  static Future<void> recordDailyActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD formatı
    List<String> activityDates = prefs.getStringList('activityDates') ?? [];
    
    if (!activityDates.contains(today)) {
      activityDates.add(today);
      await prefs.setStringList('activityDates', activityDates);
    }
  }

  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activityDates = prefs.getStringList('activityDates') ?? [];
    
    if (activityDates.isEmpty) return 0;
    
    // Tarihleri sırala
    activityDates.sort();
    
    // Bugünün tarihini al
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    
    // Bugün aktivite varsa streak'i hesapla
    if (!activityDates.contains(todayStr)) {
      // Bugün aktivite yoksa, dün kontrol et
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr = yesterday.toIso8601String().split('T')[0];
      if (!activityDates.contains(yesterdayStr)) {
        return 0; // Dün de yoksa streak kırılmış
      }
    }
    
    // Streak'i geriye doğru say
    int streak = 0;
    DateTime currentDate = today;
    
    while (true) {
      final dateStr = currentDate.toIso8601String().split('T')[0];
      if (activityDates.contains(dateStr)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  static Future<int> getTotalActivityDays() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activityDates = prefs.getStringList('activityDates') ?? [];
    return activityDates.length;
  }

  static Future<List<String>> getActivityDates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('activityDates') ?? [];
  }

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('learnedWords');
    await prefs.remove('quizCorrectCount');
    await prefs.remove('quizWrongCount');
    await prefs.remove('activityDates');
    await prefs.remove('favoriteWords');
  }
}
