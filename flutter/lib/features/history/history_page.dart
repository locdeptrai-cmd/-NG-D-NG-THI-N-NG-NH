import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_controller.dart';
import '../../core/database/app_database.dart';
import '../../ui/atc_theme.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<LocalAttempt>>(
      future: ref.read(appControllerProvider.notifier).attempts(),
      builder: (context, snapshot) {
        final attempts = snapshot.data ?? const <LocalAttempt>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
          children: [
            Text('Lịch sử làm bài',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Lịch sử được giữ trên thiết bị kể cả khi chưa thể gửi lên máy chủ.',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 24),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (attempts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 54),
                child: Center(child: Text('Chưa có bài luyện tập nào.')),
              )
            else
              for (final attempt in attempts)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: atcCyan.withValues(alpha: 0.12),
                    child: Text(
                      '${(attempt.score ?? 0).round()}',
                      style: const TextStyle(color: atcCyan, fontSize: 12),
                    ),
                  ),
                  title: Text(
                      '${attempt.subjectCode} • ${attempt.correctAnswers}/${attempt.totalQuestions} câu'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(attempt.startedAt.toLocal()),
                  ),
                  trailing: Icon(
                    attempt.syncStatus == 'completed'
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_upload_outlined,
                    color: attempt.syncStatus == 'completed'
                        ? atcCyan
                        : atcWarning,
                  ),
                ),
          ],
        );
      },
    );
  }
}
