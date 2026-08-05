import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_controller.dart';
import '../../data/models/exam_models.dart';
import '../../data/repositories/question_selector.dart';
import '../../ui/atc_theme.dart';
import 'practice_session_page.dart';

class PracticePage extends ConsumerStatefulWidget {
  const PracticePage({super.key});

  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  String? selectedPackageId;
  int count = 20;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final downloaded =
        state.packages.where((item) => item.isDownloaded).toList();

    // Keep selection valid when package ids change (e.g. ACC HAN -> ACC_HAN).
    if (downloaded.isNotEmpty &&
        (selectedPackageId == null ||
            !downloaded.any((item) => item.packageId == selectedPackageId))) {
      selectedPackageId = downloaded.first.packageId;
    }

    final selected = downloaded
        .where((item) => item.packageId == selectedPackageId)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
      children: [
        Text('Tạo bài luyện tập',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          selected != null && !usesTsnRatio(selected.subject.code)
              ? 'ACC HAN / ACS SUP HCM / SUP ACS HAN: chia đều theo loại '
                  'kiến thức, không áp dụng tỷ lệ TSN/LTCS. Số câu 20/50/100. '
                  'Không lặp câu của 6 bài đã nộp gần nhất.'
              : 'Nếu ngân hàng còn từ 15% câu TSN trở lên: ưu tiên 35%, thiếu '
                  'thì hạ 25%, rồi 15%. Dưới 15% TSN hoặc hết TSN: chia đều '
                  'theo loại kiến thức. Số câu 20/50/100. Không lặp câu của '
                  '6 bài đã nộp gần nhất.',
          style: const TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 28),
        if (downloaded.isEmpty)
          const _NoDownloadedData()
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nhóm năng định',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                // Choice chips wrap cleanly for labels like "ACC HAN"
                // (SegmentedButton clips long/4-way groups on narrow screens).
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final item in downloaded)
                      ChoiceChip(
                        label: Text(item.subject.code),
                        selected: item.packageId == selectedPackageId,
                        onSelected: (_) {
                          setState(() => selectedPackageId = item.packageId);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 26),
                Text('Số câu', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: [
                    for (final value in supportedMockQuestionCounts)
                      ButtonSegment(value: value, label: Text('$value')),
                  ],
                  selected: {count},
                  onSelectionChanged: (value) =>
                      setState(() => count = value.first),
                ),
                const SizedBox(height: 28),
                if (selected != null) ...[
                  _ReadinessLine(package: selected),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _start(selected),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Bắt đầu làm bài'),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _start(QuestionPackageSummary package) async {
    try {
      final session = await ref
          .read(appControllerProvider.notifier)
          .createPractice(package, count);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PracticeSessionPage(session: session),
          fullscreenDialog: true,
        ),
      );
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}

class _ReadinessLine extends StatelessWidget {
  const _ReadinessLine({required this.package});

  final QuestionPackageSummary package;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.offline_bolt, color: atcCyan),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${package.subject.code} • ${package.questionCount} câu • phiên bản ${package.version}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _NoDownloadedData extends StatelessWidget {
  const _NoDownloadedData();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(Icons.download_for_offline_outlined,
              size: 48, color: Colors.white38),
          SizedBox(height: 14),
          Text('Hãy tải ít nhất một gói câu hỏi trước khi luyện tập.'),
        ],
      ),
    );
  }
}
