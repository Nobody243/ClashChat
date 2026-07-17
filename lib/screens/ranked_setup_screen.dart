import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rank_model.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';
import '../models/debate_mode.dart';

class RankedSetupScreen extends StatelessWidget {
  final String topic;
  final String stance;

  const RankedSetupScreen({
    super.key,
    required this.topic,
    required this.stance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranked Match')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(AuthService.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final points = snapshot.data?.data()?['rankPoints'] ?? 0;
          final rank = RankModel.getRankFromPoints(points);
          final rankData = RankModel.rankData[rank]!;
          final progress = RankModel.getRankProgress(points);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Current rank display
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(rankData['color'] as int).withOpacity(0.3),
                        Color(rankData['color'] as int).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(rankData['color'] as int).withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(rankData['emoji'] as String,
                        style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(rankData['name'] as String,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(rankData['color'] as int),
                        )),
                      const SizedBox(height: 8),
                      Text('$points Points',
                        style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      // Progress bar to next rank
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation(
                            Color(rankData['color'] as int)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rank == DebateRank.grandmaster
                            ? 'Max Rank!'
                            : '${(progress * 100).toInt()}% to next rank',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Match info
                _InfoRow(icon: Icons.topic, label: 'Topic', value: topic),
                _InfoRow(icon: Icons.sports_mma, label: 'Stance', value: stance),
                _InfoRow(icon: Icons.timer, label: 'Timer', value: '10 minutes (fixed)'),
                _InfoRow(
                  icon: Icons.psychology,
                  label: 'AI Difficulty',
                  value: '${rankData['emoji']} ${rankData['name']} level',
                ),

                const SizedBox(height: 16),

                // Points preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Points at Stake',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _PointsPreview(label: 'Win (50+)', value: '+10 to +50', color: Colors.green),
                          _PointsPreview(label: 'Loss (<50)', value: '-10 to -20', color: Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          topic: topic,
                          stance: stance,
                          difficulty: rankData['name'] as String,
                          timerMinutes: 10, // always 10 in ranked
                          mode: DebateMode.ranked,
                        ),
                      ),
                    ),
                    child: const Text('Enter Ranked Match 🏆',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _PointsPreview extends StatelessWidget {
  final String label, value;
  final Color color;
  const _PointsPreview({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
