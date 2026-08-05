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
  bool _updateDialogVisible = false;
  bool _promptScheduled = false;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(appControllerProvider).packageUpdatePromptPending) {
        _scheduleUpdatePrompt();
      }
    });
  }

  Future<void> _promptPackageUpdates(AppState state) async {
    if (!mounted || _updateDialogVisible) return;
    final outdated = state.packagesNeedingUpdate;
    if (outdated.isEmpty) {
      ref.read(appControllerProvider.notifier).dismissPackageUpdatePrompt();
      return;
    }
    _updateDialogVisible = true;
    final codes = outdated.map((item) => item.subject.code).join(', ');
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Có phiên bản ngân hàng mới'),
        content: Text(
          'Phát hiện cập nhật cho: $codes.\n'
          'Đồng bộ ngay để dùng bộ đề mới trên thiết bị?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đồng bộ ngay'),
          ),
        ],
      ),
    );
    _updateDialogVisible = false;
    if (!mounted) return;
    final controller = ref.read(appControllerProvider.notifier);
    if (confirmed == true) {
      final ok = await controller.syncOutdatedPackages();
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đồng bộ ngân hàng câu hỏi mới.')),
        );
        setState(() => index = 1);
      }
    } else {
      controller.dismissPackageUpdatePrompt();
    }
  }

  void _scheduleUpdatePrompt() {
    if (_updateDialogVisible || _promptScheduled) return;
    _promptScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptScheduled = false;
      _promptPackageUpdates(ref.read(appControllerProvider));
    });
  }

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
    ref.listen(
      appControllerProvider.select((value) => value.packageUpdatePromptPending),
      (previous, pending) {
        if (pending == true) _scheduleUpdatePrompt();
      },
    );
    return Scaffold(
      body: AtcBackdrop(
        imageAsset: 'assets/images/home-bg.png',
        imageAlignment: Alignment.center,
        imageOpacity: 0.78,
        showRadar: false,
        scrimGradient: RadialGradient(
          center: const Alignment(0.72, -0.12),
          radius: 1.35,
          colors: [
            atcNavy.withValues(alpha: 0.58),
            atcNavy.withValues(alpha: 0.82),
          ],
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 900;
              final content = Column(
                children: [
                  _WorkspaceHeader(
                    state: state,
                    onSettings: () => setState(() => index = 5),
                  ),
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
          ? _MobileNavigation(
              selectedIndex: index,
              destinations: destinations.take(5).toList(),
              onSelected: (value) => setState(() => index = value),
            )
          : null,
    );
  }
}

class _MobileNavigation extends StatelessWidget {
  const _MobileNavigation({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<(IconData, IconData, String)> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          for (var index = 0; index < destinations.length; index++)
            Expanded(
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selectedIndex == index
                            ? destinations[index].$2
                            : destinations[index].$1,
                        color:
                            selectedIndex == index ? atcCyan : Colors.white70,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        destinations[index].$3,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              selectedIndex == index ? atcCyan : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WorkspaceHeader extends ConsumerWidget {
  const _WorkspaceHeader({
    required this.state,
    required this.onSettings,
  });

  final AppState state;
  final VoidCallback onSettings;

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
          IconButton(
            onPressed: onSettings,
            tooltip: 'Cài đặt và tài khoản',
            icon: CircleAvatar(
              backgroundColor: atcCyan.withValues(alpha: 0.16),
              child: Text(
                (state.user?.displayName ?? 'O').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: atcCyan,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
