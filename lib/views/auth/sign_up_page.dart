import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../widgets/media_picker_sheet.dart';
import '../../services/service_registry.dart';
import '../../services/auth_service_http.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// BƯỚC 1 – ĐĂNG KÝ TÀI KHOẢN (email + password)
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey  = GlobalKey<FormState>();
  final _emailC   = TextEditingController();
  final _passC    = TextEditingController();
  final _confirmC = TextEditingController();

  bool _showPass    = false;
  bool _showConfirm = false;
  bool _loading     = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailC.text.trim();
    final pass  = _passC.text;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = Services.auth;
      if (auth is AuthServiceHttp) {
        await auth.startRegister(email: email, password: pass);
      } else {
        throw Exception('Auth service không hỗ trợ đăng ký OTP');
      }

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyEmailPage(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A84FF),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2DAAE1), Color(0xFF0A84FF)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        'QUICKCHAT',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.95),
                          fontSize: 20,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 18,
                            color: Colors.black26,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Đăng ký',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Email
                            TextFormField(
                              controller: _emailC,
                              decoration: buildAuthInputDecoration(
                                label: 'Email',
                                icon: Icons.email_outlined,
                                cs: cs,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                final t = v?.trim() ?? '';
                                if (t.isEmpty) return 'Nhập email';
                                if (!t.contains('@') || !t.contains('.')) {
                                  return 'Email không hợp lệ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),

                            // Mật khẩu
                            TextFormField(
                              controller: _passC,
                              decoration: buildAuthInputDecoration(
                                label: 'Mật khẩu',
                                icon: Icons.lock_outline,
                                cs: cs,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPass
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                        () => _showPass = !_showPass,
                                  ),
                                ),
                              ),
                              obscureText: !_showPass,
                              validator: (v) {
                                final t = v ?? '';
                                if (t.length < 6) {
                                  return 'Mật khẩu tối thiểu 6 ký tự';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),

                            // Xác nhận mật khẩu
                            TextFormField(
                              controller: _confirmC,
                              decoration: buildAuthInputDecoration(
                                label: 'Xác nhận mật khẩu',
                                icon: Icons.lock_reset_outlined,
                                cs: cs,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showConfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                        () => _showConfirm = !_showConfirm,
                                  ),
                                ),
                              ),
                              obscureText: !_showConfirm,
                              validator: (v) {
                                if (v != _passC.text) {
                                  return 'Mật khẩu không khớp';
                                }
                                return null;
                              },
                            ),

                            if (_error != null) ...[
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                      color: Colors.redAccent),
                                ),
                              ),
                            ],

                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _loading ? null : _submit,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  'Tiếp tục',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.signIn),
                      child: const Text(
                        'Đã có tài khoản? Đăng nhập',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// BƯỚC 2 – XÁC MINH EMAIL (OTP)
class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({super.key, required this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _otpC = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    final code = _otpC.text.trim();
    if (code.length < 4) {
      setState(() => _error = 'Mã xác minh không hợp lệ');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = Services.auth;
      if (auth is AuthServiceHttp) {
        await auth.verifyEmail(email: widget.email, code: code);
      } else {
        throw Exception('Auth service không hỗ trợ verify OTP');
      }

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CompleteProfilePage(email: widget.email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A84FF),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2DAAE1), Color(0xFF0A84FF)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 18,
                        color: Colors.black26,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Xác minh email',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Nhập mã OTP đã được gửi tới\n${widget.email}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _otpC,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: 'Nhập mã 6 chữ số',
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _error!,
                          style:
                          const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _verify,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'Xác nhận',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // TODO: resend OTP
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gửi lại mã (mock)'),
                            ),
                          );
                        },
                        child: const Text('Gửi lại mã'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// BƯỚC 3 – HOÀN TẤT HỒ SƠ (phone + displayName + avatar)
class CompleteProfilePage extends StatefulWidget {
  final String email;

  const CompleteProfilePage({super.key, required this.email});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey      = GlobalKey<FormState>();
  final _displayNameC = TextEditingController();
  final _phoneC       = TextEditingController();

  bool _loading = false;
  String? _error;
  String? _avatarUrl;

  /// CHỌN AVATAR: mở bottom sheet mới (camera + gallery)
  Future<void> _pickAvatar() async {
    final auth = Services.auth;
    if (auth is! AuthServiceHttp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Auth service hiện không hỗ trợ upload avatar')),
      );
      return;
    }

    final picker = ImagePicker();

    // mở bottom sheet, trả về File nếu user chọn ảnh (camera hoặc thư viện)
    final file = await showMediaPickerSheet(
      context,
      onTakePhoto: () async {
        final xFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (xFile == null) return null;
        return File(xFile.path);
      },
    );

    if (file == null) return; // user bấm ra ngoài hoặc không chọn

    await _uploadAvatarFile(auth, file);
  }

  Future<void> _uploadAvatarFile(AuthServiceHttp auth, File file) async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final updatedUser = await auth.uploadAvatar(file);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _avatarUrl = updatedUser.avatarUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật avatar thành công')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final displayName = _displayNameC.text.trim();
    final phone = _phoneC.text.trim().isEmpty
        ? null
        : _phoneC.text.trim();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = Services.auth;
      if (auth is AuthServiceHttp) {
        await auth.completeProfile(
          displayName: displayName,
          phone: phone,
          avatarAssetId: null, // hiện đang dùng uploadAvatar trực tiếp
        );
      } else {
        throw Exception('Auth service không hỗ trợ complete profile');
      }

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialProfile();
  }

  Future<void> _loadInitialProfile() async {
    try {
      final auth = Services.auth;
      if (auth is AuthServiceHttp) {
        final cached = await auth.currentUser();
        final user = cached ?? await auth.fetchMe();

        final emailLocal = widget.email.split('@').first;

        if (user.displayName.isNotEmpty &&
            user.displayName != emailLocal) {
          _displayNameC.text = user.displayName;
        } else {
          _displayNameC.text = '';
        }

        if (user.phone != null) _phoneC.text = user.phone!;
        _avatarUrl = user.avatarUrl;

        if (mounted) setState(() {});
      }
    } catch (_) {
      // ignore lỗi nhẹ
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A84FF),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2DAAE1), Color(0xFF0A84FF)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 18,
                        color: Colors.black26,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Hoàn tất hồ sơ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // avatar
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: _pickAvatar,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xFFE5F1FF),
                                backgroundImage:
                                _avatarUrl != null
                                    ? NetworkImage(_avatarUrl!)
                                    : null,
                                child: _avatarUrl == null
                                    ? const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Color(0xFF1F2933),
                                )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Ảnh đại diện',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Nhấn để chọn hoặc chụp ảnh',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // tên hiển thị
                        TextFormField(
                          controller: _displayNameC,
                          decoration: buildAuthInputDecoration(
                            label: 'Tên hiển thị',
                            icon: Icons.person_outline,
                            cs: cs,
                          ),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'Nhập tên hiển thị';
                            if (t.length < 2) return 'Tên quá ngắn';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // phone
                        TextFormField(
                          controller: _phoneC,
                          decoration: buildAuthInputDecoration(
                            label: 'Số điện thoại',
                            icon: Icons.phone_iphone_outlined,
                            cs: cs,
                          ),
                          keyboardType: TextInputType.phone,
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                  color: Colors.redAccent),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _loading ? null : _submit,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Hoàn tất',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper dùng chung cho input auth
InputDecoration buildAuthInputDecoration({
  required String label,
  required IconData icon,
  required ColorScheme cs,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    filled: true,
    fillColor: const Color(0xFFF5F7FB),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide(color: cs.primary, width: 1.4),
    ),
    contentPadding: const EdgeInsets.symmetric(
      vertical: 14,
      horizontal: 0,
    ),
  );
}
