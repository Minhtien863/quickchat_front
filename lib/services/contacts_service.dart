import '../models/user_lite.dart';
enum FriendsFilter { all, newOnly, online }
enum GroupSort { activity, name, managed } // mới

class FriendDTO {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool online;
  final bool isNew;
  FriendDTO({required this.id, required this.displayName, this.avatarUrl, required this.online, this.isNew = false});
}

class GroupDTO {
  final String id;
  final String title;
  final String? avatarUrl;
  final int memberCount;
  final bool muted;

  final DateTime lastActivityAt;        // thời gian hoạt động cuối
  final String? lastMessagePreview;     // dòng preview
  final bool isManaged;

  GroupDTO({
    required this.id,
    required this.title,
    this.avatarUrl,
    required this.memberCount,
    required this.muted,
    required this.lastActivityAt,
    this.lastMessagePreview,
    this.isManaged = false,
  });
}

class FriendInviteDTO {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt; // <-- để hiển thị "x ngày trước"
  FriendInviteDTO({required this.id, required this.displayName, this.avatarUrl, required this.createdAt});
}

class UserProfileDTO {
  final String id;
  final String displayName;
  final String handle;
  final String? bio;
  final DateTime? birthday;
  final String? avatarUrl;
  UserProfileDTO({required this.id, required this.displayName, required this.handle, this.bio, this.birthday, this.avatarUrl});
}



abstract class ContactsService {
  Future<List<FriendDTO>> listFriends({String? q, FriendsFilter filter = FriendsFilter.all, int limit = 200});
  Future<int> friendsCount();
  Future<int> onlineFriendsCount();
  Future<int> newFriendsCount();

  Future<List<GroupDTO>> listGroups({String? q, int limit = 200});

  Future<int>  friendInvitesCount();
  Future<List<FriendInviteDTO>> listFriendInvites({int limit = 50});        // ĐÃ NHẬN
  Future<List<FriendInviteDTO>> listSentFriendInvites({int limit = 50});    // ĐÃ GỬI
  Future<void> acceptFriendInvite(String inviteId);
  Future<void> declineFriendInvite(String inviteId);
  Future<void> cancelSentFriendInvite(String inviteId);                      // <-- THÊM

  Future<UserProfileDTO> getProfile(String userId);
  Future<UserProfileDTO> myProfile();

  Future<List<UserLite>> searchUsers({required String q});
  Future<void> sendFriendInvite({required String userId});
}
