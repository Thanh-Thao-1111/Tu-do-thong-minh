/// Cấu hình Cloudinary (lưu ảnh thay cho Firebase Storage).
///
/// Hai giá trị này KHÔNG phải bí mật (được phép nhúng trong app):
/// - [cloudName]: tên cloud, xem ở Dashboard Cloudinary.
/// - [uploadPreset]: tên một "upload preset" ở chế độ **Unsigned**
///   (Settings → Upload → Upload presets → Add → Signing Mode: Unsigned).
///
/// Khi cả hai được điền, app tự dùng Cloudinary cho ảnh; nếu để trống,
/// app fallback lưu ảnh cục bộ.
class CloudinaryConfig {
  CloudinaryConfig._();

  static const String cloudName = 'dimbefbuh';
  static const String uploadPreset = 'qfrvytex';

  /// Thư mục lưu trên Cloudinary (tùy chọn, cho gọn gàng).
  static const String folder = 'smart_wardrobe';

  static bool get isConfigured =>
      cloudName.isNotEmpty && uploadPreset.isNotEmpty;
}
