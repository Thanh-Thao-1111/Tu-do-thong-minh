import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/wardrobe_item.dart';
import '../repositories/wardrobe_repository.dart';

/// Quản lý trạng thái tủ đồ: tải danh sách, lọc theo loại/phong cách/màu,
/// tìm kiếm theo tên, và các thao tác CRUD (thêm, cập nhật, xóa).
class WardrobeViewModel extends ChangeNotifier {
  WardrobeViewModel(this._repo);

  final WardrobeRepository _repo;

  bool _loading = false;

  /// True khi đang tải dữ liệu từ Firestore.
  bool get loading => _loading;

  List<WardrobeItem> _all = [];

  /// Toàn bộ danh sách món đồ (bất biến — dùng unmodifiable để tránh sửa ngoài).
  List<WardrobeItem> get all => List.unmodifiable(_all);

  ClothingCategory? _categoryFilter;

  /// Bộ lọc theo danh mục đang active. Null = hiện tất cả.
  ClothingCategory? get categoryFilter => _categoryFilter;

  StyleTag? _styleFilter;

  /// Bộ lọc theo phong cách đang active. Null = hiện tất cả.
  StyleTag? get styleFilter => _styleFilter;

  String? _colorFilter;

  /// Bộ lọc theo tên màu đang active. Null = hiện tất cả.
  String? get colorFilter => _colorFilter;

  String _query = '';

  /// Chuỗi tìm kiếm theo tên món đồ.
  String get query => _query;

  /// Số bộ lọc nâng cao (màu + phong cách) đang được bật.
  /// Hiển thị trên badge của icon lọc để thông báo cho người dùng.
  int get activeFilterCount =>
      (_styleFilter != null ? 1 : 0) + (_colorFilter != null ? 1 : 0);

  /// Danh sách món đồ sau khi áp dụng tất cả bộ lọc:
  /// danh mục + phong cách + màu sắc + tìm kiếm theo tên.
  List<WardrobeItem> get items {
    return _all.where((i) {
      final matchCat =
          _categoryFilter == null || i.category == _categoryFilter;
      final matchStyle =
          _styleFilter == null || i.styles.contains(_styleFilter);
      final matchColor = _colorFilter == null ||
          i.colors.any((c) => c.name == _colorFilter);
      final matchQuery = _query.isEmpty ||
          i.name.toLowerCase().contains(_query.toLowerCase());
      return matchCat && matchStyle && matchColor && matchQuery;
    }).toList();
  }

  /// Tổng số món đồ trong tủ (không tính bộ lọc).
  int get totalCount => _all.length;

  /// Đếm số món đồ thuộc danh mục [c].
  int countByCategory(ClothingCategory c) =>
      _all.where((i) => i.category == c).length;

  /// Tải toàn bộ tủ đồ từ Firestore.
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _all = await _repo.fetchAll();
    _loading = false;
    notifyListeners();
  }

  /// Đặt bộ lọc danh mục. Truyền null để bỏ lọc.
  void setCategoryFilter(ClothingCategory? c) {
    _categoryFilter = c;
    notifyListeners();
  }

  /// Toggle bộ lọc phong cách [s]. Bấm lại để bỏ lọc.
  void setStyleFilter(StyleTag? s) {
    _styleFilter = _styleFilter == s ? null : s; // toggle
    notifyListeners();
  }

  /// Toggle bộ lọc màu theo tên [name]. Bấm lại để bỏ lọc.
  void setColorFilter(String? name) {
    _colorFilter = _colorFilter == name ? null : name; // toggle
    notifyListeners();
  }

  /// Xóa tất cả bộ lọc nâng cao (phong cách + màu).
  void clearFilters() {
    _styleFilter = null;
    _colorFilter = null;
    notifyListeners();
  }

  /// Cập nhật chuỗi tìm kiếm — lọc tức thì theo tên.
  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  /// Tìm một món đồ theo [id]. Trả về null nếu không có trong danh sách.
  WardrobeItem? byId(String id) =>
      _all.firstWhereOrNull((e) => e.id == id);

  /// Thêm [item] vào tủ đồ rồi tải lại danh sách.
  Future<void> add(WardrobeItem item) async {
    await _repo.add(item);
    await load();
  }

  /// Cập nhật thông tin [item] rồi tải lại danh sách.
  Future<void> update(WardrobeItem item) async {
    await _repo.update(item);
    await load();
  }

  /// Xóa món đồ theo [id] rồi tải lại danh sách.
  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load();
  }

  /// Đánh dấu món đồ [id] đã mặc vào thời điểm [when] — cập nhật wearCount + lastWornAt.
  Future<void> markWorn(String id, DateTime when) async {
    await _repo.markWorn(id, when);
    await load();
  }
}
