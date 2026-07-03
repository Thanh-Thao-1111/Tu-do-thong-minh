import 'package:flutter/foundation.dart';

import 'background_removal_service.dart';

/// Tách nền theo chiến lược fallback hai cấp:
///
/// **Luồng xử lý**:
/// 1. Thử [primary] (mặc định: ML Kit — miễn phí, chạy offline, on-device).
/// 2. Nếu [primary] trả về bytes giống hệt ảnh gốc (không tách được) hoặc
///    ném exception → thử [secondary] (mặc định: remove.bg API).
/// 3. Nếu [secondary] cũng thất bại → trả lại ảnh gốc (không tách nền).
///
/// **Tại sao kiểm tra "bytes giống hệt"?**
/// ML Kit trả về ảnh gốc không thay đổi khi không nhận ra chủ thể
/// (thay vì ném exception), nên cần so sánh bytes để phát hiện thất bại.
class FallbackBackgroundRemovalService implements BackgroundRemovalService {
  /// Dịch vụ tách nền ưu tiên (thường là ML Kit).
  final BackgroundRemovalService primary;

  /// Dịch vụ dự phòng nếu primary thất bại (thường là remove.bg). Có thể null.
  final BackgroundRemovalService? secondary;

  const FallbackBackgroundRemovalService({
    required this.primary,
    this.secondary,
  });

  @override
  Future<Uint8List> removeBackground(Uint8List imageBytes) async {
    // --- Bước 1: Thử primary ---
    Uint8List result;
    try {
      result = await primary.removeBackground(imageBytes);
    } catch (e) {
      debugPrint('⚠️ Primary tách nền exception: $e');
      result = imageBytes; // primary ném exception → coi như thất bại
    }

    // --- Bước 2: Nếu primary thất bại và có secondary → thử secondary ---
    if (_isSameBytes(result, imageBytes) && secondary != null) {
      debugPrint('⚠️ Primary trả ảnh gốc → chuyển sang secondary...');
      try {
        result = await secondary!.removeBackground(imageBytes);
        if (!_isSameBytes(result, imageBytes)) {
          debugPrint('✅ Secondary tách nền thành công');
        } else {
          debugPrint('❌ Secondary cũng trả ảnh gốc');
        }
      } catch (e) {
        debugPrint('❌ Secondary tách nền exception: $e');
        result = imageBytes; // secondary cũng lỗi → giữ ảnh gốc
      }
    }

    return result;
  }

  /// So sánh nhanh hai [Uint8List] có nội dung giống nhau không.
  ///
  /// **Chiến lược**: So sánh toàn bộ với ảnh nhỏ; với ảnh lớn (>10KB)
  /// chỉ kiểm tra mỗi 1/100 byte (lấy mẫu) để tránh chậm.
  bool _isSameBytes(Uint8List a, Uint8List b) {
    if (identical(a, b)) return true;              // cùng tham chiếu
    if (a.length != b.length) return false;        // khác kích thước → khác
    final step = a.length > 10000 ? a.length ~/ 100 : 1; // bước lấy mẫu
    for (var i = 0; i < a.length; i += step) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
