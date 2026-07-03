import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'local_image_store.dart';

/// Khóa cố định cho ảnh đại diện trong LocalImageStore.
/// Dùng cho cả upload local và Firebase để nhất quán tra cứu.
const kAvatarLocalKey = 'profile-avatar';

/// Interface dịch vụ lưu ảnh trang phục và ảnh đại diện.
///
/// Trả về định danh (URL hoặc khóa cục bộ) để gán vào:
/// - `WardrobeItem.imageUrl` — ảnh món đồ.
/// - `UserProfile.avatarId` — ảnh đại diện.
///
/// Các cài đặt:
/// - [LocalImageStorageService]: lưu trong RAM, dùng khi chưa nối Firebase.
/// - [FirebaseImageStorageService]: upload lên Firebase Storage, trả về download URL.
/// - [CloudinaryImageStorageService]: upload lên Cloudinary, trả về secure_url.
abstract class ImageStorageService {
  /// Lưu ảnh món đồ [itemId].
  /// Trả về URL (Firebase/Cloudinary) hoặc null (cục bộ — ảnh trong LocalImageStore).
  Future<String?> uploadItemImage(String itemId, Uint8List bytes);

  /// Lưu ảnh đại diện.
  /// Trả về URL (Firebase/Cloudinary) hoặc khóa cục bộ [kAvatarLocalKey].
  Future<String?> uploadAvatar(Uint8List bytes);
}

/// Bản cục bộ — lưu ảnh trong RAM, không cần internet.
/// Dùng khi chưa cấu hình Firebase Storage hay Cloudinary.
class LocalImageStorageService implements ImageStorageService {
  LocalImageStorageService(this._store);

  final LocalImageStore _store;

  @override
  Future<String?> uploadItemImage(String itemId, Uint8List bytes) async {
    _store.put(itemId, bytes);
    return null; // null = ảnh sẽ hiển thị qua LocalImageStore theo itemId
  }

  @override
  Future<String?> uploadAvatar(Uint8List bytes) async {
    _store.put(kAvatarLocalKey, bytes);
    return kAvatarLocalKey; // trả về khóa cục bộ
  }
}

/// Bản Firebase Storage — upload vào đường dẫn `users/{uid}/...`.
/// Tự fallback về [_fallback] (LocalImageStore) nếu Storage chưa bật hoặc lỗi
/// → app vẫn hiển thị ảnh bình thường trong phiên hiện tại.
class FirebaseImageStorageService implements ImageStorageService {
  FirebaseImageStorageService(this._storage, this._auth, this._fallback);

  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final LocalImageStore _fallback; // kho cục bộ để hiển thị ngay + làm dự phòng

  /// UID người dùng hiện tại — dùng làm tiền tố đường dẫn Storage.
  String get _uid => _auth.currentUser?.uid ?? 'anonymous';

  @override
  Future<String?> uploadItemImage(String itemId, Uint8List bytes) async {
    _fallback.put(itemId, bytes); // lưu cục bộ NGAY để hiển thị tức thì
    try {
      final ref = _storage.ref('users/$_uid/items/$itemId.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL(); // trả về URL tải xuống
    } catch (_) {
      return null; // lỗi → UI sẽ dùng LocalImageStore
    }
  }

  @override
  Future<String?> uploadAvatar(Uint8List bytes) async {
    try {
      final ref = _storage.ref('users/$_uid/avatar.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (_) {
      _fallback.put(kAvatarLocalKey, bytes); // fallback cục bộ
      return kAvatarLocalKey;
    }
  }
}
