import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_model.dart';
import '../providers/word_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Word> _words;
  late Word _currentWord;
  late List<String> _options;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _words = context.read<WordProvider>().words;
    _loadNewQuestion();
  }

  void _loadNewQuestion() {
    final random = Random();
    _currentWord = _words[random.nextInt(_words.length)];

    final allTranslations = _words.map((e) => e.turkce).toList();
    allTranslations.shuffle();

    _options = allTranslations
        .where((turkce) => turkce != _currentWord.turkce)
        .take(3)
        .toList()
      ..add(_currentWord.turkce)
      ..shuffle();

    setState(() {});
  }

  void _checkAnswer(String selected) {
    final isCorrect = selected == _currentWord.turkce;
    final message = isCorrect ? 'Doğru!' : 'Yanlış. Doğru cevap: ${_currentWord.turkce}';

    if (isCorrect) _score++;

    showDialog(
      context: context,
      builder: (_) => FadeTransition(
        opacity: CurvedAnimation(parent: ModalRoute.of(context)!.animation!, curve: Curves.easeIn),
        child: AlertDialog(
          title: Text(isCorrect ? '✔️' : '❌'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadNewQuestion();
              },
              child: const Text('Sonraki'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(child: Text('Puan: $_score')),
          )
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Padding(
          key: ValueKey(_currentWord.id),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anlamı nedir?',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _currentWord.ingilizce,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ),
              const SizedBox(height: 24),
              ..._options.map((option) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _checkAnswer(option),
                      child: Text(option, style: const TextStyle(fontSize: 16)),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}



