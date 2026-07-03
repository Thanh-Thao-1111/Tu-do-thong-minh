import 'clothing_color.dart';
import 'enums.dart';

/// Một món đồ trong tủ đồ — đơn vị dữ liệu trung tâm của hệ thống.
/// Toàn bộ metadata được chuẩn hóa để phục vụ lưu trữ, lọc và gợi ý phối đồ.
class WardrobeItem {
  WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    this.originalImageUrl,
    this.localImagePath,
    this.subtype,
    this.colors = const [],
    this.styles = const [],
    this.seasons = const [],
    this.occasions = const [],
    this.pattern,
    this.material,
    this.wearCount = 0,
    this.lastWornAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// ID duy nhất của món đồ (Firestore document ID).
  final String id;

  /// Tên hiển thị (vd: "Áo thun trắng basic").
  final String name;

  /// Danh mục chính (áo, quần, váy, áo khoác, giày, phụ kiện).
  final ClothingCategory category;

  /// Loại cụ thể trong danh mục (vd: "Áo thun", "Quần jeans"). Có thể null.
  final String? subtype;

  /// URL ảnh đã tách nền trên Cloudinary. Null khi chưa upload.
  final String? imageUrl;

  /// URL ảnh gốc (trước khi tách nền) trên Cloudinary. Null khi chưa upload.
  final String? originalImageUrl;

  /// Đường dẫn ảnh lưu cục bộ trên thiết bị — dùng khi chưa nối Cloudinary.
  final String? localImagePath;

  /// Danh sách màu sắc của món đồ (có thể nhiều màu).
  final List<ClothingColor> colors;

  /// Phong cách phù hợp (vd: casual, formal, streetwear...).
  final List<StyleTag> styles;

  /// Mùa/thời tiết phù hợp (vd: summer, winter...).
  final List<Season> seasons;

  /// Ngữ cảnh phù hợp (vd: work, date, casual...).
  final List<Occasion> occasions;

  /// Hoa văn (vd: "Trơn", "Kẻ sọc", "Chấm bi"). Null nếu không rõ.
  final String? pattern;

  /// Chất liệu (vd: "Cotton", "Denim", "Len"). Null nếu không rõ.
  final String? material;

  /// Số lần đã mặc — dùng để thống kê "trang phục hay dùng nhất".
  final int wearCount;

  /// Thời điểm mặc gần nhất — dùng cho "Trang phục gần đây" ở Trang chủ.
  final DateTime? lastWornAt;

  /// Thời điểm thêm vào tủ đồ.
  final DateTime createdAt;

  /// Màu chủ đạo (màu đầu tiên trong danh sách) — tiện cho hiển thị và so khớp nhanh.
  ClothingColor? get primaryColor => colors.isNotEmpty ? colors.first : null;

  /// Tạo bản sao với một số field được thay thế.
  WardrobeItem copyWith({
    String? id,
    String? name,
    ClothingCategory? category,
    String? subtype,
    String? imageUrl,
    String? originalImageUrl,
    String? localImagePath,
    List<ClothingColor>? colors,
    List<StyleTag>? styles,
    List<Season>? seasons,
    List<Occasion>? occasions,
    String? pattern,
    String? material,
    int? wearCount,
    DateTime? lastWornAt,
    DateTime? createdAt,
  }) {
    return WardrobeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subtype: subtype ?? this.subtype,
      imageUrl: imageUrl ?? this.imageUrl,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      colors: colors ?? this.colors,
      styles: styles ?? this.styles,
      seasons: seasons ?? this.seasons,
      occasions: occasions ?? this.occasions,
      pattern: pattern ?? this.pattern,
      material: material ?? this.material,
      wearCount: wearCount ?? this.wearCount,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Chuyển sang Map để lưu lên Firestore.
  /// Lưu ý: không lưu [localImagePath] vì đây chỉ là đường dẫn cục bộ.
  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category.name,                                    // lưu tên enum
        'subtype': subtype,
        'imageUrl': imageUrl,
        'originalImageUrl': originalImageUrl,
        'colors': colors.map((c) => c.toMap()).toList(),
        'styles': styles.map((s) => s.name).toList(),
        'seasons': seasons.map((s) => s.name).toList(),
        'occasions': occasions.map((o) => o.name).toList(),
        'pattern': pattern,
        'material': material,
        'wearCount': wearCount,
        'lastWornAt': lastWornAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  /// Khôi phục WardrobeItem từ dữ liệu Firestore.
  /// [id] là document ID, [map] là dữ liệu trong document.
  factory WardrobeItem.fromMap(String id, Map<String, dynamic> map) {
    return WardrobeItem(
      id: id,
      name: (map['name'] ?? '') as String,
      category: ClothingCategory.fromName(map['category'] as String?),
      subtype: map['subtype'] as String?,
      imageUrl: map['imageUrl'] as String?,
      originalImageUrl: map['originalImageUrl'] as String?,
      colors: ((map['colors'] as List?) ?? [])
          .map((e) => ClothingColor.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      styles: ((map['styles'] as List?) ?? [])
          .map((e) => StyleTag.fromName(e as String?))
          .toList(),
      seasons: ((map['seasons'] as List?) ?? [])
          .map((e) => Season.fromName(e as String?))
          .toList(),
      occasions: ((map['occasions'] as List?) ?? [])
          .map((e) => Occasion.fromName(e as String?))
          .toList(),
      pattern: map['pattern'] as String?,
      material: map['material'] as String?,
      wearCount: (map['wearCount'] ?? 0) as int,
      lastWornAt: map['lastWornAt'] != null
          ? DateTime.tryParse(map['lastWornAt'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }
}
