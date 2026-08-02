import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/atc_exam_app.dart';
import 'app/app_controller.dart';
import 'core/api/api_client.dart';
import 'core/database/app_database.dart';
import 'data/repositories/question_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.defaults();
  final api = ApiClient();
  final repository = QuestionRepository(database: database, api: api);
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        apiClientProvider.overrideWithValue(api),
        questionRepositoryProvider.overrideWithValue(repository),
      ],
      child: const AtcExamApp(),
    ),
  );
}
