import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_controller.dart';
import '../../ui/atc_theme.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final downloaded = state.packages.where((item) => item.isDownloaded).length;
    return RefreshIndicator(
      onRefresh: () => ref.read(appControllerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sẵn sàng luyện tập',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.online
                      ? 'Danh mục được kiểm tra từ máy chủ. Kết quả mới sẽ tự đồng bộ.'
                      : 'Bạn đang dùng dữ liệu cục bộ. Kết quả sẽ nằm trong hàng đợi.',
                  style: const TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 28,
                  runSpacing: 18,
                  children: [
                    _Metric(
                      value: '$downloaded/${state.packages.length}',
                      label: 'Gói đã tải',
                    ),
                    _Metric(
                      value:
                          '${state.packages.fold<int>(0, (sum, item) => sum + (item.isDownloaded ? item.questionCount : 0))}',
                      label: 'Câu hỏi trên máy',
                    ),
                    _Metric(
                      value: '${state.pendingSync}',
                      label: 'Kết quả chờ gửi',
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                const Divider(),
                const SizedBox(height: 18),
                Text(
                  'Tác vụ chính',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: downloaded > 0 ? () => onNavigate(2) : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Bắt đầu luyện tập'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => onNavigate(1),
                      icon: const Icon(Icons.download_outlined),
                      label:
                          Text(downloaded > 0 ? 'Quản lý gói' : 'Tải dữ liệu'),
                    ),
                    if (state.pendingSync > 0)
                      OutlinedButton.icon(
                        onPressed: state.online ? () => onNavigate(4) : null,
                        icon: const Icon(Icons.sync),
                        label: const Text('Đồng bộ ngay'),
                      ),
                  ],
                ),
                const SizedBox(height: 38),
                _OperationalNote(
                  icon: state.online
                      ? Icons.verified_user_outlined
                      : Icons.offline_bolt_outlined,
                  title: state.online
                      ? 'Phiên luyện tập offline-first'
                      : 'Dữ liệu vẫn an toàn trên thiết bị',
                  text: state.online
                      ? 'Ứng dụng đọc dữ liệu đã tải trước, sau đó mới kiểm tra cập nhật từ máy chủ.'
                      : 'Không xóa ứng dụng hoặc dữ liệu trình duyệt trước khi hàng đợi được đồng bộ.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              height: 1,
              fontWeight: FontWeight.w800,
              color: atcCyan,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }
}

class _OperationalNote extends StatelessWidget {
  const _OperationalNote({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: atcSky),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(text, style: const TextStyle(color: Colors.white60)),
            ],
          ),
        ),
      ],
    );
  }
}
