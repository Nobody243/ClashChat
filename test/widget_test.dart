import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:clashchat/models/rank_model.dart';
import 'package:clashchat/models/chat_message.dart';
import 'package:clashchat/widgets/gradient_button.dart';
import 'package:clashchat/widgets/stat_chip.dart';
import 'package:clashchat/widgets/rank_badge_widget.dart';
import 'package:clashchat/core/theme_provider.dart';

void main() {
  group('RankModel Rating & Progression Tests', () {
    test('Calculates correct rank based on points', () {
      expect(RankModel.getRankFromPoints(0), DebateRank.newcomer);
      expect(RankModel.getRankFromPoints(150), DebateRank.newcomer);
      expect(RankModel.getRankFromPoints(200), DebateRank.challenger);
      expect(RankModel.getRankFromPoints(350), DebateRank.challenger);
      expect(RankModel.getRankFromPoints(500), DebateRank.debater);
      expect(RankModel.getRankFromPoints(850), DebateRank.debater);
      expect(RankModel.getRankFromPoints(1000), DebateRank.orator);
      expect(RankModel.getRankFromPoints(1500), DebateRank.orator);
      expect(RankModel.getRankFromPoints(2000), DebateRank.grandmaster);
      expect(RankModel.getRankFromPoints(5000), DebateRank.grandmaster);
    });

    test('Calculates points earned from debate outcomes', () {
      // Casual debates give 0 rank points
      expect(RankModel.calculatePointsEarned(95, false), 0);
      expect(RankModel.calculatePointsEarned(20, false), 0);

      // Ranked wins
      expect(RankModel.calculatePointsEarned(95, true), 50);
      expect(RankModel.calculatePointsEarned(85, true), 35);
      expect(RankModel.calculatePointsEarned(75, true), 25);
      expect(RankModel.calculatePointsEarned(65, true), 15);
      expect(RankModel.calculatePointsEarned(55, true), 10);

      // Ranked losses
      expect(RankModel.calculatePointsEarned(45, true), -10);
      expect(RankModel.calculatePointsEarned(20, true), -20);
    });

    test('Computes valid rank progress ratio', () {
      expect(RankModel.getRankProgress(0), 0.0);
      expect(RankModel.getRankProgress(2000), 1.0);
      final midProgress = RankModel.getRankProgress(350);
      expect(midProgress, greaterThan(0.0));
      expect(midProgress, lessThan(1.0));
    });
  });

  group('ChatMessage Data Model Tests', () {
    test('Instantiates ChatMessage with user and coach tip', () {
      final now = DateTime.now();
      final msg = ChatMessage(
        text: 'AI regulation is essential for public safety.',
        isUser: true,
        timestamp: now,
        coachTip: 'Strong opening claim with clear scope.',
      );

      expect(msg.text, 'AI regulation is essential for public safety.');
      expect(msg.isUser, isTrue);
      expect(msg.timestamp, now);
      expect(msg.coachTip, 'Strong opening claim with clear scope.');
    });
  });

  group('ClashChat Custom UI Widget Tests', () {
    testWidgets('GradientButton renders label and responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GradientButton(
                label: 'Start Debate',
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Start Debate'), findsOneWidget);

      await tester.tap(find.text('Start Debate'));
      await tester.pump(const Duration(milliseconds: 150));

      expect(tapped, isTrue);
    });

    testWidgets('StatChip displays label and icon with ThemeProvider', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: StatChip(
                  label: 'Win Streak 5 🔥',
                  icon: Icons.bolt,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Win Streak 5 🔥'), findsOneWidget);
      expect(find.byIcon(Icons.bolt), findsOneWidget);
    });

    testWidgets('RankBadgeWidget renders custom painter for ranks', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: RankBadgeWidget(
                rank: DebateRank.debater,
                size: 80,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RankBadgeWidget), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
