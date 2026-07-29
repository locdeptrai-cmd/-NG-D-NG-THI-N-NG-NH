import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_controller.dart';
import '../../data/models/exam_models.dart';
import '../../ui/atc_theme.dart';

class PracticeSessionPage extends ConsumerStatefulWidget {
  const PracticeSessionPage({super.key, required this.session});

  final PracticeSession session;

  @override
  ConsumerState<PracticeSessionPage> createState() =>
      _PracticeSessionPageState();
}

class _PracticeSessionPageState extends ConsumerState<PracticeSessionPage> {
  int index = 0;
  final selections = <int, int>{};
  final bookmarks = <int>{};
  bool submitting = false;

  @override
  Widget build(BuildContext context) {
    final question = widget.session.questions[index];
    final progress = (index + 1) / widget.session.questions.length;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: atcNavy,
        title: Text(
            '${widget.session.subject.code} • Câu ${index + 1}/${widget.session.questions.length}'),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              if (!bookmarks.add(question.id)) bookmarks.remove(question.id);
            }),
            tooltip: 'Đánh dấu câu',
            icon: Icon(
              bookmarks.contains(question.id)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: bookmarks.contains(question.id) ? atcWarning : null,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(value: progress, minHeight: 3),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Label(question.code),
                      if (question.category.isNotEmpty)
                        _Label(question.category),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    question.content,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  for (final answer in question.answers)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AnswerTile(
                        answer: answer,
                        selected: selections[question.id] == answer.id,
                        onTap: () => setState(() {
                          selections[question.id] = answer.id;
                        }),
                      ),
                    ),
                ],
              ),
            ),
            _BottomBar(
              index: index,
              total: widget.session.questions.length,
              answered: selections.length,
              submitting: submitting,
              onPrevious: index > 0 ? () => setState(() => index -= 1) : null,
              onNext: index + 1 < widget.session.questions.length
                  ? () => setState(() => index += 1)
                  : null,
              onSubmit: _confirmSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nộp bài luyện tập?'),
        content: Text(
          'Bạn đã trả lời ${selections.length}/${widget.session.questions.length} câu. '
          'Kết quả được lưu trên thiết bị trước khi đồng bộ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục làm'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => submitting = true);
    await ref
        .read(appControllerProvider.notifier)
        .completePractice(widget.session, selections);
    if (!mounted) return;
    final correct = widget.session.questions.where((question) {
      final selected = selections[question.id];
      return question.answers.any(
        (answer) => answer.id == selected && answer.isCorrect,
      );
    }).length;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PracticeResultPage(
          session: widget.session,
          selections: selections,
          correct: correct,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(value,
          style: const TextStyle(fontSize: 12, color: Colors.white60)),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.answer,
    required this.selected,
    required this.onTap,
  });

  final AnswerOption answer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: selected
                ? atcCyan.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? atcCyan : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      selected ? atcCyan : Colors.white.withValues(alpha: 0.07),
                ),
                child: Text(
                  answer.label,
                  style: TextStyle(
                    color: selected ? atcNavy : Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(answer.content)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.total,
    required this.answered,
    required this.submitting,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  final int index;
  final int total;
  final int answered;
  final bool submitting;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: atcSurface,
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
          const SizedBox(width: 8),
          Text('$answered/$total đã trả lời',
              style: const TextStyle(color: Colors.white60)),
          const Spacer(),
          FilledButton.icon(
            onPressed: submitting ? null : onSubmit,
            icon: submitting
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.task_alt),
            label: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }
}

class PracticeResultPage extends StatelessWidget {
  const PracticeResultPage({
    super.key,
    required this.session,
    required this.selections,
    required this.correct,
  });

  final PracticeSession session;
  final Map<int, int> selections;
  final int correct;

  @override
  Widget build(BuildContext context) {
    final score = correct / session.questions.length * 100;
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả luyện tập')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            '${score.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w800,
              color: atcCyan,
            ),
          ),
          Text(
            '$correct/${session.questions.length} câu đúng • đã lưu cục bộ',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 26),
          const Divider(),
          const SizedBox(height: 12),
          Text('Xem giải thích', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (var i = 0; i < session.questions.length; i++)
            _ResultQuestion(
              number: i + 1,
              question: session.questions[i],
              selectedAnswerId: selections[session.questions[i].id],
            ),
        ],
      ),
    );
  }
}

class _ResultQuestion extends StatelessWidget {
  const _ResultQuestion({
    required this.number,
    required this.question,
    required this.selectedAnswerId,
  });

  final int number;
  final QuestionItem question;
  final int? selectedAnswerId;

  @override
  Widget build(BuildContext context) {
    final correctAnswer =
        question.answers.where((answer) => answer.isCorrect).firstOrNull;
    final selected = question.answers
        .where((answer) => answer.id == selectedAnswerId)
        .firstOrNull;
    final ok = selected?.isCorrect == true;
    return ExpansionTile(
      leading: Icon(
        ok ? Icons.check_circle : Icons.cancel,
        color: ok ? atcCyan : Theme.of(context).colorScheme.error,
      ),
      title: Text('Câu $number • ${question.code}'),
      subtitle: Text(
        question.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Bạn chọn: ${selected?.label ?? "Chưa trả lời"}. ${selected?.content ?? ""}'),
        const SizedBox(height: 6),
        Text(
          'Đáp án đúng: ${correctAnswer?.label ?? ""}. ${correctAnswer?.content ?? ""}',
          style: const TextStyle(color: atcCyan, fontWeight: FontWeight.w700),
        ),
        if (question.explanation.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(question.explanation,
              style: const TextStyle(color: Colors.white70)),
        ],
        if (question.referenceText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Tham chiếu: ${question.referenceText}',
              style: const TextStyle(color: atcSky)),
        ],
      ],
    );
  }
}
