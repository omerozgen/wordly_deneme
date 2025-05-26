import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int correct = 0;
  int wrong = 0;
  int learned = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final quiz = await ProgressService.getQuizStats();
    final learnedList = await ProgressService.getLearnedWordIds();

    setState(() {
      correct = quiz['correct']!;
      wrong = quiz['wrong']!;
      learned = learnedList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlerleme')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StatTile(label: 'Öğrenilen Kelime Sayısı', value: learned),
            StatTile(label: 'Doğru Cevaplar', value: correct),
            StatTile(label: 'Yanlış Cevaplar', value: wrong),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ProgressService.resetProgress();
                await _loadStats();
              },
              child: const Text('Verileri Sıfırla'),
            ),
          ],
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final int value;

  const StatTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
