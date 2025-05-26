import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/word_service.dart';

class WordProvider with ChangeNotifier {
  List<Word> _words = [];
  bool _isLoading = true;

  List<Word> get words => _words;
  bool get isLoading => _isLoading;

  Future<void> loadWords() async {
    _isLoading = true;
    notifyListeners();

    _words = await WordService.loadWordsFromAssets();

    _isLoading = false;
    notifyListeners();
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
