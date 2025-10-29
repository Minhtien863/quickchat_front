import 'dart:async';
import 'auth_service.dart';

class AuthServiceMock implements AuthService {
  AuthUser? _current;

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _current = AuthUser(id: 'u1', email: email, displayName: 'Minh Tiến');
    return _current!;
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _current = AuthUser(id: 'u1', email: email, displayName: displayName, phone: phone);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _current = null;
  }

  @override
  Future<AuthUser?> currentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _current;
  }
}
