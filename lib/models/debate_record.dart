import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_message.dart';
import 'debate_mode.dart';

class DebateRecord {
  final String id;
  final String topic;
  final String stance;
  final int score;
  final bool isRanked;
  final DebateMode mode;
  final String difficulty;
  final int pointsEarned;
  final String rankAtTime;
  final int durationMinutes;
  final DateTime date;
  
  final List<ChatMessage> messages;
  final List<String> strengths;
  final List<String> weaknesses;
  final String summary;

  const DebateRecord({
    required this.id,
    required this.topic,
    required this.stance,
    required this.score,
    required this.isRanked,
    required this.mode,
    required this.difficulty,
    required this.pointsEarned,
    required this.rankAtTime,
    required this.durationMinutes,
    required this.date,
    this.messages = const [],
    this.strengths = const [],
    this.weaknesses = const [],
    this.summary = '',
  });

  factory DebateRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    DateTime parsedDate = DateTime.now();
    if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else if (data['date'] != null) {
      parsedDate = DateTime.tryParse(data['date'].toString()) ?? DateTime.now();
    }

    final isRanked = data['isRanked'] as bool? ?? false;
    DebateMode mode = DebateMode.casual;
    if (data['mode'] != null) {
      final modeStr = data['mode'].toString();
      mode = DebateMode.values.firstWhere((e) => e.name == modeStr, orElse: () => isRanked ? DebateMode.ranked : DebateMode.casual);
    } else {
      mode = isRanked ? DebateMode.ranked : DebateMode.casual;
    }

    final msgsData = data['messages'] as List<dynamic>? ?? [];
    final parsedMessages = msgsData.map((m) {
      final md = m as Map<String, dynamic>;
      return ChatMessage(
        text: md['text'] as String? ?? '',
        isUser: md['isUser'] as bool? ?? true,
        timestamp: md['timestamp'] != null ? DateTime.tryParse(md['timestamp'].toString()) ?? parsedDate : parsedDate,
        coachTip: md['coachTip'] as String?,
      );
    }).toList();

    return DebateRecord(
      id: doc.id,
      topic: data['topic'] as String? ?? 'Unknown Topic',
      stance: data['stance'] as String? ?? 'For',
      score: (data['score'] as num?)?.toInt() ?? 0,
      isRanked: isRanked,
      mode: mode,
      difficulty: data['difficulty'] as String? ?? 'Medium',
      pointsEarned: (data['pointsEarned'] as num?)?.toInt() ?? 0,
      rankAtTime: data['rankAtTime'] as String? ?? 'Newcomer',
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? (data['timerMinutes'] as num?)?.toInt() ?? 0,
      date: parsedDate,
      messages: parsedMessages,
      strengths: List<String>.from(data['strengths'] ?? []),
      weaknesses: List<String>.from(data['weaknesses'] ?? []),
      summary: data['summary'] as String? ?? '',
    );
  }
}
