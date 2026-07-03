import '../models/outfit.dart';

/// Interface cho kho dữ liệu outfit đã lưu.
/// Cho phép hoán đổi cài đặt (InMemory ↔ Firestore) mà không ảnh hưởng
/// đến ViewModel — áp dụng nguyên tắc Dependency Inversion.
abstract class OutfitRepository {
  /// Lấy toàn bộ outfit đã lưu (mới nhất trước).
  Future<List<Outfit>> fetchAll();

  /// Lưu [outfit] (thêm mới nếu chưa có, ghi đè nếu đã có cùng id).
  Future<void> save(Outfit outfit);

  /// Xóa outfit theo [id].
  Future<void> delete(String id);
}

/// Cài đặt lưu trong bộ nhớ (RAM) — dùng khi chưa nối Firebase.
/// Dữ liệu mất sau khi khởi động lại app.
class InMemoryOutfitRepository implements OutfitRepository {
  final List<Outfit> _outfits = [];

  @override
  Future<List<Outfit>> fetchAll() async {
    final list = [..._outfits];
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // mới nhất trước
    return List.unmodifiable(list);
  }

  @override
  Future<void> save(Outfit outfit) async {
    final idx = _outfits.indexWhere((e) => e.id == outfit.id);
    if (idx != -1) {
      _outfits[idx] = outfit; // ghi đè nếu đã tồn tại
    } else {
      _outfits.add(outfit);   // thêm mới
    }
  }

  @override
  Future<void> delete(String id) async =>
      _outfits.removeWhere((e) => e.id == id);
}
