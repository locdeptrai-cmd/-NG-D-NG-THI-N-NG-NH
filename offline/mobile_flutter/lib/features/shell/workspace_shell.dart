import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_controller.dart';
import '../../ui/atc_backdrop.dart';
import '../../ui/atc_theme.dart';
import '../../ui/status_chip.dart';
import '../dashboard/dashboard_page.dart';
import '../downloads/downloads_page.dart';
import '../history/history_page.dart';
import '../practice/practice_page.dart';
import '../settings/settings_page.dart';
import '../sync/sync_page.dart';

class WorkspaceShell extends ConsumerStatefulWidget {
  const WorkspaceShell({super.key});

  @override
  ConsumerState<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends ConsumerState<WorkspaceShell> {
  int index = 0;

  static const destinations = [
    (Icons.space_dashboard_outlined, Icons.space_dashboard, 'Tổng quan'),
    (Icons.download_outlined, Icons.download, 'Tải dữ liệu'),
    (Icons.quiz_outlined, Icons.quiz, 'Luyện tập'),
    (Icons.history_outlined, Icons.history, 'Lịch sử'),
    (Icons.sync_outlined, Icons.sync, 'Đồng bộ'),
    (Icons.settings_outlined, Icons.settings, 'Cài đặt'),
  ];

  List<Widget> get pages => [
        DashboardPage(onNavigate: (value) => setState(() => index = value)),
        const DownloadsPage(),
        const PracticePage(),
        const HistoryPage(),
        const SyncPage(),
        const SettingsPage(),
      ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    ref.listen(appControllerProvider.select((value) => value.error),
        (_, error) {
      if (error == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    });
    return Scaffold(
      body: AtcBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 900;
              final content = Column(
                children: [
                  _WorkspaceHeader(state: state),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0.02, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(index),
                        child: pages[index],
                      ),
                    ),
                  ),
                ],
              );
              if (!desktop) return content;
              return Row(
                children: [
                  NavigationRail(
                    backgroundColor: Colors.black.withValues(alpha: 0.12),
                    selectedIndex: index,
                    onDestinationSelected: (value) {
                      setState(() => index = value);
                    },
                    extended: constraints.maxWidth >= 1180,
                    leading: const Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 22),
                      child:
                          Icon(Icons.radar_rounded, color: atcCyan, size: 34),
                    ),
                    destinations: [
                      for (final item in destinations)
                        NavigationRailDestination(
                          icon: Icon(item.$1),
                          selectedIcon: Icon(item.$2),
                          label: Text(item.$3),
                        ),
                    ],
                  ),
                  VerticalDivider(
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  Expanded(child: content),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 900
          ? NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => setState(() => index = value),
              destinations: [
                for (final item in destinations)
                  NavigationDestination(
                    icon: Icon(item.$1),
                    selectedIcon: Icon(item.$2),
                    label: item.$3,
                  ),
              ],
            )
          : null,
    );
  }
}

class _WorkspaceHeader extends ConsumerWidget {
  const _WorkspaceHeader({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
      child: Row(
        children: [
          if (MediaQuery.sizeOf(context).width < 900) ...[
            const Icon(Icons.radar_rounded, color: atcCyan),
            const SizedBox(width: 10),
          ],
          const Text(
            'ATC EXAM',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const Spacer(),
          StatusChip(
            label: state.online ? 'Trực tuyến' : 'Ngoại tuyến',
            active: state.online,
            icon: state.online
                ? Icons.cloud_done_outlined
                : Icons.cloud_off_outlined,
          ),
          if (state.pendingSync > 0) ...[
            const SizedBox(width: 8),
            StatusChip(
              label: '${state.pendingSync} chờ gửi',
              active: false,
              icon: Icons.sync_problem_outlined,
            ),
          ],
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: atcCyan.withValues(alpha: 0.16),
            child: Text(
              (state.user?.displayName ?? 'O').substring(0, 1).toUpperCase(),
              style:
                  const TextStyle(color: atcCyan, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
