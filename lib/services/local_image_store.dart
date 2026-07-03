import 'dart:typed_data';

/// Kho ảnh tạm trong bộ nhớ RAM — lưu bytes ảnh cho các món đồ trong phiên hiện tại.
///
/// Mục đích: Cho phép hiển thị ảnh ngay khi chưa upload lên Cloudinary/Firebase Storage.
/// Khi có URL từ Storage, widget sẽ dùng URL thay vì kho cục bộ này.
///
/// Lưu ý: Dữ liệu mất khi app bị tắt hoàn toàn.
class LocalImageStore {
  final Map<String, Uint8List> _images = {};

  /// Lưu ảnh [bytes] vào kho với khóa [id] (thường là itemId hoặc 'profile-avatar').
  void put(String id, Uint8List bytes) => _images[id] = bytes;

  /// Lấy ảnh theo [id]. Trả về null nếu chưa có trong kho.
  Uint8List? get(String id) => _images[id];

  /// Xóa ảnh theo [id] — dùng khi xóa món đồ để giải phóng RAM.
  void remove(String id) => _images.remove(id);
}
