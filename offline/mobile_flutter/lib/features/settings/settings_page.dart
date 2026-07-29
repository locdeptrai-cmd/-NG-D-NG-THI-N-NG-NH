import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_controller.dart';
import '../../ui/atc_theme.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController apiUrl;

  @override
  void initState() {
    super.initState();
    apiUrl = TextEditingController(
      text: ref.read(appControllerProvider.notifier).apiBaseUrl,
    );
  }

  @override
  void dispose() {
    apiUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
      children: [
        Text('Cài đặt', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Máy chủ Django',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              TextField(
                controller: apiUrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ API',
                  hintText: 'https://example.com/api',
                  prefixIcon: Icon(Icons.dns_outlined),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(appControllerProvider.notifier)
                        .setBaseUrl(apiUrl.text);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Đã lưu và kiểm tra địa chỉ máy chủ.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Lưu địa chỉ'),
                ),
              ),
              const SizedBox(height: 30),
              Text('Cài PWA', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              const _InstallStep(
                icon: Icons.phone_iphone,
                title: 'iPhone / iPad',
                detail: 'Safari → Chia sẻ → Thêm vào Màn hình chính.',
              ),
              const _InstallStep(
                icon: Icons.android,
                title: 'Android',
                detail:
                    'Chrome → Cài đặt ứng dụng hoặc Thêm vào màn hình chính.',
              ),
              const _InstallStep(
                icon: Icons.laptop_windows,
                title: 'Windows / macOS',
                detail:
                    'Dùng nút Cài đặt ứng dụng trên thanh địa chỉ của trình duyệt.',
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 18),
              const Text(
                'ATC Exam PWA 2.0.0\nDữ liệu offline: Drift + IndexedDB/SQLite',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      ref.read(appControllerProvider.notifier).logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstallStep extends StatelessWidget {
  const _InstallStep({
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
      padding: const EdgeInsets.only(bottom: 14),
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
