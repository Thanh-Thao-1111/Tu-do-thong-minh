import '../models/diary_entry.dart';

/// Interface cho kho dữ liệu nhật ký thời trang (OOTD).
/// Cho phép hoán đổi cài đặt (InMemory ↔ Firestore) mà không ảnh hưởng
/// đến ViewModel — áp dụng nguyên tắc Dependency Inversion.
abstract class DiaryRepository {
  /// Lấy toàn bộ danh sách nhật ký (mới nhất trước).
  Future<List<DiaryEntry>> fetchAll();

  /// Lấy mục nhật ký theo [day]. Trả về null nếu không có.
  Future<DiaryEntry?> getByDay(DateTime day);

  /// Lưu mục nhật ký (thêm mới hoặc ghi đè nếu đã có cùng id).
  Future<void> save(DiaryEntry entry);

  /// Xóa mục nhật ký theo [id].
  Future<void> delete(String id);
}

/// Cài đặt lưu trong bộ nhớ (RAM) — dùng khi chưa nối Firebase.
/// Dữ liệu mất sau khi khởi động lại app.
class InMemoryDiaryRepository implements DiaryRepository {
  final List<DiaryEntry> _entries = [];

  @override
  Future<List<DiaryEntry>> fetchAll() async {
    final list = [..._entries];
    list.sort((a, b) => b.date.compareTo(a.date)); // mới nhất trước
    return List.unmodifiable(list);
  }

  @override
  Future<DiaryEntry?> getByDay(DateTime day) async {
    final key = DiaryEntry(id: '', date: day, itemIds: const []).dayKey;
    for (final e in _entries) {
      if (e.dayKey == key) return e;
    }
    return null;
  }

  @override
  Future<void> save(DiaryEntry entry) async {
    // Cho phép nhiều bộ đồ trong cùng một ngày → khóa theo id, không theo dayKey.
    final idx = _entries.indexWhere((e) => e.id == entry.id);
    if (idx != -1) {
      _entries[idx] = entry; // ghi đè nếu đã tồn tại
    } else {
      _entries.add(entry);   // thêm mới
    }
  }

  @override
  Future<void> delete(String id) async =>
      _entries.removeWhere((e) => e.id == id);
}
