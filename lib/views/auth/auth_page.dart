import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Màn đăng nhập / đăng ký bằng email + mật khẩu.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _name = TextEditingController();
  bool _isLogin = true;
  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _name.dispose();
    super.dispose();
  }

  void _toggleMode() => setState(() {
        _isLogin = !_isLogin;
        _error = null;
      });

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final email = _email.text.trim();
    final pass = _password.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Vui lòng nhập email hợp lệ.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Mật khẩu tối thiểu 6 ký tự.');
      return;
    }
    if (!_isLogin && pass != _confirm.text) {
      setState(() => _error = 'Mật khẩu xác nhận không khớp.');
      return;
    }
    final vm = context.read<AuthViewModel>();
    final ok = _isLogin
        ? await vm.signIn(email, pass)
        : await vm.signUp(email, pass, _name.text);
    if (!ok && mounted) setState(() => _error = vm.error);
    // Nếu thành công, AuthGate tự chuyển sang màn chính.
  }

  Future<void> _forgotPassword() async {
    FocusScope.of(context).unfocus();
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => _ForgotPasswordDialog(initialEmail: _email.text.trim()),
    );
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Đã gửi email đặt lại mật khẩu. Hãy kiểm tra hộp thư (cả Spam).'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthViewModel>().busy;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner Image
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/app.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
              const SizedBox(height: 28),
              
              // Welcome title
              Center(
                child: Text(
                  _isLogin ? 'Chào mừng trở lại!' : 'Tạo tài khoản mới',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A), // slate-900
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Form Labels and Fields
              _label('EMAIL'),
              const SizedBox(height: 8),
              _field(_email, 'Nhập địa chỉ email', Icons.email_outlined,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _label('MẬT KHẨU'),
              const SizedBox(height: 8),
              _field(
                _password,
                'Nhập mật khẩu',
                Icons.lock_outline_rounded,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF9CA3AF),
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              if (!_isLogin) ...[
                const SizedBox(height: 16),
                _label('XÁC THỰC MẬT KHẨU'),
                const SizedBox(height: 8),
                _field(
                  _confirm,
                  'Nhập mật khẩu',
                  Icons.lock_outline_rounded,
                  obscure: _obscureConfirm,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF9CA3AF),
                    ),
                    onPressed: () => setState(
                        () => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ],
              
              // Forgot Password link (only for login)
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: TextButton(
                      onPressed: busy ? null : _forgotPassword,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF10B981),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ),
                ),

              // Error banner
              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppPalette.error, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              color: AppPalette.error, fontSize: 13)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: busy ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _isLogin ? 'Đăng nhập' : 'Đăng ký',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              // "hoặc tiếp tục với" divider
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFE5E7EB),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _isLogin ? 'HOẶC TIẾP TỤC VỚI' : 'HOẶC ĐĂNG KÝ VỚI',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFE5E7EB),
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              // Social Auth Buttons (Google & Facebook in side-by-side Row)
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _socialButton(
                      icon: const Text(
                        'G',
                        style: TextStyle(
                          color: Color(0xFF4285F4),
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          fontFamily: 'Product Sans',
                        ),
                      ),
                      label: 'Google',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tính năng đăng nhập Google đang được phát triển.'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _socialButton(
                      icon: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1877F2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'f',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.1,
                          ),
                        ),
                      ),
                      label: 'Facebook',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tính năng đăng nhập Facebook đang được phát triển.'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Bottom navigation toggle
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: busy ? null : _toggleMode,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'Inter',
                        ),
                        children: [
                          TextSpan(
                            text: _isLogin
                                ? 'Chưa có tài khoản? '
                                : 'Đã có tài khoản? ',
                            style: const TextStyle(color: Color(0xFF6B7280)),
                          ),
                          TextSpan(
                            text: _isLogin ? 'Đăng ký' : 'Đăng nhập',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6B7280),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscure = false,
    TextInputType? keyboard,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(icon, color: const Color(0xFF9CA3AF), size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 0),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppPalette.primary, width: 1.8),
        ),
      ),
      style: const TextStyle(fontSize: 16, color: AppPalette.ink),
    );
  }

  Widget _socialButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F2937),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hộp thoại "Quên mật khẩu" — StatefulWidget để tự quản vòng đời controller
/// (tránh lỗi dùng TextEditingController sau khi dispose lúc đóng dialog).
class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({this.initialEmail});
  final String? initialEmail;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _email =
      TextEditingController(text: widget.initialEmail ?? '');
  bool _sending = false;
  String? _err;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _err = 'Vui lòng nhập email hợp lệ.');
      return;
    }
    setState(() {
      _sending = true;
      _err = null;
    });
    final vm = context.read<AuthViewModel>();
    final ok = await vm.sendPasswordReset(email);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _sending = false;
        _err = vm.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quên mật khẩu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập email tài khoản, chúng tôi sẽ gửi liên kết đặt lại mật khẩu '
            'vào hộp thư của bạn.',
            style: TextStyle(fontSize: 13, color: AppPalette.inkSoft),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            onSubmitted: (_) => _sending ? null : _send(),
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          if (_err != null) ...[
            const SizedBox(height: 10),
            Text(_err!,
                style: const TextStyle(color: AppPalette.error, fontSize: 13)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _sending ? null : _send,
          child: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Gửi'),
        ),
      ],
    );
  }
}
