import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../providers/word_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int correct = 0;
  int wrong = 0;
  int learned = 0;
  int favorites = 0;
  int totalWords = 0;
  int streak = 0;
  int totalActivityDays = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final quiz = await ProgressService.getQuizStats();
    final learnedList = await ProgressService.getLearnedWordIds();
    final favoriteList = await ProgressService.getFavoriteWordIds();
    final currentStreak = await ProgressService.getCurrentStreak();
    final activityDays = await ProgressService.getTotalActivityDays();

    if (mounted) {
      setState(() {
        correct = quiz['correct']!;
        wrong = quiz['wrong']!;
        learned = learnedList.length;
        favorites = favoriteList.length;
        streak = currentStreak;
        totalActivityDays = activityDays;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordProvider = context.watch<WordProvider>();
    totalWords = wordProvider.words.length;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('İstatistikler')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalAnswers = correct + wrong;
    final successRate = totalAnswers > 0
        ? ((correct / totalAnswers) * 100).round()
        : 0;
    final learnedPercentage = totalWords > 0
        ? ((learned / totalWords) * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler ve İlerleme',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadStats,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak Kartı
              _buildStreakCard(),
              const SizedBox(height: 16),

              // Genel İstatistikler
              const Text(
                'Genel İstatistikler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Öğrenilen Kelimeler',
                      learned.toString(),
                      '$learnedPercentage%',
                      Icons.book,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Favoriler',
                      favorites.toString(),
                      '',
                      Icons.favorite,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Toplam Kelimeler',
                      totalWords.toString(),
                      '',
                      Icons.library_books,
                      Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Aktif Günler',
                      totalActivityDays.toString(),
                      '',
                      Icons.calendar_today,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quiz İstatistikleri
              const Text(
                'Quiz İstatistikleri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuizStatsCard(correct, wrong, successRate),
              const SizedBox(height: 24),

              // İlerleme Çubuğu
              _buildProgressCard(learned, totalWords, learnedPercentage),
              const SizedBox(height: 24),

              // Sıfırlama Butonu
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => _showResetDialog(),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Tüm Verileri Sıfırla'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Günlük Seri',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$streak Gün',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                if (subtitle.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizStatsCard(int correct, int wrong, int successRate) {
    final total = correct + wrong;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuizStatItem('Doğru', correct, Colors.green),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _buildQuizStatItem('Yanlış', wrong, Colors.red),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _buildQuizStatItem('Toplam', total, Colors.blue),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Başarı Oranı: %$successRate',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(int learned, int total, int percentage) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Genel İlerleme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total > 0 ? learned / total : 0,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$learned / $total kelime öğrenildi',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Sıfırla'),
        content: const Text(
          'Tüm ilerleme verileriniz silinecek. Bu işlem geri alınamaz. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ProgressService.resetProgress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tüm veriler sıfırlandı'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadStats();
      }
    }
  }
}
