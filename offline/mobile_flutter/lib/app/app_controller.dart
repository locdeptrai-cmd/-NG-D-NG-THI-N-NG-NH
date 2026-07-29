import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/database/app_database.dart';
import '../data/models/exam_models.dart';
import '../data/repositories/question_repository.dart';

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(),
);
final apiClientProvider = Provider<ApiClient>(
  (ref) => throw UnimplementedError(),
);
final questionRepositoryProvider = Provider<QuestionRepository>(
  (ref) => throw UnimplementedError(),
);
final appControllerProvider =
    StateNotifierProvider<AppController, AppState>((ref) {
  final controller = AppController(ref.watch(questionRepositoryProvider));
  ref.onDispose(controller.dispose);
  return controller;
});

class AppState {
  const AppState({
    this.initialized = false,
    this.busy = false,
    this.online = false,
    this.authenticated = false,
    this.offlineAccess = false,
    this.user,
    this.subjects = const [],
    this.packages = const [],
    this.pendingSync = 0,
    this.error,
  });

  final bool initialized;
  final bool busy;
  final bool online;
  final bool authenticated;
  final bool offlineAccess;
  final UserProfile? user;
  final List<SubjectSummary> subjects;
  final List<QuestionPackageSummary> packages;
  final int pendingSync;
  final String? error;

  AppState copyWith({
    bool? initialized,
    bool? busy,
    bool? online,
    bool? authenticated,
    bool? offlineAccess,
    UserProfile? user,
    bool clearUser = false,
    List<SubjectSummary>? subjects,
    List<QuestionPackageSummary>? packages,
    int? pendingSync,
    String? error,
    bool clearError = false,
  }) {
    return AppState(
      initialized: initialized ?? this.initialized,
      busy: busy ?? this.busy,
      online: online ?? this.online,
      authenticated: authenticated ?? this.authenticated,
      offlineAccess: offlineAccess ?? this.offlineAccess,
      user: clearUser ? null : user ?? this.user,
      subjects: subjects ?? this.subjects,
      packages: packages ?? this.packages,
      pendingSync: pendingSync ?? this.pendingSync,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AppController extends StateNotifier<AppState> {
  AppController(this._repository) : super(const AppState()) {
    initialize();
  }

  final QuestionRepository _repository;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  String get apiBaseUrl => _repository.baseUrl;

  Future<void> initialize() async {
    await _repository.initialize();
    await _loadLocal();
    final online = await _repository.isOnline();
    final hasSession = await _repository.hasSession();
    final user = await _repository.cachedUser();
    state = state.copyWith(
      initialized: true,
      online: online,
      authenticated: hasSession && user != null,
      user: user,
    );
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((_) => checkOnline());
    if (online && hasSession) {
      await refresh();
      await syncPending();
    }
  }

  Future<void> _loadLocal() async {
    final results = await Future.wait([
      _repository.getSubjects(),
      _repository.getPackages(),
      _repository.pendingSyncCount(),
    ]);
    state = state.copyWith(
      subjects: results[0] as List<SubjectSummary>,
      packages: results[1] as List<QuestionPackageSummary>,
      pendingSync: results[2] as int,
    );
  }

  Future<void> checkOnline() async {
    final online = await _repository.isOnline();
    state = state.copyWith(online: online);
    if (online && state.authenticated) {
      await syncPending();
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final user = await _repository.login(username, password);
      await _loadLocal();
      state = state.copyWith(
        busy: false,
        online: true,
        authenticated: true,
        offlineAccess: false,
        user: user,
      );
      await syncPending();
      return true;
    } catch (error) {
      state = state.copyWith(
        busy: false,
        error: 'Không đăng nhập được. Kiểm tra tài khoản và địa chỉ máy chủ.',
      );
      return false;
    }
  }

  Future<bool> enableOfflineAccess() async {
    await _loadLocal();
    if (!state.packages.any((item) => item.isDownloaded)) {
      state = state.copyWith(
        error: 'Thiết bị chưa có gói câu hỏi đã tải.',
      );
      return false;
    }
    state = state.copyWith(offlineAccess: true, clearError: true);
    return true;
  }

  Future<void> refresh() async {
    if (!state.online || !state.authenticated) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _repository.refreshCatalog();
      await _loadLocal();
      state = state.copyWith(busy: false);
    } catch (_) {
      state = state.copyWith(
        busy: false,
        error: 'Không cập nhật được danh mục. Dữ liệu đã tải vẫn dùng được.',
      );
    }
  }

  Future<void> downloadPackage(String packageId) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _repository.downloadPackage(packageId);
      await _loadLocal();
      state = state.copyWith(busy: false);
    } catch (_) {
      state = state.copyWith(
        busy: false,
        error: 'Tải gói thất bại. Hãy kiểm tra kết nối rồi thử lại.',
      );
    }
  }

  Future<void> removePackage(String packageId) async {
    await _repository.removePackage(packageId);
    await _loadLocal();
  }

  Future<PracticeSession> createPractice(
    QuestionPackageSummary package,
    int count,
  ) {
    return _repository.createPractice(package, questionCount: count);
  }

  Future<void> completePractice(
    PracticeSession session,
    Map<int, int> selections,
  ) async {
    await _repository.completePractice(session, selections);
    await _loadLocal();
    if (state.online && state.authenticated) await syncPending();
  }

  Future<int> syncPending() async {
    try {
      final count = await _repository.syncPending();
      await _loadLocal();
      return count;
    } catch (_) {
      await _loadLocal();
      state = state.copyWith(
        error:
            'Đồng bộ tạm thời chưa thành công; tác vụ vẫn được giữ trên máy.',
      );
      return 0;
    }
  }

  Future<List<LocalAttempt>> attempts() => _repository.getAttempts();

  Future<void> setBaseUrl(String value) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _repository.setBaseUrl(value);
      final online = await _repository.isOnline();
      state = state.copyWith(busy: false, online: online);
    } on FormatException catch (error) {
      state = state.copyWith(busy: false, error: error.message);
    } catch (_) {
      state = state.copyWith(
        busy: false,
        error: 'Không lưu được địa chỉ máy chủ.',
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = state.copyWith(
      authenticated: false,
      offlineAccess: false,
      clearUser: true,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
