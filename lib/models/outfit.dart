import 'package:uuid/uuid.dart';

import 'enums.dart';
import 'wardrobe_item.dart';

/// Một bộ trang phục (outfit) — tập hợp các món đồ thuộc các vai trò khác nhau.
/// Ràng buộc hợp lệ: phải có (áo + quần) hoặc (váy/đầm); không được trùng vai trò.
class Outfit {
  Outfit({
    required this.id,
    required this.items,
    this.occasion,
    this.score = 0,
    this.scoreBreakdown = const {},
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// ID duy nhất của outfit (UUID v4).
  final String id;

  /// Danh sách các món đồ trong bộ.
  final List<WardrobeItem> items;

  /// Ngữ cảnh mà outfit này được sinh ra cho (vd: Occasion.work, Occasion.date).
  final Occasion? occasion;

  /// Điểm phù hợp tổng hợp (0.0 – 1.0) do thuật toán gợi ý tính toán.
  /// Càng cao càng phù hợp với ngữ cảnh, thời tiết và phong cách người dùng.
  final double score;

  /// Chi tiết điểm từng tiêu chí: "color", "style", "weather", "occasion", "variety".
  final Map<String, double> scoreBreakdown;

  /// Thời điểm tạo outfit — dùng để sắp xếp và lưu trữ.
  final DateTime createdAt;

  /// Danh sách ID của từng món đồ (tiện cho lưu Firestore mà không cần lưu cả object).
  List<String> get itemIds => items.map((e) => e.id).toList();

  /// Tìm món đồ thuộc danh mục [c] trong bộ. Trả về null nếu không có.
  WardrobeItem? itemByCategory(ClothingCategory c) {
    for (final item in items) {
      if (item.category == c) return item;
    }
    return null;
  }

  /// Outfit hợp lệ khi có đủ thành phần bắt buộc:
  /// - Có váy/đầm (dress), HOẶC
  /// - Có cả áo (top) lẫn quần (bottom).
  bool get isValid {
    final hasDress = items.any((i) => i.category == ClothingCategory.dress);
    final hasTop = items.any((i) => i.category == ClothingCategory.top);
    final hasBottom = items.any((i) => i.category == ClothingCategory.bottom);
    return hasDress || (hasTop && hasBottom);
  }

  /// Chuyển sang Map để lưu lên Firestore.
  /// Lưu ý: chỉ lưu itemIds, không lưu object WardrobeItem đầy đủ.
  Map<String, dynamic> toMap() => {
        'itemIds': itemIds,
        'occasion': occasion?.name,
        'score': score,
        'scoreBreakdown': scoreBreakdown,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Khôi phục Outfit từ dữ liệu Firestore.
  /// **Lưu ý**: [items] sẽ là danh sách rỗng vì Firestore chỉ lưu itemIds.
  /// Cần join với WardrobeRepository ở tầng trên để lấy object đầy đủ.
  factory Outfit.fromMap(String id, Map<String, dynamic> map) {
    return Outfit(
      id: id,
      items: const [],                     // itemIds lưu riêng, resolve ở tầng repository
      occasion: Occasion.fromName(map['occasion'] as String?),
      score: (map['score'] as num? ?? 0).toDouble(),
      scoreBreakdown: {
        for (final e
            in ((map['scoreBreakdown'] as Map?)?.entries ?? <MapEntry>[]))
          e.key as String: (e.value as num).toDouble(),
      },
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  /// Tạo ID ngẫu nhiên (UUID v4) cho outfit mới.
  static String generateId() => const Uuid().v4();
}
