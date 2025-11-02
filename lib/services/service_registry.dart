import 'auth_service.dart';
import 'auth_service_mock.dart';
import 'chat_service.dart';
import 'chat_service_mock.dart';
import 'contacts_service.dart';
import 'contacts_service_mock.dart';
export '../models/user_lite.dart';
class Services {
  static AuthService     auth     = AuthServiceMock();
  static ChatService     chat     = ChatServiceMock();
  static ContactsService contacts = ContactsServiceMock();

}
