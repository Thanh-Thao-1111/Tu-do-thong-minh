import 'dart:async';

import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';

/// Quản lý trạng thái xác thực người dùng:
/// theo dõi đăng nhập qua stream, xử lý đăng nhập/đăng ký/quên mật khẩu.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo) {
    // Lắng nghe stream trạng thái đăng nhập từ Firebase Auth.
    // Khi trạng thái thay đổi (đăng nhập/đăng xuất), cập nhật _user ngay.
    _sub = _repo.authStateChanges().listen((u) {
      _user = u;
      _initializing = false; // đã xác định được trạng thái ban đầu
      notifyListeners();
    });
  }

  final AuthRepository _repo;
  StreamSubscription<AppUser?>? _sub; // subscription cần hủy khi dispose

  AppUser? _user;

  /// Người dùng hiện tại. Null nếu chưa đăng nhập.
  AppUser? get user => _user;

  bool _initializing = true;

  /// True trong lúc chờ Firebase xác định trạng thái đăng nhập ban đầu.
  /// Dùng để hiện splash screen thay vì nhảy màn hình login sớm.
  bool get initializing => _initializing;

  bool _busy = false;

  /// True khi đang thực hiện thao tác đăng nhập/đăng ký (hiện loading indicator).
  bool get busy => _busy;

  String? _error;

  /// Thông báo lỗi thân thiện với người dùng từ lần thao tác gần nhất.
  String? get error => _error;

  /// Đăng nhập bằng email/mật khẩu. Trả về true nếu thành công.
  Future<bool> signIn(String email, String password) =>
      _run(() => _repo.signInWithEmail(email, password));

  /// Đăng ký tài khoản mới. Trả về true nếu thành công.
  Future<bool> signUp(String email, String password, String displayName) =>
      _run(() =>
          _repo.signUpWithEmail(email, password, displayName: displayName));

  /// Gửi email đặt lại mật khẩu đến [email]. Trả về true nếu gửi thành công.
  Future<bool> sendPasswordReset(String email) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.sendPasswordReset(email);
      _busy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendly(e);
      _busy = false;
      notifyListeners();
      return false;
    }
  }

  /// Wrapper chạy thao tác auth: bật loading, gọi [action], xử lý lỗi.
  Future<bool> _run(Future<AppUser> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _busy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendly(e);
      _busy = false;
      notifyListeners();
      return false;
    }
  }

  /// Đăng xuất — xóa session Firebase Auth.
  Future<void> signOut() => _repo.signOut();

  /// Chuyển lỗi Firebase Auth thành thông báo tiếng Việt thân thiện.
  String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('invalid-email')) return 'Email không hợp lệ.';
    if (s.contains('user-not-found')) return 'Tài khoản không tồn tại.';
    if (s.contains('wrong-password') || s.contains('invalid-credential')) {
      return 'Email hoặc mật khẩu không đúng.';
    }
    if (s.contains('email-already-in-use')) return 'Email này đã được đăng ký.';
    if (s.contains('weak-password')) {
      return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
    }
    if (s.contains('network')) return 'Lỗi mạng, vui lòng thử lại.';
    if (s.contains('too-many-requests')) return 'Thử lại sau ít phút.';
    return 'Có lỗi xảy ra, vui lòng thử lại.';
  }

  @override
  void dispose() {
    _sub?.cancel(); // hủy lắng nghe stream để tránh memory leak
    super.dispose();
  }
}
