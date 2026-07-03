import 'enums.dart';

/// Giới tính — phục vụ cá nhân hóa gợi ý phối đồ trong tương lai.
enum Gender {
  female(label: 'Nữ'),
  male(label: 'Nam'),
  other(label: 'Khác');

  const Gender({required this.label});

  /// Tên hiển thị tiếng Việt.
  final String label;

  /// Chuyển tên enum string → Gender. Trả về null nếu không tìm thấy.
  static Gender? fromName(String? name) {
    if (name == null) return null;
    for (final g in Gender.values) {
      if (g.name == name) return g;
    }
    return null;
  }
}

/// Hồ sơ cá nhân của người dùng — lưu thông tin và sở thích
/// để cá nhân hóa trải nghiệm và gợi ý phối đồ.
class UserProfile {
  UserProfile({
    required this.id,
    required this.displayName,
    this.avatarId,
    this.gender,
    this.city,
    this.birthday,
    this.preferredStyles = const [],
    this.bio,
  });

  /// ID người dùng (khớp với Firebase Auth UID hoặc 'me' nếu dùng local).
  final String id;

  /// Tên hiển thị.
  final String displayName;

  /// Khóa ảnh đại diện trong LocalImageStore (hoặc URL trên Cloudinary).
  final String? avatarId;

  /// Giới tính (tùy chọn).
  final Gender? gender;

  /// Thành phố — dùng để lấy thời tiết mặc định khi GPS không khả dụng.
  final String? city;

  /// Ngày sinh (tùy chọn).
  final DateTime? birthday;

  /// Danh sách phong cách yêu thích — dùng để ưu tiên trong thuật toán gợi ý.
  final List<StyleTag> preferredStyles;

  /// Tiểu sử ngắn (tùy chọn).
  final String? bio;

  /// Chữ cái đầu của tên — dùng làm avatar mặc định khi chưa có ảnh.
  String get initial =>
      displayName.trim().isEmpty ? '?' : displayName.trim()[0].toUpperCase();

  /// Tạo bản sao với một số field được thay thế.
  UserProfile copyWith({
    String? displayName,
    String? avatarId,
    Gender? gender,
    String? city,
    DateTime? birthday,
    List<StyleTag>? preferredStyles,
    String? bio,
  }) =>
      UserProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        avatarId: avatarId ?? this.avatarId,
        gender: gender ?? this.gender,
        city: city ?? this.city,
        birthday: birthday ?? this.birthday,
        preferredStyles: preferredStyles ?? this.preferredStyles,
        bio: bio ?? this.bio,
      );

  /// Chuyển sang Map để lưu lên Firestore.
  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'avatarId': avatarId,
        'gender': gender?.name,                                      // lưu tên enum
        'city': city,
        'birthday': birthday?.toIso8601String(),
        'preferredStyles': preferredStyles.map((s) => s.name).toList(),
        'bio': bio,
      };

  /// Khôi phục UserProfile từ dữ liệu Firestore.
  factory UserProfile.fromMap(String id, Map<String, dynamic> map) => UserProfile(
        id: id,
        displayName: (map['displayName'] ?? 'Người dùng') as String,
        avatarId: map['avatarId'] as String?,
        gender: Gender.fromName(map['gender'] as String?),
        city: map['city'] as String?,
        birthday: map['birthday'] != null
            ? DateTime.tryParse(map['birthday'] as String)
            : null,
        preferredStyles: ((map['preferredStyles'] as List?) ?? [])
            .map((e) => StyleTag.fromName(e as String?))
            .toList(),
        bio: map['bio'] as String?,
      );

  /// Hồ sơ mặc định khi người dùng chưa thiết lập (lần đầu đăng nhập).
  factory UserProfile.initial() => UserProfile(
        id: 'me',
        displayName: 'Người dùng',
        bio: 'Chào mừng đến với tủ đồ thông minh của bạn!',
      );
}
