import 'dart:convert';
import 'package:http/http.dart' as http;

import 'contacts_service.dart';
import '../models/user_lite.dart';

const String _baseUrl = 'http://10.0.2.2:4000/api';

// token được set từ AuthServiceHttp
String? _accessToken;
void setAuthToken(String? token) {
  _accessToken = token;
}

Map<String, String> _authHeaders() {
  final h = {'Content-Type': 'application/json'};
  if (_accessToken != null) {
    h['Authorization'] = 'Bearer $_accessToken';
  }
  return h;
}

void setContactsAccessToken(String? token) {
  _accessToken = token;
}

class ContactsServiceHttp implements ContactsService {
  // ================== PROFILE ==================
  @override
  Future<UserProfileDTO> myProfile() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: _authHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Lấy hồ sơ thất bại: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return _profileFromJson(data['profile'] as Map<String, dynamic>);
  }

  @override
  Future<UserProfileDTO> getProfile(String userId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: _authHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Lấy hồ sơ thất bại: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return _profileFromJson(data['profile'] as Map<String, dynamic>);
  }

  @override
  Future<UserProfileDTO> updateMyProfile({
    required String displayName,
    String? bio,
    String? phone,
    DateTime? birthday,
  }) async {
    final body = {
      'displayName': displayName,
      'bio': bio,
      'phone': phone,
      'birthday': birthday?.toIso8601String(),
    };

    final res = await http.patch(
      Uri.parse('$_baseUrl/users/me'),
      headers: _authHeaders(),
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Không lưu được hồ sơ: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return _profileFromJson(data['profile'] as Map<String, dynamic>);
  }

  UserProfileDTO _profileFromJson(Map<String, dynamic> j) {
    final handleRaw = j['handle'] as String?;
    final emailRaw = j['email'] as String?;

    final fallbackHandle = (emailRaw != null && emailRaw.contains('@'))
        ? emailRaw.split('@').first
        : 'user';

    return UserProfileDTO(
      id: j['id'] as String,
      displayName: j['displayName'] as String,
      handle: handleRaw ?? fallbackHandle,
      bio: j['bio'] as String?,
      phone: j['phone'] as String?,
      email: emailRaw,
      birthday: (j['birthday'] != null && j['birthday'] != '')
          ? DateTime.parse(j['birthday'] as String)
          : null,
      avatarUrl: (j['avatarUrl'] ?? j['avatar_url']) as String?,
    );
  }

  // ========== CÁC HÀM KHÁC — để trống tạm ==========
  @override
  Future<List<FriendDTO>> listFriends({String? q, FriendsFilter filter = FriendsFilter.all, int limit = 200}) async => [];
  @override
  Future<int> friendsCount() async => 0;
  @override
  Future<int> onlineFriendsCount() async => 0;
  @override
  Future<int> newFriendsCount() async => 0;
  @override
  Future<List<GroupDTO>> listGroups({String? q, int limit = 200}) async => [];
  @override
  Future<int> friendInvitesCount() async => 0;
  @override
  Future<List<FriendInviteDTO>> listFriendInvites({int limit = 50}) async => [];
  @override
  Future<List<FriendInviteDTO>> listSentFriendInvites({int limit = 50}) async => [];
  @override
  Future<void> acceptFriendInvite(String inviteId) async {}
  @override
  Future<void> declineFriendInvite(String inviteId) async {}
  @override
  Future<void> cancelSentFriendInvite(String inviteId) async {}
  @override
  Future<List<UserLite>> searchUsers({required String q}) async => [];
  @override
  Future<void> sendFriendInvite({required String userId}) async {}
}