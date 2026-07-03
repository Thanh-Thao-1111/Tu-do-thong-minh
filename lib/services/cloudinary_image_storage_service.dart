import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/config/cloudinary_config.dart';
import 'image_storage_service.dart';
import 'local_image_store.dart';

/// Lưu ảnh lên Cloudinary qua unsigned upload preset.
///
/// **Luồng hoạt động**:
/// 1. Lưu bytes vào [LocalImageStore] ngay → ảnh hiển thị tức thì trên UI.
/// 2. Upload lên Cloudinary ở nền → nhận `secure_url` (https://...).
/// 3. URL được gán vào `imageUrl` của WardrobeItem và lưu Firestore.
/// 4. Nếu upload lỗi hoặc chưa cấu hình → fallback về kho cục bộ, app vẫn dùng được.
class CloudinaryImageStorageService implements ImageStorageService {
  CloudinaryImageStorageService(this._fallback);

  /// Kho cục bộ dùng để hiển thị ảnh ngay và làm fallback khi upload lỗi.
  final LocalImageStore _fallback;

  /// Gọi API Cloudinary upload ảnh [bytes] với tên file [filename].
  /// Trả về `secure_url` nếu thành công, null nếu thất bại.
  Future<String?> _upload(Uint8List bytes, String filename) async {
    if (!CloudinaryConfig.isConfigured) return null; // bỏ qua nếu chưa cấu hình
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = CloudinaryConfig.uploadPreset // unsigned preset
        ..fields['folder'] = CloudinaryConfig.folder              // thư mục smart_wardrobe
        ..files.add(http.MultipartFile.fromBytes('file', bytes,
            filename: filename));

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode == 200) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final url = json['secure_url'] as String?;
        return url == null ? null : _optimized(url); // tối ưu URL trước khi trả về
      }
      return null; // lỗi HTTP → để hàm gọi tự fallback
    } catch (_) {
      return null; // lỗi mạng hoặc parse → fallback
    }
  }

  /// Chèn biến đổi tối ưu vào URL Cloudinary: `f_auto` (WebP/AVIF tự động)
  /// và `q_auto` (chất lượng tự động) → ảnh nhẹ hơn, tải nhanh hơn.
  ///
  /// Ví dụ: `.../upload/sample.jpg` → `.../upload/f_auto,q_auto/sample.jpg`
  String _optimized(String url) {
    const marker = '/upload/';
    return url.contains(marker)
        ? url.replaceFirst(marker, '${marker}f_auto,q_auto/')
        : url;
  }

  @override
  Future<String?> uploadItemImage(String itemId, Uint8List bytes) async {
    _fallback.put(itemId, bytes); // lưu cục bộ NGAY để hiển thị tức thì
    return _upload(bytes, '$itemId.jpg');
  }

  @override
  Future<String?> uploadAvatar(Uint8List bytes) async {
    final url = await _upload(bytes, 'avatar.jpg');
    if (url != null) return url; // thành công → trả URL Cloudinary
    // Thất bại → lưu cục bộ và trả khóa cục bộ
    _fallback.put(kAvatarLocalKey, bytes);
    return kAvatarLocalKey;
  }
}
