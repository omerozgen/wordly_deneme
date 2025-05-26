import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word_model.dart';

class WordService {
  /// JSON dosyasından kelime listesini yükler
  static Future<List<Word>> loadWordsFromAssets() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/wordly_words_a1.json');

    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((json) => Word.fromJson(json)).toList();
  }
}
