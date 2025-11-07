import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_service.dart';
import 'contacts_service_http.dart' show setContactsAccessToken;

class AuthServiceHttp implements AuthService {
  final String baseUrl;

  String? _accessToken;
  String? _refreshToken;
  AuthUser? _current;

  static const _storage = FlutterSecureStorage();
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserJson = 'auth_user_json';

  AuthServiceHttp({required this.baseUrl});

  Future<void> init() async {
    final at = await _storage.read(key: _kAccessToken);
    final rt = await _storage.read(key: _kRefreshToken);
    final userStr = await _storage.read(key: _kUserJson);

    _accessToken = at;
    _refreshToken = rt;

    if (userStr != null) {
      try {
        final data = jsonDecode(userStr) as Map<String, dynamic>;
        _current = _parseUser(data);
      } catch (_) {
        // nếu lỗi parse thì bỏ qua
      }
    }
  }


  Map<String, String> get _jsonNoAuth => {
    'Content-Type': 'application/json',
  };

  Map<String, String> get _jsonWithAuth => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  AuthUser _parseUser(Map<String, dynamic> u) {
    return AuthUser(
      id: u['id'] as String,
      email: u['email'] as String,
      displayName:
      (u['display_name'] ?? u['displayName'] ?? '') as String,
      avatarUrl: (u['avatar_url'] ?? u['avatarUrl']) as String?,
      phone: u['phone'] as String?,
    );
  }

  Map<String, String> get _authHeader => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  Future<AuthUser> uploadAvatar(File file) async {
    // NHỚ chỉnh path này trùng với backend
    final uri = Uri.parse('$baseUrl/api/auth/profile/avatar');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(_authHeader);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _errorFromResponse(res);
    }

    // ---- parse an toàn ----
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Phản hồi server không hợp lệ: ${res.body}');
    }

    Map<String, dynamic>? u;
    if (decoded['user'] is Map<String, dynamic>) {
      u = decoded['user'] as Map<String, dynamic>;
    } else if (decoded['profile'] is Map<String, dynamic>) {
      // trường hợp backend trả { profile: {...} }
      u = decoded['profile'] as Map<String, dynamic>;
    }

    if (u == null) {
      throw Exception('Phản hồi server không có user/profile: ${res.body}');
    }

    _current = _parseUser(u);

    // lưu lại user (để lần sau vào app vẫn có avatar mới)
    await _storage.write(
      key: _kUserJson,
      value: jsonEncode(u),
    );

    return _current!;
  }

  Future<void> _storeTokensAndUser(Map<String, dynamic> body) async {
    final u = body['user'] as Map<String, dynamic>;
    final t = body['tokens'] as Map<String, dynamic>?;

    _current = _parseUser(u);

    if (t != null) {
      _accessToken = t['accessToken'] as String?;
      _refreshToken = t['refreshToken'] as String?;
      setContactsAccessToken(_accessToken);
    }

    // lưu xuống storage
    await _storage.write(
      key: _kUserJson,
      value: jsonEncode(u),
    );
    if (_accessToken != null) {
      await _storage.write(key: _kAccessToken, value: _accessToken);
    }
    if (_refreshToken != null) {
      await _storage.write(key: _kRefreshToken, value: _refreshToken);
    }
  }

  Exception _errorFromResponse(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) {
        return Exception(msg);
      }
    } catch (_) {}
    return Exception('Lỗi server (${res.statusCode})');
  }

  // ========== AuthService bắt buộc ==========

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    final res = await http.post(
      uri,
      headers: _jsonNoAuth,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await _storeTokensAndUser(data);
      return _current!;
    }
    throw _errorFromResponse(res);
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) {
    // Không dùng trong flow OTP hiện tại
    throw UnimplementedError('Dùng flow đăng ký OTP thay cho signUp().');
  }

  Future<AuthUser> fetchMe() async {
    final uri = Uri.parse('$baseUrl/api/auth/me');
    final res = await http.get(uri, headers: _jsonWithAuth);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final u = data['user'] as Map<String, dynamic>;

      _current = _parseUser(u);
      return _current!;
    }

    throw _errorFromResponse(res);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _accessToken = null;
    _refreshToken = null;

    setContactsAccessToken(null);
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kUserJson);
  }


  @override
  Future<AuthUser?> currentUser() async => _current;

  // ========== Flow OTP 3 bước ==========

  Future<void> startRegister({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/register/start');
    final res = await http.post(
      uri,
      headers: _jsonNoAuth,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw _errorFromResponse(res);
  }

  Future<AuthUser> verifyEmail({
    required String email,
    required String code,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/register/verify-email');
    final res = await http.post(
      uri,
      headers: _jsonNoAuth,
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await _storeTokensAndUser(data);
      return _current!;
    }
    throw _errorFromResponse(res);
  }

  Future<AuthUser> completeProfile({
    required String displayName,
    String? phone,
    String? avatarAssetId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/complete-profile');
    final res = await http.post(
      uri,
      headers: _jsonWithAuth,
      body: jsonEncode({
        'displayName': displayName,
        'phone': phone,
        'avatarAssetId': avatarAssetId,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final u = data['user'] as Map<String, dynamic>;
      _current = _parseUser(u);
      return _current!;
    }
    throw _errorFromResponse(res);
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
}
