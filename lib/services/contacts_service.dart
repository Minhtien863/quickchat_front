import '../models/user_lite.dart';

enum FriendsFilter { all, newOnly, online }
enum GroupSort { activity, name, managed }

class FriendDTO {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool online;
  final bool isNew;

  FriendDTO({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.online,
    this.isNew = false,
  });
}

class GroupDTO {
  final String id;
  final String title;
  final String? avatarUrl;
  final int memberCount;
  final bool muted;

  final DateTime lastActivityAt;
  final String? lastMessagePreview;
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
  final DateTime createdAt;

  FriendInviteDTO({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });
}

class UserProfileDTO {
  final String id;
  final String displayName;
  final String handle;
  final String? bio;
  final String? phone;
  final String? email;
  final DateTime? birthday;
  final String? avatarUrl;

  UserProfileDTO({
    required this.id,
    required this.displayName,
    required this.handle,
    this.bio,
    this.birthday,
    this.avatarUrl,
    this.phone,
    this.email,
  });
}

abstract class ContactsService {
  Future<List<FriendDTO>> listFriends({String? q, FriendsFilter filter = FriendsFilter.all, int limit = 200});
  Future<int> friendsCount();
  Future<int> onlineFriendsCount();
  Future<int> newFriendsCount();

  Future<List<GroupDTO>> listGroups({String? q, int limit = 200});

  Future<int>  friendInvitesCount();
  Future<List<FriendInviteDTO>> listFriendInvites({int limit = 50});
  Future<List<FriendInviteDTO>> listSentFriendInvites({int limit = 50});
  Future<void> acceptFriendInvite(String inviteId);
  Future<void> declineFriendInvite(String inviteId);
  Future<void> cancelSentFriendInvite(String inviteId);

  Future<UserProfileDTO> getProfile(String userId);
  Future<UserProfileDTO> myProfile();

  Future<UserProfileDTO> updateMyProfile({
    required String displayName,
    String? bio,
    String? phone,
    DateTime? birthday,
  });

  Future<List<UserLite>> searchUsers({required String q});
  Future<void> sendFriendInvite({required String userId});
}