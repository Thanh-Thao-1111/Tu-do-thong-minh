import '../models/user_profile.dart';

/// Interface cho kho dữ liệu hồ sơ cá nhân người dùng.
/// - Bản thật (Firebase): lưu vào Firestore theo uid của người dùng.
/// - Bản in-memory: lưu trong RAM, mất khi khởi động lại.
abstract class ProfileRepository {
  /// Lấy hồ sơ hiện tại. Trả về hồ sơ mặc định nếu chưa có.
  Future<UserProfile> fetch();

  /// Lưu hồ sơ [profile] (thêm mới hoặc ghi đè).
  Future<void> save(UserProfile profile);
}

/// Cài đặt lưu trong bộ nhớ (RAM) — dùng khi chưa nối Firebase.
/// Bắt đầu bằng [UserProfile.initial()] (tên "Người dùng").
class InMemoryProfileRepository implements ProfileRepository {
  UserProfile _profile = UserProfile.initial(); // hồ sơ mặc định

  @override
  Future<UserProfile> fetch() async => _profile;

  @override
  Future<void> save(UserProfile profile) async => _profile = profile;
}
