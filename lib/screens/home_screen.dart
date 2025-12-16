import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../screens/word_detail_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/stats_screen.dart';
import '../services/progress_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FlutterTts flutterTts;
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    // Günlük aktiviteyi kaydet
    ProgressService.recordDailyActivity();
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final wordProvider = context.watch<WordProvider>();
    final allWords = wordProvider.words;
    final favoriteWords = wordProvider.favoriteWords;
    final wordsToShow = _showFavoritesOnly ? favoriteWords : allWords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Öğrenme',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
            tooltip: _showFavoritesOnly ? 'Tüm kelimeleri göster' : 'Sadece favorileri göster',
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'İstatistikler',
            onPressed: () => Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (_, __, ___) => const StatsScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.quiz),
            tooltip: 'Quiz',
            onPressed: () => Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (_, __, ___) => const QuizScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (_showFavoritesOnly)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showFavoritesOnly = false;
                    });
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Tüm Kelimelere Dön'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (_showFavoritesOnly && favoriteWords.isEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz favori kelime yok',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kelime detayından favorilere ekleyebilirsiniz',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  itemCount: wordsToShow.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemBuilder: (context, index) {
                    final word = wordsToShow[index];
                    final isFavorite = wordProvider.isFavorite(word.id);
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 600),
                            pageBuilder: (_, __, ___) =>
                                WordDetailScreen(word: word),
                            transitionsBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(word.ingilizce,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        if (isFavorite)
                                          const Icon(
                                            Icons.favorite,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(word.turkce,
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up),
                                onPressed: () => _speak(word.ingilizce),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => const QuizScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        label: const Text('Quiz Yap'),
        icon: const Icon(Icons.quiz),
      ),
    );
  }
}
