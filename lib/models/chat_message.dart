/// Represents a single message in a debate chat session.
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? coachTip;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.coachTip,
  });
}
