class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? phone;

  AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.phone,
  });
}

abstract class AuthService {
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String displayName,
    String? phone,
  });
  Future<void> signOut();
  Future<AuthUser?> currentUser();
}
