import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/word_service.dart';
import '../services/progress_service.dart';

class WordProvider with ChangeNotifier {
  List<Word> _words = [];
  bool _isLoading = true;
  Set<int> _favoriteIds = {};

  List<Word> get words => _words;
  bool get isLoading => _isLoading;
  Set<int> get favoriteIds => _favoriteIds;

  Future<void> loadWords() async {
    _isLoading = true;
    notifyListeners();

    _words = await WordService.loadWordsFromAssets();
    await _loadFavorites();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    _favoriteIds = (await ProgressService.getFavoriteWordIds()).toSet();
  }

  Future<void> toggleFavorite(int wordId) async {
    if (_favoriteIds.contains(wordId)) {
      await ProgressService.removeFromFavorites(wordId);
      _favoriteIds.remove(wordId);
    } else {
      await ProgressService.addToFavorites(wordId);
      _favoriteIds.add(wordId);
    }
    notifyListeners();
  }

  bool isFavorite(int wordId) {
    return _favoriteIds.contains(wordId);
  }

  List<Word> get favoriteWords {
    return _words.where((word) => _favoriteIds.contains(word.id)).toList();
  }

  Word? getWordById(int id) {
    return _words.firstWhere((word) => word.id == id, orElse: () => Word(
      id: 0,
      ingilizce: 'N/A',
      turkce: 'Yok',
      ornekCumle: '',
      seviye: '',
    ));
  }
}
