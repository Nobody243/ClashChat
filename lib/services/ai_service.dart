import 'dart:convert';
import 'dart:math' show min;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class AiService {
  static const String _apiEndpoint =
      'https://clashchat-proxy.clashchat-proxy-2026.workers.dev/';
  static final String _appSecret = dotenv.env['APP_SHARED_SECRET']!;
  static const String _model = 'llama-3.3-70b-versatile';

  static Future<ChatMessage> sendDebateMessage({
    required String topic,
    required String userStance,
    required List<ChatMessage> history,
    required String userMessage,
    required String difficulty,
    bool isLearningMode = false,
  }) async {
    try {
      final aiStance = userStance == 'For' ? 'Against' : 'For';

      String systemPrompt;
      switch (difficulty.toLowerCase()) {
        case 'easy':
        case 'newcomer':
          systemPrompt = 'You are a casual debate opponent talking to a beginner. Use simple everyday words only. Make small logical mistakes sometimes. Be friendly, never intimidating. Max 2 short sentences.';
          break;
        case 'medium':
        case 'challenger':
        case 'debater':
          systemPrompt = 'You are a balanced debate opponent. Use clear simple arguments, no fancy words. Be fair and logical but do not overwhelm. Give the user a real challenge but keep it understandable. Max 3 sentences.';
          break;
        case 'hard':
        case 'orator':
          systemPrompt = 'You are a sharp expert debater. Use advanced logic, philosophy, and precise vocabulary. Never give ground easily. Be aggressive and surgical. Max 3 sentences.';
          break;
        case 'grandmaster':
          systemPrompt = 'You are an absolute master of debate. Your logic is flawless and ruthless. Exploit every tiny flaw in the user\'s argument. Use highly advanced vocabulary and rhetorical devices. Max 3 sentences.';
          break;
        default:
          systemPrompt = 'You are a balanced debate opponent. Be fair and logical. Max 3 sentences.';
      }

      if (isLearningMode) {
        systemPrompt = 'You are an expert debate coach and teacher. The user is practicing debating against you. You must play the role of their opponent AND their coach.\n'
            'Your difficulty level is: $difficulty.\n'
            'Every time you reply, you MUST return your response in strictly valid JSON format with two keys:\n'
            '1. "coach_tip": Provide brief, constructive feedback on the user\'s last argument (e.g., pointing out logical fallacies, strong points, or missing evidence).\n'
            '2. "argument": Make your actual counter-argument as the opponent.\n'
            'Do not return any text outside of the JSON object.';
      }

      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ...history
            .map(
              (msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': isLearningMode && !msg.isUser && msg.coachTip != null
                    ? '{"coach_tip": "${msg.coachTip}", "argument": "${msg.text}"}'
                    : msg.text,
              },
            ),
        {
          'role': 'user',
          'content':
              'Debate topic: "$topic"\nUser is arguing: $userStance\nYou must argue: $aiStance\nBe a fierce but fair opponent. Max 3 sentences.\n\nUser says: $userMessage',
        },
      ];

      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          // APP_SHARED_SECRET is an abuse deterrent, not a cryptographic secret,
          // since it will be visible in the compiled web client. Its only purpose
          // is to block casual/automated direct calls to the proxy endpoint.
          'X-App-Secret': _appSecret,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['choices'][0]['message']['content'] as String?;
        
        if (content == null) {
          return ChatMessage(text: 'Let me think about that...', isUser: false, timestamp: DateTime.now());
        }

        if (isLearningMode) {
          try {
            final jsonStart = content.indexOf('{');
            final jsonEnd = content.lastIndexOf('}') + 1;
            if (jsonStart >= 0 && jsonEnd > jsonStart) {
              final jsonStr = content.substring(jsonStart, jsonEnd);
              final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
              return ChatMessage(
                text: parsed['argument'] ?? content,
                isUser: false,
                timestamp: DateTime.now(),
                coachTip: parsed['coach_tip'],
              );
            }
          } catch (e) {
            debugPrint('JSON Parse error in learning mode: $e');
          }
        }
        
        return ChatMessage(text: content, isUser: false, timestamp: DateTime.now());
      } else {
        debugPrint('GROQ ERROR: ${response.statusCode} - ${response.body}');
        return ChatMessage(text: 'Connection error. Please try again.', isUser: false, timestamp: DateTime.now());
      }
    } catch (e) {
      debugPrint('GROQ ERROR: $e');
      return ChatMessage(text: 'Connection error. Please try again.', isUser: false, timestamp: DateTime.now());
    }
  }

  static Future<Map<String, dynamic>> scoreDebate({
    required String topic,
    required String userStance,
    required List<ChatMessage> messages,
    required String difficulty,
  }) async {
    try {
      final userMessages = messages
          .map((m) => '${m.isUser ? "User" : "ClashBot"}: ${m.text}')
          .join('\n');

      final userMessageCount = messages.where((m) => m.isUser).length;

      debugPrint('🎯 SCORING SESSION:');
      debugPrint('   Topic: $topic');
      debugPrint('   User stance: $userStance');
      debugPrint('   Difficulty: $difficulty');
      debugPrint('   User messages count: $userMessageCount');
      debugPrint('   Total messages: ${messages.length}');
      debugPrint('   Messages:');
      for (var i = 0; i < messages.length; i++) {
        final m = messages[i];
        debugPrint(
          '      [$i] ${m.isUser ? "USER" : "BOT"}: ${m.text.substring(0, min(m.text.length, 100))}...',
        );
      }

      final prompt =
          '''You are a debate judge. Evaluate the user's debate performance using the guidelines below.

USER DETAILS:
- Topic: "$topic"
- User stance: $userStance
- Difficulty Level: $difficulty
- User made: $userMessageCount arguments/responses
- Total exchanges: ${messages.length}

CONVERSATION TO EVALUATE:
$userMessages

DIFFICULTY-BASED SCORING CRITERIA:

${(difficulty.toLowerCase() == 'easy' || difficulty.toLowerCase() == 'newcomer')
              ? '''EASY MODE (Beginner Level):
- 10-25: Gave up or no real responses
- 26-40: Minimal effort, vague answers
- 41-55: Some good points but inconsistent
- 56-70: Held your ground against a basic opponent
- 71-85: Strong arguments despite easy difficulty
- 86-100: Dominated with excellent logic

Expectations: At least 2-3 arguments shown. Clarity valued over complexity.
Min messages for score tiers: 2+ for 40+, 3+ for 70+
'''
              : (difficulty.toLowerCase() == 'medium' || difficulty.toLowerCase() == 'challenger' || difficulty.toLowerCase() == 'debater')
              ? '''MEDIUM MODE (Standard Level):
- 10-25: Couldn't respond or got crushed
- 26-40: Weak arguments, easily countered
- 41-55: Fair points but missed opportunities
- 56-70: Good defense of your stance
- 71-85: Strong logical chains and examples
- 86-100: Exceptional reasoning and strategy

Expectations: At least 3-4 arguments with clear reasoning.
Min messages for score tiers: 3+ for 40+, 4+ for 70+, 5+ for 85+
'''
              : '''HARD MODE (Advanced Level):
- 10-25: Major logical flaws or surrender
- 26-40: Basic arguments only, no depth
- 41-55: Decent points but weak against advanced opponent
- 56-70: Held ground with reasonable rebuttals
- 71-85: Strong logic with good counter-arguments
- 86-100: Expert-level reasoning, evidence, and strategy

Expectations: At least 4-5 arguments with sophisticated reasoning. Examples/evidence required.
Min messages for score tiers: 4+ for 40+, 5+ for 70+, 6+ for 85+
'''}

STRICT RULES (apply these):
- Score between 10-100 only
- Penalize if message count is below difficulty minimum for that score tier
- Give bonus +5 if concrete examples or statistics provided
- Factor argument quality + quantity + consistency
- Consider how well user responded to opponent's counter-arguments

RETURN VALID JSON ONLY (no other text):
{
  "score": 72,
  "strengths": ["specific thing user did well"],
  "weaknesses": ["specific gap or mistake"],
  "summary": "brief honest assessment"
}

Judge fairly for this difficulty level. Score now with ONLY the JSON object.
''';

      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          // APP_SHARED_SECRET is an abuse deterrent, not a cryptographic secret,
          // since it will be visible in the compiled web client. Its only purpose
          // is to block casual/automated direct calls to the proxy endpoint.
          'X-App-Secret': _appSecret,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
          'temperature': 0.4,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text = data['choices'][0]['message']['content'] as String?;
        debugPrint('✅ API RESPONSE TEXT: "$text"');

        if (text != null && text.isNotEmpty) {
          try {
            final jsonStart = text.indexOf('{');
            final jsonEnd = text.lastIndexOf('}') + 1;
            debugPrint(
              '🔍 JSON Start: $jsonStart, JSON End: $jsonEnd, Text length: ${text.length}',
            );

            if (jsonStart >= 0 && jsonEnd > jsonStart) {
              final jsonStr = text.substring(jsonStart, jsonEnd);
              debugPrint('📄 Extracted JSON string: "$jsonStr"');

              final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
              debugPrint('✅ PARSED JSON: $parsed');

              // Validate score is a number and in reasonable range
              final rawScore = parsed['score'];
              debugPrint(
                '📊 RAW SCORE VALUE: "$rawScore" (Type: ${rawScore.runtimeType})',
              );

              int? score;
              if (rawScore is int) {
                score = rawScore;
                debugPrint('  ✓ Score is int: $score');
              } else if (rawScore is double) {
                score = rawScore.toInt();
                debugPrint('  ✓ Score is double, converted: $score');
              } else if (rawScore is String) {
                score = int.tryParse(rawScore);
                debugPrint('  ✓ Score is string, parsed: $score');
              } else {
                debugPrint('  ✗ Score is unexpected type: ${rawScore.runtimeType}');
              }

              if (score != null && score >= 10 && score <= 100) {
                debugPrint('✅ SCORE IS VALID (10-100): $score');
                parsed['score'] = score;
                parsed['strengths'] = _normalizeStringList(parsed['strengths']);
                parsed['weaknesses'] = _normalizeStringList(parsed['weaknesses']);
                parsed['summary'] = parsed['summary']?.toString() ?? 'Debate completed';
                debugPrint('✅✅ RETURNING SCORE: $score from parseDebate()');
                return parsed;
              } else {
                debugPrint('❌ SCORE OUT OF VALID RANGE: $score (must be 10-100)');
              }
            } else {
              debugPrint(
                '❌ Could not find JSON in response: jsonStart=$jsonStart, jsonEnd=$jsonEnd',
              );
            }
          } catch (parseError) {
            debugPrint('❌ JSON PARSE ERROR: $parseError');
            debugPrint('   Stack: ${StackTrace.current}');
          }
        } else {
          debugPrint('⚠️ Empty API response text');
        }
      } else {
        debugPrint('❌ GROQ HTTP ERROR: ${response.statusCode}');
        debugPrint('   Response: ${response.body}');
      }

      debugPrint('⚠️ FALLING BACK TO HARDCODED SCORE: 65');
      return {
        'score': 65,
        'strengths': ['Good effort'],
        'weaknesses': ['Could not evaluate'],
        'summary': 'Debate completed',
      };
    } catch (e, stackTrace) {
      debugPrint('❌ CRITICAL GROQ ERROR: $e');
      debugPrint('   Stack: $stackTrace');
      debugPrint('⚠️ FALLING BACK (ERROR): score 65');
      return {
        'score': 65,
        'strengths': ['Good effort'],
        'weaknesses': ['Could not evaluate'],
        'summary': 'Debate completed',
      };
    }
  }

  static List<String> _normalizeStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
    }
    if (value is String && value.isNotEmpty) {
      return [value];
    }
    return const <String>[];
  }
}
