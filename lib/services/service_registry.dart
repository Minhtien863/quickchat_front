// lib/services/service_registry.dart
import 'auth_service.dart';
import 'auth_service_http.dart';
import 'chat_service.dart';
import 'chat_service_http.dart';
import 'contacts_service.dart';
import 'contacts_service_http.dart';

export '../models/user_lite.dart';

const _baseUrl = 'http://10.0.2.2:4000';

class Services {
  // giữ instance gốc kiểu AuthServiceHttp để gọi init(), accessToken, v.v.
  static final AuthServiceHttp _authHttp =
  AuthServiceHttp(baseUrl: _baseUrl);

  // public API: dùng qua interface AuthService
  static AuthService get auth => _authHttp;

  static final ChatService chat = ChatServiceHttp(
    baseUrl: _baseUrl,
    auth: _authHttp, // truyền đúng instance
  );

  static final ContactsService contacts = ContactsServiceHttp();

  // gọi trong main()
  static Future<void> init() async {
    await _authHttp.init();
  }
}
