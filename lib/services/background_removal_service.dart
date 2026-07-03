import 'dart:typed_data';

/// Dịch vụ tách nền ảnh trang phục.
/// Nhận ảnh gốc dạng bytes, trả về ảnh PNG với nền trong suốt.
///
/// Các cài đặt:
/// - [RemoveBgBackgroundRemovalService]: tách nền bằng API remove.bg (chất lượng cao nhất, cần internet).
/// - [MlKitBackgroundRemovalService]: tách nền on-device bằng Google ML Kit (miễn phí, offline).
/// - [FallbackBackgroundRemovalService]: thử remove.bg → fallback sang ML Kit.
/// - [MockBackgroundRemovalService]: giữ nguyên ảnh gốc (dùng khi demo/test).
abstract class BackgroundRemovalService {
  /// Nhận [imageBytes] ảnh gốc, trả về bytes ảnh đã tách nền (PNG nền trong suốt).
  Future<Uint8List> removeBackground(Uint8List imageBytes);
}

/// Bản mock — giả lập độ trễ xử lý nhưng trả lại ảnh gốc (không tách nền thật).
/// Dùng để kiểm thử toàn bộ pipeline mà không cần API key hay ML model.
class MockBackgroundRemovalService implements BackgroundRemovalService {
  @override
  Future<Uint8List> removeBackground(Uint8List imageBytes) async {
    await Future<void>.delayed(const Duration(milliseconds: 400)); // giả lập thời gian xử lý
    return imageBytes; // trả lại ảnh gốc không thay đổi
  }
}
