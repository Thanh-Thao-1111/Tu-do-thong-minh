/// Người dùng hiện tại của ứng dụng — đại diện cho Firebase Auth User.
class AppUser {
  const AppUser({required this.uid, this.email, this.displayName});

  /// UID duy nhất do Firebase Auth cấp.
  final String uid;

  /// Địa chỉ email đăng nhập (có thể null với đăng nhập social).
  final String? email;

  /// Tên hiển thị.
  final String? displayName;
}

/// Interface xác thực người dùng.
/// - Bản Firebase: bọc Firebase Auth (email/mật khẩu).
/// - Bản mock: luôn "đã đăng nhập" để chạy chế độ cục bộ không cần login.
abstract class AuthRepository {
  /// Người dùng đang đăng nhập. Null nếu chưa đăng nhập.
  AppUser? get currentUser;

  /// Stream trạng thái đăng nhập — emit null khi đăng xuất, AppUser khi đăng nhập.
  /// AuthViewModel lắng nghe stream này để cập nhật UI tự động.
  Stream<AppUser?> authStateChanges();

  /// Đăng nhập bằng email/mật khẩu. Ném exception nếu thất bại.
  Future<AppUser> signInWithEmail(String email, String password);

  /// Đăng ký tài khoản mới bằng email/mật khẩu. Ném exception nếu thất bại.
  Future<AppUser> signUpWithEmail(String email, String password,
      {String? displayName});

  /// Gửi email đặt lại mật khẩu cho [email].
  Future<void> sendPasswordReset(String email);

  /// Đăng xuất khỏi phiên hiện tại.
  Future<void> signOut();
}

/// Bản mock — luôn coi như đã đăng nhập (bỏ qua màn hình login).
/// Dùng để chạy app và demo mà không cần Firebase Auth.
class MockAuthRepository implements AuthRepository {
  static const _user = AppUser(uid: 'local-user', displayName: 'Bạn');

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authStateChanges() => Stream.value(_user); // luôn đăng nhập

  @override
  Future<AppUser> signInWithEmail(String email, String password) async => _user;

  @override
  Future<AppUser> signUpWithEmail(String email, String password,
          {String? displayName}) async =>
      _user;

  @override
  Future<void> sendPasswordReset(String email) async {} // không làm gì

  @override
  Future<void> signOut() async {} // không làm gì
}
