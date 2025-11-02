class UserLite {
  final String id;
  final String? displayName;
  final String? handle;    // @tienne (lưu không có @ cũng được)
  final String? email;
  final String? phone;
  final String? avatarUrl;

  // Cờ UI cho màn AddFriend
  bool invited;
  bool sending;

  UserLite({
    required this.id,
    this.displayName,
    this.handle,
    this.email,
    this.phone,
    this.avatarUrl,
    this.invited = false,
    this.sending = false,
  });
}
