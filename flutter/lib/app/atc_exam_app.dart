import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/authentication/login_page.dart';
import '../features/shell/workspace_shell.dart';
import '../ui/atc_theme.dart';
import 'app_controller.dart';

class AtcExamApp extends ConsumerWidget {
  const AtcExamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ATC Exam',
      theme: buildAtcTheme(),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        child: !state.initialized
            ? const _InitializingScreen(key: ValueKey('initializing'))
            : state.authenticated || state.offlineAccess
                ? const WorkspaceShell(key: ValueKey('workspace'))
                : const LoginPage(key: ValueKey('login')),
      ),
    );
  }
}

class _InitializingScreen extends StatelessWidget {
  const _InitializingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radar_rounded, size: 52),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Đang mở dữ liệu ATC Exam…'),
          ],
        ),
      ),
    );
  }
}
