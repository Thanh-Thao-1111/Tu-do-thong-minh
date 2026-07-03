import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:path_provider/path_provider.dart';

import 'background_removal_service.dart';

/// Tách nền ảnh trang phục bằng Google ML Kit Subject Segmentation.
///
/// Chạy on-device: miễn phí, không giới hạn số ảnh, hoạt động offline.
/// Chỉ hỗ trợ Android. Nếu lỗi hoặc không tách được → trả lại ảnh gốc để
/// luồng thêm đồ vẫn chạy bình thường.
class MlKitBackgroundRemovalService implements BackgroundRemovalService {
  // Chỉ cần ảnh tiền cảnh (nền trong suốt), không cần mask hay tách nhiều chủ thể.
  final SubjectSegmenter _segmenter = SubjectSegmenter(
    options: SubjectSegmenterOptions(
      enableForegroundBitmap: true,
      enableForegroundConfidenceMask: false,
      enableMultipleSubjects: SubjectResultOptions(
        enableConfidenceMask: false,
        enableSubjectBitmap: false,
      ),
    ),
  );

  @override
  Future<Uint8List> removeBackground(Uint8List imageBytes) async {
    // ML Kit nhận ảnh qua đường dẫn file → ghi tạm ra bộ nhớ cache.
    File? temp;
    try {
      final dir = await getTemporaryDirectory();
      temp = File(
        '${dir.path}/bg_input_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await temp.writeAsBytes(imageBytes, flush: true);

      final result =
          await _segmenter.processImage(InputImage.fromFilePath(temp.path));
      // foregroundBitmap là PNG nền trong suốt; null khi không nhận ra chủ thể.
      return result.foregroundBitmap ?? imageBytes;
    } catch (_) {
      return imageBytes; // lỗi -> giữ ảnh gốc
    } finally {
      if (temp != null) {
        try {
          await temp.delete();
        } catch (_) {
          // bỏ qua nếu xóa file tạm thất bại
        }
      }
    }
  }
}