import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atc_offline_mobile/core/api/api_client.dart';
import 'package:atc_offline_mobile/data/models/exam_models.dart';
import 'package:atc_offline_mobile/ui/atc_theme.dart';
import 'package:atc_offline_mobile/ui/status_chip.dart';

void main() {
  test('question package parser marks the correct answer', () {
    final package = QuestionPackageBundle.fromJson({
      'package_id': 'ADC-2026-PRACTICE',
      'name': 'ADC',
      'version': 2,
      'checksum': 'sha256:test',
      'minimum_app_version': '1.0.0',
      'updated_at': '2026-07-29T12:00:00Z',
      'size_bytes': 120,
      'question_count': 1,
      'subject': {'id': 1, 'code': 'ADC', 'name': 'ADC'},
      'questions': [
        {
          'id': 10,
          'code': 'ADC-001',
          'content': 'Question',
          'question_type': 'single',
          'category_id': 1,
          'category': 'General',
          'answers': [
            {'id': 1, 'label': 'A', 'content': 'Correct'},
            {'id': 2, 'label': 'B', 'content': 'Wrong'},
          ],
          'correct_answer': ['A'],
          'explanation': 'Explanation',
          'reference': 'Reference',
        },
      ],
    });

    expect(package.questions.single.answers.first.isCorrect, isTrue);
    expect(package.questions.single.answers.last.isCorrect, isFalse);
  });

  testWidgets('network status is visible and accessible', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAtcTheme(),
        home: const Scaffold(
          body: StatusChip(
            label: 'Trực tuyến',
            active: true,
            icon: Icons.cloud_done_outlined,
          ),
        ),
      ),
    );

    expect(find.text('Trực tuyến'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_done_outlined), findsOneWidget);
  });

  test('hosted PWA rejects a saved localhost API URL', () {
    expect(
      ApiClient.isSavedBaseUrlUsable(
        value: 'http://127.0.0.1:8000/api',
        pageUri: Uri.parse('https://example.github.io/atc-exam/'),
        isWeb: true,
      ),
      isFalse,
    );
  });

  test('hosted PWA keeps a saved HTTPS API URL', () {
    expect(
      ApiClient.isSavedBaseUrlUsable(
        value: 'https://api.example.com/api',
        pageUri: Uri.parse('https://example.github.io/atc-exam/'),
        isWeb: true,
      ),
      isTrue,
    );
  });

  test('production default API points to Render', () {
    expect(
      ApiClient.productionBaseUrl,
      'https://atc-exam-api.onrender.com/api',
    );
  });

  test('hosted PWA rejects a saved LAN IP API URL', () {
    expect(
      ApiClient.isSavedBaseUrlUsable(
        value: 'http://192.168.1.10:8000/api',
        pageUri: Uri.parse('https://locdeptrai-cmd.github.io/-NG-D-NG-THI-N-NG-NH/'),
        isWeb: true,
      ),
      isFalse,
    );
  });
}
