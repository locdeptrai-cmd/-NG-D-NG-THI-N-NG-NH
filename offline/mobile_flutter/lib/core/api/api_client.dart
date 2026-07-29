import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/exam_models.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    FlutterSecureStorage? secureStorage,
  })  : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _dio.options
      ..baseUrl = const String.fromEnvironment(
        'ATC_API_BASE_URL',
        defaultValue: 'http://127.0.0.1:8000/api',
      )
      ..connectTimeout = const Duration(seconds: 8)
      ..receiveTimeout = const Duration(seconds: 30);
  }

  static const _accessKey = 'atc_access_token';
  static const _refreshKey = 'atc_refresh_token';
  static const _baseUrlKey = 'atc_api_base_url';

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  String get baseUrl => _dio.options.baseUrl;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedUrl = preferences.getString(_baseUrlKey);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _dio.options.baseUrl = _normalizeBaseUrl(savedUrl);
    }
  }

  Future<void> setBaseUrl(String value) async {
    final normalized = _normalizeBaseUrl(value);
    _dio.options.baseUrl = normalized;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_baseUrlKey, normalized);
  }

  String _normalizeBaseUrl(String value) {
    var normalized = value.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !const {'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty) {
      throw const FormatException(
        'Địa chỉ máy chủ phải bắt đầu bằng http:// hoặc https://.',
      );
    }
    if (!normalized.endsWith('/api')) {
      normalized = '$normalized/api';
    }
    return normalized;
  }

  Future<bool> hasSession() async {
    return (await _secureStorage.read(key: _refreshKey)) != null;
  }

  Future<void> login(String username, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login/',
      data: {'username': username, 'password': password},
    );
    await _secureStorage.write(
      key: _accessKey,
      value: response.data!['access'].toString(),
    );
    await _secureStorage.write(
      key: _refreshKey,
      value: response.data!['refresh'].toString(),
    );
  }

  Future<void> logout() => _secureStorage.deleteAll();

  Future<bool> isOnline() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/health/');
      return response.statusCode == 200 && response.data?['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  Future<UserProfile> me() async {
    final response = await _authorized<Map<String, dynamic>>(
      () => _dio.get('/auth/me/'),
    );
    return UserProfile.fromJson(response.data!);
  }

  Future<List<SubjectSummary>> getSubjects() async {
    final response = await _authorized<List<dynamic>>(
      () => _dio.get('/subjects/'),
    );
    return response.data!
        .map(
          (item) => SubjectSummary.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<QuestionPackageSummary>> getPackages() async {
    final response = await _authorized<List<dynamic>>(
      () => _dio.get('/question-packages/'),
    );
    return response.data!
        .map(
          (item) => QuestionPackageSummary.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<QuestionPackageBundle> downloadPackage(String packageId) async {
    final response = await _authorized<Map<String, dynamic>>(
      () => _dio.get('/question-packages/$packageId/download/'),
    );
    return QuestionPackageBundle.fromJson(response.data!);
  }

  Future<List<Map<String, dynamic>>> sync(
    String clientId,
    List<Map<String, dynamic>> operations,
  ) async {
    final response = await _authorized<Map<String, dynamic>>(
      () => _dio.post(
        '/sync/',
        data: {'client_id': clientId, 'operations': operations},
      ),
    );
    return (response.data!['results'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  Future<Response<T>> _authorized<T>(
    Future<Response<T>> Function() request,
  ) async {
    final access = await _secureStorage.read(key: _accessKey);
    _dio.options.headers['Authorization'] = 'Bearer $access';
    try {
      return await request();
    } on DioException catch (error) {
      if (error.response?.statusCode != 401 || !await _refresh()) rethrow;
      _dio.options.headers['Authorization'] =
          'Bearer ${await _secureStorage.read(key: _accessKey)}';
      return request();
    }
  }

  Future<bool> _refresh() async {
    final refresh = await _secureStorage.read(key: _refreshKey);
    if (refresh == null) return false;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh/',
        data: {'refresh': refresh},
      );
      await _secureStorage.write(
        key: _accessKey,
        value: response.data!['access'].toString(),
      );
      final rotated = response.data!['refresh'];
      if (rotated != null) {
        await _secureStorage.write(
          key: _refreshKey,
          value: rotated.toString(),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
