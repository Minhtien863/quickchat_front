import 'package:flutter/material.dart';
import '../../routes.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC  = TextEditingController();
  final _confirmC = TextEditingController();
  final _displayNameC = TextEditingController();
  final _phoneC = TextEditingController();

  bool _showPass = false;
  bool _showConfirm = false;
  bool _loading = false;
  String? _error;

  // Gợi ý tên hiển thị từ email
  void _suggestDisplayName(String email) {
    if (_displayNameC.text.isNotEmpty) return;
    final idx = email.indexOf('@');
    if (idx > 0) _displayNameC.text = email.substring(0, idx);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    // TODO: AuthServiceHttp.signUp(...) → điều hướng tới xác minh email (nếu dùng flow verify)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar: để sau (upload Cloudinary / chọn ảnh)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(radius: 28, child: Icon(Icons.person)),
                  title: const Text('Ảnh đại diện'),
                  subtitle: const Text('Chọn sau (sẽ bật khi có backend/upload)'),
                  onTap: () {/* TODO: mở picker & upload */},
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _emailC,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || v.isEmpty) ? 'Nhập email' : null,
                  onChanged: _suggestDisplayName,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _displayNameC,
                  decoration: const InputDecoration(labelText: 'Tên hiển thị'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Nhập tên hiển thị' : null,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _phoneC,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _passC,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    suffixIcon: IconButton(
                      icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showPass = !_showPass),
                    ),
                  ),
                  obscureText: !_showPass,
                  validator: (v) => (v == null || v.length < 6) ? 'Tối thiểu 6 ký tự' : null,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _confirmC,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showConfirm = !_showConfirm),
                    ),
                  ),
                  obscureText: !_showConfirm,
                  validator: (v) => (v != _passC.text) ? 'Mật khẩu không khớp' : null,
                ),

                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],

                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Đăng ký'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.signIn),
                  child: const Text('Đã có tài khoản? Đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
