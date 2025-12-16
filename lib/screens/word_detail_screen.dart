import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../models/word_model.dart';
import '../providers/word_provider.dart';

class WordDetailScreen extends StatefulWidget {
  final Word word;

  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _toggleFavorite() async {
    final provider = context.read<WordProvider>();
    await provider.toggleFavorite(widget.word.id);
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final isFavorite = context.watch<WordProvider>().isFavorite(word.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(word.ingilizce),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            tooltip: isFavorite ? "Favorilerden çıkar" : "Favorilere ekle",
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: "Kelimeyi oku",
            onPressed: () => _speak(word.ingilizce),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    word.ingilizce,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    word.turkce,
                    style: const TextStyle(fontSize: 24, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Örnek Cümle:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  word.ornekCumle,
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Seviye: ${word.seviye}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
