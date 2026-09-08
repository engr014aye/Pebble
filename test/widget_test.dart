import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble/data/models/entry_model.dart';
import 'package:pebble/presentation/widgets/bouncy_tap.dart';
import 'package:pebble/presentation/widgets/glass_container.dart';
import 'package:pebble/presentation/widgets/pebble_mood_selector.dart';

void main() {
  group('EntryModel & MoodType Unit Tests', () {
    test('MoodType scores and string mapping correctly', () {
      expect(MoodType.great.score, equals(5));
      expect(MoodType.tough.score, equals(1));
      expect(MoodType.fromString('Great'), equals(MoodType.great));
      expect(MoodType.fromString('neutral'), equals(MoodType.neutral));
      expect(MoodType.fromString('unknown'), equals(MoodType.good)); // fallback
      expect(MoodType.fromScore(5), equals(MoodType.great));
      expect(MoodType.fromScore(1), equals(MoodType.tough));
    });

    test('EntryModel serialization to and from Map', () {
      final now = DateTime.now();
      final entry = EntryModel(
        id: 'test-1',
        title: 'Clarity in Morning Routine',
        content: 'Felt very calm after waking up early.',
        mood: MoodType.great,
        category: 'Mind',
        createdAt: now,
        isFavorite: true,
      );

      final map = entry.toMap();
      expect(map['id'], equals('test-1'));
      expect(map['title'], equals('Clarity in Morning Routine'));
      expect(map['mood'], equals('Great'));
      expect(map['is_favorite'], equals(1));

      final deserialized = EntryModel.fromMap(map);
      expect(deserialized.id, equals(entry.id));
      expect(deserialized.title, equals(entry.title));
      expect(deserialized.mood, equals(MoodType.great));
      expect(deserialized.isFavorite, isTrue);
    });
  });

  group('Presentation Widgets Unit Tests', () {
    testWidgets('PebbleMoodSelector renders all 5 moods and handles selection',
        (WidgetTester tester) async {
      MoodType? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PebbleMoodSelector(
              selectedMood: null,
              onMoodSelected: (m) => selected = m,
              showLabels: true,
            ),
          ),
        ),
      );

      expect(find.text('Great'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Neutral'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
      expect(find.text('Tough'), findsOneWidget);

      await tester.tap(find.text('Great'));
      await tester.pumpAndSettle();

      expect(selected, equals(MoodType.great));
    });

    testWidgets('BouncyTap triggers onTap callback', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BouncyTap(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('GlassContainer renders child with padding',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              child: Text('Frosted Content'),
            ),
          ),
        ),
      );

      expect(find.text('Frosted Content'), findsOneWidget);
    });
  });
}
