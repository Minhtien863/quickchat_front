import 'dart:async';
import 'contacts_service.dart';

class ContactsServiceMock implements ContactsService {
  final String _me = 'u1';


  final Map<String, UserProfileDTO> _profiles = {
    'u1': UserProfileDTO(id: 'u1', displayName: 'Minh Tiến', handle: 'minhtien', birthday: DateTime(2003, 6, 12), bio: 'Xây QuickChat'),
    'u2': UserProfileDTO(id: 'u2', displayName: 'Bích Châu', handle: 'bichchau'),
    'u3': UserProfileDTO(id: 'u3', displayName: 'Bt', handle: 'bt.99'),
    'u4': UserProfileDTO(id: 'u4', displayName: 'Cậu Út', handle: 'cauut'),
    'u5': UserProfileDTO(id: 'u5', displayName: 'Cô 6', handle: 'co6'),
    'u6': UserProfileDTO(id: 'u6', displayName: 'Cô Ba', handle: 'coba'),
    'u7': UserProfileDTO(id: 'u7', displayName: 'Công Danh', handle: 'congdanh'),
  };

  final List<FriendDTO> _friends = [
    FriendDTO(id: 'u2', displayName: 'Bích Châu', online: true,  isNew: true),
    FriendDTO(id: 'u3', displayName: 'Bt',        online: false),
    FriendDTO(id: 'u4', displayName: 'Cậu Út',    online: true),
    FriendDTO(id: 'u5', displayName: 'Cô 6',      online: false),
    FriendDTO(id: 'u6', displayName: 'Cô Ba',     online: false, isNew: true),
    FriendDTO(id: 'u7', displayName: 'Công Danh', online: true),
  ];

  final List<GroupDTO> _groups = [
    GroupDTO(
      id: 'g1',
      title: 'Box1 Kid: Giao Lưu',
      memberCount: 58,
      muted: false,
      lastActivityAt: DateTime.now().subtract(const Duration(minutes: 1)),
      lastMessagePreview: 'Đang lên núi r :)))',
      isManaged: true,
    ),
    GroupDTO(
      id: 'g2',
      title: 'Tuổi Thơ Năm 2012',
      memberCount: 120,
      muted: true,
      lastActivityAt: DateTime.now().subtract(const Duration(minutes: 1)),
      lastMessagePreview: '@Minh Tiến nó trong sách a đọc xong a...',
    ),
    GroupDTO(
      id: 'g3',
      title: 'KID Huyền Thoại Nro',
      memberCount: 230,
      muted: false,
      lastActivityAt: DateTime.now().subtract(const Duration(hours: 2)),
      lastMessagePreview: '[Link cộng đồng] https://zalo.me/g...',
    ),
    GroupDTO(
      id: 'g4',
      title: 'BCTN D21HTTT01',
      memberCount: 45,
      muted: false,
      lastActivityAt: DateTime.now().subtract(const Duration(days: 6)),
      lastMessagePreview: 'Dạ vâng thầy',
      isManaged: false,
    ),
  ];

  final List<FriendInviteDTO> _received = [
    FriendInviteDTO(id: 'i101', displayName: 'Anh Khôi',   createdAt: DateTime.now().subtract(const Duration(days: 1))),
    FriendInviteDTO(id: 'i102', displayName: 'Lan Phương', createdAt: DateTime.now().subtract(const Duration(days: 2))),
    FriendInviteDTO(id: 'i103', displayName: 'Minh Quân',  createdAt: DateTime.now().subtract(const Duration(hours: 4))),
  ];
  final List<FriendInviteDTO> _sent = [
    FriendInviteDTO(id: 's201', displayName: 'Ngọc Hân',   createdAt: DateTime.now().subtract(const Duration(days: 3))),
  ];

  @override
  Future<List<FriendDTO>> listFriends({String? q, FriendsFilter filter = FriendsFilter.all, int limit = 200}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    Iterable<FriendDTO> res = _friends;
    if ((q ?? '').isNotEmpty) {
      final qq = q!.toLowerCase();
      res = res.where((f) => f.displayName.toLowerCase().contains(qq));
    }
    if (filter == FriendsFilter.online) res = res.where((f) => f.online);
    if (filter == FriendsFilter.newOnly) res = res.where((f) => f.isNew);
    final list = res.toList()..sort((a,b)=>a.displayName.compareTo(b.displayName));
    return list.take(limit).toList();
  }

  @override
  Future<int> friendsCount() async => _friends.length;
  @override
  Future<int> onlineFriendsCount() async => _friends.where((f)=>f.online).length;
  @override
  Future<int> newFriendsCount() async => _friends.where((f)=>f.isNew).length;

  @override
  Future<List<GroupDTO>> listGroups({String? q, int limit = 200}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    var res = _groups;
    if ((q ?? '').isNotEmpty) {
      final qq = q!.toLowerCase();
      res = res.where((g)=>g.title.toLowerCase().contains(qq)).toList();
    }
    return res.take(limit).toList();
  }

  @override
  Future<int> friendInvitesCount() async => _received.length;

  @override
  Future<List<FriendInviteDTO>> listFriendInvites({int limit = 50}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _received.take(limit).toList();
  }

  @override
  Future<List<FriendInviteDTO>> listSentFriendInvites({int limit = 50}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _sent.take(limit).toList();
  }

  @override
  Future<void> acceptFriendInvite(String inviteId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final idx = _received.indexWhere((i)=>i.id==inviteId);
    if (idx>=0) {
      final iv = _received.removeAt(idx);
      _friends.add(FriendDTO(id: 'u_${iv.id}', displayName: iv.displayName, online: false, isNew: true));
      _profiles['u_${iv.id}'] = UserProfileDTO(id: 'u_${iv.id}', displayName: iv.displayName, handle: iv.displayName.toLowerCase().replaceAll(' ', ''));
    }
  }

  @override
  Future<void> declineFriendInvite(String inviteId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _received.removeWhere((i)=>i.id==inviteId);
  }

  @override
  Future<void> cancelSentFriendInvite(String inviteId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _sent.removeWhere((i)=>i.id==inviteId);
  }

  @override
  Future<UserProfileDTO> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _profiles[userId] ?? UserProfileDTO(id: userId, displayName: 'User $userId', handle: 'user$userId');
  }

  @override
  Future<UserProfileDTO> myProfile() async => getProfile(_me);
}
