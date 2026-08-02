import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_controller.dart';
import '../../ui/atc_theme.dart';

class SyncPage extends ConsumerWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
      children: [
        Text('Trạng thái đồng bộ',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text(
          'Mỗi kết quả có mã tác vụ riêng; gửi lặp lại không tạo bản ghi trùng.',
          style: TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${state.pendingSync}',
              style: const TextStyle(
                fontSize: 52,
                height: 1,
                fontWeight: FontWeight.w800,
                color: atcCyan,
              ),
            ),
            const SizedBox(width: 12),
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text('tác vụ đang chờ'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: FilledButton.icon(
            onPressed: state.online &&
                    state.authenticated &&
                    state.pendingSync > 0
                ? () async {
                    final count = await ref
                        .read(appControllerProvider.notifier)
                        .syncPending();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã đồng bộ $count tác vụ.')),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.sync),
            label: Text(
              state.online ? 'Đồng bộ ngay' : 'Cần kết nối Internet',
            ),
          ),
        ),
        const SizedBox(height: 34),
        const Divider(),
        const SizedBox(height: 18),
        const _Rule(
          icon: Icons.save_outlined,
          title: 'Lưu local trước',
          detail:
              'Bài làm chỉ vào hàng đợi sau khi đã ghi thành công trên thiết bị.',
        ),
        const _Rule(
          icon: Icons.replay_outlined,
          title: 'Tự động thử lại',
          detail: 'Ứng dụng kiểm tra hàng đợi khi kết nối mạng thay đổi.',
        ),
        const _Rule(
          icon: Icons.fingerprint,
          title: 'Idempotency',
          detail:
              'Máy chủ ghi nhớ operation_id và trả lại kết quả cũ nếu nhận trùng.',
        ),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: atcSky),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(detail, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
