class HiddenChatPrefs {
  static final Map<String, _HiddenState> _map = {}; // conversationId -> state

  static bool isEnabled(String id) => _map[id]?.enabled == true;
  static bool hasPin(String id) => (_map[id]?.pin ?? '').isNotEmpty;

  static void enableWithPin(String id, String pin) {
    _map[id] = _HiddenState(enabled: true, pin: pin);
  }

  static void disableAndClear(String id) {
    _map[id] = _HiddenState(enabled: false, pin: '');
  }

  /// Chỉ kiểm tra PIN để mở khóa xem tạm; KHÔNG tắt trạng thái ẩn.
  static bool verifyPin(String id, String pin) => _map[id]?.pin == pin;
}

class _HiddenState {
  final bool enabled;
  final String pin;
  _HiddenState({required this.enabled, required this.pin});
}
