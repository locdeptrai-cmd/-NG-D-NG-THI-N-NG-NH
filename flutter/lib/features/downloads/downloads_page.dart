import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_controller.dart';
import '../../data/models/exam_models.dart';
import '../../ui/atc_theme.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
      children: [
        Text('Dữ liệu ngoại tuyến',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text(
          'Tải từng gói vào IndexedDB. Phiên bản chỉ được thay sau khi ghi dữ liệu thành công.',
          style: TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            onPressed: (!state.online || !state.authenticated || state.busy)
                ? null
                : () => ref.read(appControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Làm mới danh mục từ máy chủ'),
          ),
        ),
        const SizedBox(height: 20),
        if (state.packages.isEmpty)
          _EmptyCatalog(online: state.online)
        else
          for (final item in state.packages)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PackageRow(
                package: item,
                busy: state.busy,
                online: state.online,
                onDownload: () => ref
                    .read(appControllerProvider.notifier)
                    .downloadPackage(item.packageId),
                onRemove: () => _confirmRemove(context, ref, item),
              ),
            ),
      ],
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    QuestionPackageSummary package,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa gói ${package.subject.code}?'),
        content: const Text(
          'Lịch sử làm bài được giữ lại; chỉ câu hỏi tải về bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa dữ liệu'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(appControllerProvider.notifier)
          .removePackage(package.packageId);
    }
  }
}

class _PackageRow extends StatelessWidget {
  const _PackageRow({
    required this.package,
    required this.busy,
    required this.online,
    required this.onDownload,
    required this.onRemove,
  });

  final QuestionPackageSummary package;
  final bool busy;
  final bool online;
  final VoidCallback onDownload;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final date =
        DateFormat('dd/MM/yyyy HH:mm').format(package.updatedAt.toLocal());
    final size = package.sizeBytes <= 0
        ? 'Chưa xác định'
        : '${(package.sizeBytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final info = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      package.subject.code,
                      style: const TextStyle(
                        color: atcCyan,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        package.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 18,
                  runSpacing: 6,
                  children: [
                    Text('Phiên bản ${package.version}'),
                    Text('${package.questionCount} câu'),
                    Text(size),
                    Text('Cập nhật $date'),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  package.isDownloaded
                      ? (package.needsUpdate
                          ? 'Có phiên bản mới — cần đồng bộ'
                          : 'Đã tải trên thiết bị')
                      : 'Chưa có dữ liệu cục bộ',
                  style: TextStyle(
                    color: package.isDownloaded
                        ? (package.needsUpdate ? atcWarning : atcCyan)
                        : atcWarning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
            final actions = Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: !online || busy ? null : onDownload,
                  icon: Icon(
                    package.isDownloaded
                        ? Icons.system_update_alt
                        : Icons.download,
                  ),
                  label: Text(
                    package.needsUpdate
                        ? 'Đồng bộ'
                        : (package.isDownloaded ? 'Cập nhật' : 'Tải'),
                  ),
                ),
                if (package.isDownloaded)
                  IconButton(
                    onPressed: busy ? null : onRemove,
                    tooltip: 'Xóa gói',
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [info, const SizedBox(height: 18), actions],
              );
            }
            return Row(
              children: [
                Expanded(child: info),
                const SizedBox(width: 18),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Column(
        children: [
          Icon(
            online ? Icons.refresh : Icons.cloud_off_outlined,
            size: 44,
            color: Colors.white38,
          ),
          const SizedBox(height: 14),
          Text(
            online
                ? 'Đăng nhập lại hoặc làm mới danh mục.'
                : 'Kết nối Internet để lấy danh mục lần đầu.',
          ),
        ],
      ),
    );
  }
}
