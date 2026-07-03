import '../models/wardrobe_item.dart';
import 'sample_data.dart';

/// Interface (abstract class) cho kho dữ liệu tủ đồ.
/// Cho phép hoán đổi cài đặt (InMemory ↔ Firestore) mà không ảnh hưởng
/// đến tầng ViewModel/View — áp dụng nguyên tắc Dependency Inversion.
abstract class WardrobeRepository {
  /// Lấy toàn bộ tủ đồ (mới nhất trước).
  Future<List<WardrobeItem>> fetchAll();

  /// Lấy một món đồ theo [id]. Trả về null nếu không tìm thấy.
  Future<WardrobeItem?> getById(String id);

  /// Thêm món đồ mới vào kho.
  Future<void> add(WardrobeItem item);

  /// Cập nhật thông tin món đồ đã có.
  Future<void> update(WardrobeItem item);

  /// Xóa món đồ theo [id].
  Future<void> delete(String id);

  /// Tăng số lần mặc (wearCount) và cập nhật [lastWornAt] cho món đồ [id].
  /// Phục vụ nhật ký OOTD và đa dạng hóa gợi ý (tránh gợi ý mãi 1 món).
  Future<void> markWorn(String id, DateTime when);
}

/// Cài đặt lưu trong bộ nhớ (RAM) — dùng cho giai đoạn chưa nối Firebase.
/// Dữ liệu mất sau khi khởi động lại app. Có thể seed bằng [sampleWardrobe()].
class InMemoryWardrobeRepository implements WardrobeRepository {
  /// [seed] = true → nạp dữ liệu mẫu vào kho khi khởi tạo.
  InMemoryWardrobeRepository({bool seed = true}) {
    if (seed) _items.addAll(sampleWardrobe());
  }

  final List<WardrobeItem> _items = [];

  @override
  Future<List<WardrobeItem>> fetchAll() async =>
      List.unmodifiable(_items.reversed); // mới nhất lên đầu

  @override
  Future<WardrobeItem?> getById(String id) async {
    for (final i in _items) {
      if (i.id == id) return i;
    }
    return null;
  }

  @override
  Future<void> add(WardrobeItem item) async => _items.add(item);

  @override
  Future<void> update(WardrobeItem item) async {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx != -1) _items[idx] = item;
  }

  @override
  Future<void> delete(String id) async => _items.removeWhere((e) => e.id == id);

  @override
  Future<void> markWorn(String id, DateTime when) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(
        wearCount: _items[idx].wearCount + 1, // tăng đếm mặc
        lastWornAt: when,                       // cập nhật ngày mặc gần nhất
      );
    }
  }
}
