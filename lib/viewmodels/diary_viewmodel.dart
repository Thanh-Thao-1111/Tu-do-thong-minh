import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/diary_entry.dart';
import '../models/wardrobe_item.dart';
import '../repositories/diary_repository.dart';
import '../repositories/wardrobe_repository.dart';

/// Quản lý trạng thái Nhật ký thời trang (OOTD):
/// danh sách bộ đồ theo ngày, lưu outfit đã mặc, tra cứu thông tin món đồ.
class DiaryViewModel extends ChangeNotifier {
  DiaryViewModel(this._diaryRepo, this._wardrobeRepo);

  final DiaryRepository _diaryRepo;
  final WardrobeRepository _wardrobeRepo;
  final _uuid = const Uuid(); // tạo UUID cho mục nhật ký mới

  bool _loading = false;

  /// True khi đang tải dữ liệu từ Firestore.
  bool get loading => _loading;

  List<DiaryEntry> _entries = [];

  /// Toàn bộ danh sách mục nhật ký (mới nhất trước).
  List<DiaryEntry> get entries => List.unmodifiable(_entries);

  /// Index tra cứu nhanh món đồ theo ID — tránh vòng lặp lồng nhau khi render.
  final Map<String, WardrobeItem> _itemIndex = {};

  /// Tra cứu WardrobeItem theo [id]. Trả về null nếu không tìm thấy.
  WardrobeItem? item(String id) => _itemIndex[id];

  /// Tải toàn bộ nhật ký + xây dựng index món đồ từ Firestore.
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _entries = await _diaryRepo.fetchAll();
    final items = await _wardrobeRepo.fetchAll();
    _itemIndex
      ..clear()
      ..addEntries(items.map((i) => MapEntry(i.id, i))); // map id → item
    _loading = false;
    notifyListeners();
  }

  /// Lưu một outfit đã mặc vào nhật ký theo [date] và cập nhật số lần mặc.
  ///
  /// **Chiến lược**: Cập nhật danh sách cục bộ NGAY (optimistic update) để UI
  /// phản hồi tức thì, sau đó ghi Firestore và đánh dấu worn SONG SONG ở nền.
  Future<void> logOutfit(
    List<String> itemIds, {
    required DateTime date,
    String? note,
    String? occasion,
    String? style,
  }) async {
    // Chuẩn hóa về 00:00 để nhóm đúng theo ngày.
    final normalized = DateTime(date.year, date.month, date.day);
    final entry = DiaryEntry(
      id: _uuid.v4(),
      date: normalized,
      itemIds: itemIds,
      note: note,
      occasion: occasion,
      style: style,
    );

    // Cập nhật cục bộ NGAY để giao diện phản hồi tức thì (không chờ mạng).
    _entries = [entry, ..._entries];
    notifyListeners();

    // Ghi Firestore + đánh dấu đã mặc SONG SONG (tránh nhiều lượt mạng tuần tự).
    // Dùng [date] (có giờ phút) cho lastWornAt để "Trang phục gần đây" sắp xếp đúng.
    await _diaryRepo.save(entry);
    await Future.wait(itemIds.map((id) => _wardrobeRepo.markWorn(id, date)));
  }

  /// Xóa mục nhật ký theo [id] rồi tải lại danh sách.
  Future<void> delete(String id) async {
    await _diaryRepo.delete(id);
    await load();
  }
}
