import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_controller.dart';
import '../../ui/atc_backdrop.dart';
import '../../ui/atc_theme.dart';
import '../../ui/status_chip.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      body: AtcBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 760;
                    final intro = _Intro(online: state.online);
                    final form = _LoginForm(
                      formKey: _formKey,
                      username: _username,
                      password: _password,
                      apiBaseUrl:
                          ref.read(appControllerProvider.notifier).apiBaseUrl,
                      hidePassword: _hidePassword,
                      busy: state.busy,
                      error: state.error,
                      onTogglePassword: () {
                        setState(() => _hidePassword = !_hidePassword);
                      },
                      onSubmit: _submit,
                      onConfigureServer: _configureServer,
                      onOffline: () => ref
                          .read(appControllerProvider.notifier)
                          .enableOfflineAccess(),
                    );
                    if (wide) {
                      return Row(
                        children: [
                          Expanded(flex: 6, child: intro),
                          const SizedBox(width: 72),
                          Expanded(flex: 4, child: form),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        intro,
                        const SizedBox(height: 42),
                        form,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(appControllerProvider.notifier).login(
          _username.text.trim(),
          _password.text,
        );
  }

  Future<void> _configureServer() async {
    final controller = TextEditingController(
      text: ref.read(appControllerProvider.notifier).apiBaseUrl,
    );
    final formKey = GlobalKey<FormState>();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Địa chỉ máy chủ'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL API',
                  hintText: 'https://example.com/api',
                  prefixIcon: Icon(Icons.dns_outlined),
                ),
                validator: (input) {
                  final uri = Uri.tryParse(input?.trim() ?? '');
                  if (uri == null ||
                      !const {'http', 'https'}.contains(uri.scheme) ||
                      uri.host.isEmpty) {
                    return 'Nhập URL bắt đầu bằng http:// hoặc https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Khi mở ứng dụng bằng HTTPS, máy chủ API cũng phải dùng HTTPS.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || !mounted) return;
    await ref.read(appControllerProvider.notifier).setBaseUrl(value);
    if (mounted) setState(() {});
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: atcCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.radar_rounded, color: atcCyan),
              ),
              const SizedBox(width: 14),
              const Text(
                'ATC EXAM',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 52),
          Text(
            'Luyện tập vững vàng,\nkể cả khi mất mạng.',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 18),
          Text(
            'Tải gói câu hỏi một lần, làm bài trên mọi thiết bị và đồng bộ kết quả khi kết nối trở lại.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 28),
          StatusChip(
            label: online ? 'Máy chủ sẵn sàng' : 'Đang ở chế độ ngoại tuyến',
            active: online,
            icon: online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.username,
    required this.password,
    required this.apiBaseUrl,
    required this.hidePassword,
    required this.busy,
    required this.error,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onConfigureServer,
    required this.onOffline,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController username;
  final TextEditingController password;
  final String apiBaseUrl;
  final bool hidePassword;
  final bool busy;
  final String? error;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onConfigureServer;
  final VoidCallback onOffline;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Đăng nhập', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text(
            'Kết nối lần đầu để tải dữ liệu dùng ngoại tuyến.',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: busy ? null : onConfigureServer,
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.dns_outlined, size: 18),
            label: Text(
              'Máy chủ: $apiBaseUrl',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 26),
          TextFormField(
            controller: username,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(
              labelText: 'Tài khoản',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Nhập tài khoản' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: password,
            obscureText: hidePassword,
            onFieldSubmitted: (_) => onSubmit(),
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Nhập mật khẩu' : null,
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            Text(error!, style: const TextStyle(color: Color(0xFFFF9A9A))),
          ],
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: busy ? null : onSubmit,
            icon: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login_rounded),
            label: const Text('Đăng nhập và đồng bộ'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: busy ? null : onOffline,
            icon: const Icon(Icons.offline_bolt_outlined),
            label: const Text('Dùng dữ liệu đã tải'),
          ),
        ],
      ),
    );
  }
}
