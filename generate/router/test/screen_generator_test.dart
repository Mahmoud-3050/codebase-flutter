import 'package:flutter_test/flutter_test.dart';
import '../src/screen_generator.dart';

void main() {
  group('ScreenGenerator.buildFullPageContent', () {
    test('should generate a standard StatefulWidget with no args', () {
      final content = ScreenGenerator.buildFullPageContent('TestScreen', {});
      expect(content, contains('class TestScreen extends StatefulWidget'));
      expect(content, contains('const TestScreen({super.key});'));
      expect(content, contains('return const Placeholder();'));
    });

    test('should generate fields and constructor for args', () {
      final content = ScreenGenerator.buildFullPageContent('LoginScreen', {
        'email': 'string',
        'attempts': 0,
      });
      expect(content, contains('final String email;'));
      expect(content, contains('final int attempts;'));
      expect(content, contains('required this.email'));
      expect(content, contains('required this.attempts'));
    });
  });

  group('ScreenGenerator.updateExistingScreenArgs', () {
    test(
      'should update args and constructor while preserving custom build logic',
      () {
        const existing = '''
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String oldArg;
  const ProfileScreen({super.key, required this.oldArg});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text(widget.oldArg));
  }
}
''';
        final updated = ScreenGenerator.updateExistingScreenArgs(
          existing,
          'ProfileScreen',
          {'newArg': 'string', 'userId': 123},
        );

        expect(updated, contains('final String newArg;'));
        expect(updated, contains('final int userId;'));
        expect(updated, contains('required this.newArg'));
        expect(updated, contains('required this.userId'));
        expect(updated, isNot(contains('final String oldArg;')));
        expect(
          updated,
          contains('Scaffold(body: Text(widget.oldArg))'),
        ); // Preserved
      },
    );

    test('should handle constructor with no args', () {
      const existing = '''
class SimpleScreen extends StatefulWidget {
  const SimpleScreen({super.key});
  @override
  Widget build(BuildContext context) => Container();
}
''';
      final updated = ScreenGenerator.updateExistingScreenArgs(
        existing,
        'SimpleScreen',
        {'id': 'abc'},
      );
      expect(updated, contains('final String id;'));
      expect(updated, contains('const SimpleScreen({'));
      expect(updated, contains('required this.id'));
    });
  });
}
