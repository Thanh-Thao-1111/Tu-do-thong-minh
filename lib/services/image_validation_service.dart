import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Kết quả kiểm tra chất lượng ảnh.
class ImageValidationResult {
  const ImageValidationResult._({
    required this.isValid,
    this.errorTitle,
    this.errorMessage,
    this.errorHint,
  });

  /// Ảnh hợp lệ, có thể đưa vào pipeline xử lý.
  const ImageValidationResult.valid()
      : this._(isValid: true);

  /// Ảnh không hợp lệ — kèm thông báo hiển thị cho người dùng.
  const ImageValidationResult.invalid({
    required String errorTitle,
    required String errorMessage,
    String? errorHint,
  }) : this._(
          isValid: false,
          errorTitle: errorTitle,
          errorMessage: errorMessage,
          errorHint: errorHint,
        );

  final bool isValid;
  final String? errorTitle;
  final String? errorMessage;
  final String? errorHint;
}

/// Kiểm tra chất lượng ảnh đầu vào trước khi đưa vào pipeline.
///
/// Thứ tự kiểm tra (fail fast — dừng tại lỗi đầu tiên):
/// 1. Dung lượng file
/// 2. Decode được ảnh / định dạng hợp lệ (JPEG, PNG, WebP, ...)
/// 3. Độ phân giải tối thiểu
/// 4. Độ sáng trung bình (phát hiện ảnh quá tối)
/// 5. Độ sắc nét — phương sai Laplacian (phát hiện ảnh quá mờ / blur)
class ImageValidationService {
  const ImageValidationService({
    this.maxFileSizeBytes = 15 * 1024 * 1024, // 15 MB
    this.minWidth = 200,
    this.minHeight = 200,
    this.minBrightness = 30.0, // 0–255; dưới ngưỡng này = quá tối
    this.minSharpness = 80.0,  // phương sai Laplacian; dưới = quá mờ
  });

  final int maxFileSizeBytes;
  final int minWidth;
  final int minHeight;
  final double minBrightness;
  final double minSharpness;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Kiểm tra toàn bộ điều kiện. Trả về [ImageValidationResult.valid()] nếu
  /// đạt hoặc [ImageValidationResult.invalid] kèm thông báo cụ thể.
  Future<ImageValidationResult> validate(Uint8List bytes) async {
    // 1. Kích thước file
    final sizeResult = _checkFileSize(bytes);
    if (!sizeResult.isValid) return sizeResult;

    // 2. Decode ảnh — kiểm tra định dạng đồng thời
    final image = img.decodeImage(bytes);
    if (image == null) {
      return const ImageValidationResult.invalid(
        errorTitle: 'Định dạng ảnh không hỗ trợ',
        errorMessage:
            'Ảnh này không thể đọc được. Hệ thống hỗ trợ JPEG, PNG và WebP.',
        errorHint: 'Vui lòng chọn ảnh khác hoặc chụp lại.',
      );
    }

    // 3. Độ phân giải
    final resResult = _checkResolution(image);
    if (!resResult.isValid) return resResult;

    // 4. Độ sáng
    final brightResult = _checkBrightness(image);
    if (!brightResult.isValid) return brightResult;

    // 5. Độ sắc nét
    final sharpResult = _checkSharpness(image);
    if (!sharpResult.isValid) return sharpResult;

    return const ImageValidationResult.valid();
  }

  // ---------------------------------------------------------------------------
  // Kiểm tra từng tiêu chí
  // ---------------------------------------------------------------------------

  ImageValidationResult _checkFileSize(Uint8List bytes) {
    if (bytes.lengthInBytes > maxFileSizeBytes) {
      final mb = (bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(1);
      final maxMb = (maxFileSizeBytes / (1024 * 1024)).round();
      return ImageValidationResult.invalid(
        errorTitle: 'Ảnh quá lớn',
        errorMessage: 'Ảnh của bạn nặng $mb MB, vượt quá giới hạn $maxMb MB.',
        errorHint: 'Hãy chọn ảnh nhẹ hơn hoặc nén lại trước khi tải lên.',
      );
    }
    return const ImageValidationResult.valid();
  }

  ImageValidationResult _checkResolution(img.Image image) {
    if (image.width < minWidth || image.height < minHeight) {
      return ImageValidationResult.invalid(
        errorTitle: 'Độ phân giải quá thấp',
        errorMessage:
            'Ảnh chỉ có ${image.width}×${image.height} px, cần ít nhất '
            '$minWidth×$minHeight px.',
        errorHint:
            'Chụp lại ở khoảng cách gần hơn hoặc chọn ảnh có độ phân giải cao hơn.',
      );
    }
    return const ImageValidationResult.valid();
  }

  /// Độ sáng trung bình dựa trên kênh luma (Y = 0.299R + 0.587G + 0.114B).
  /// API image 4.x: pixel.r / pixel.g / pixel.b là num (0–255).
  ImageValidationResult _checkBrightness(img.Image image) {
    double totalLuma = 0;
    int sampleCount = 0;

    final w = image.width;
    final h = image.height;
    final total = w * h;
    final step = math.max(1, total ~/ 4000); // tối đa ~4000 mẫu

    for (var i = 0; i < total; i += step) {
      final x = i % w;
      final y = i ~/ w;
      final pixel = image.getPixel(x, y);
      totalLuma +=
          0.299 * pixel.r.toDouble() +
          0.587 * pixel.g.toDouble() +
          0.114 * pixel.b.toDouble();
      sampleCount++;
    }

    final avgLuma = sampleCount == 0 ? 255.0 : totalLuma / sampleCount;

    if (avgLuma < minBrightness) {
      return const ImageValidationResult.invalid(
        errorTitle: 'Ảnh quá tối',
        errorMessage:
            'Trang phục không thể hiện rõ trong điều kiện ánh sáng này.',
        errorHint:
            'Chụp ảnh ở nơi có đủ ánh sáng hoặc bật đèn flash để hình ảnh sáng hơn.',
      );
    }
    return const ImageValidationResult.valid();
  }

  /// Phát hiện blur bằng phương sai của toán tử Laplacian đơn giản.
  /// Variance thấp → ảnh mờ, đồng đều → thiếu cạnh sắc nét.
  /// API image 4.x: pixel.r trên ảnh grayscale = độ sáng của điểm đó.
  ImageValidationResult _checkSharpness(img.Image image) {
    // Làm việc trên ảnh grayscale thu nhỏ để tiết kiệm CPU.
    final small = img.copyResize(image, width: math.min(image.width, 300));
    final gray = img.grayscale(small);

    final w = gray.width;
    final h = gray.height;

    double sumLap = 0;
    double sumLapSq = 0;
    int count = 0;

    // Tính Laplacian tại từng pixel nội vùng (bỏ viền 1px).
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        // Trên ảnh grayscale, kênh r = g = b = độ xám.
        final center = gray.getPixel(x, y).r.toDouble();
        final top    = gray.getPixel(x, y - 1).r.toDouble();
        final bottom = gray.getPixel(x, y + 1).r.toDouble();
        final left   = gray.getPixel(x - 1, y).r.toDouble();
        final right  = gray.getPixel(x + 1, y).r.toDouble();

        final lap = 4 * center - top - bottom - left - right;
        sumLap += lap;
        sumLapSq += lap * lap;
        count++;
      }
    }

    if (count == 0) return const ImageValidationResult.valid();

    final mean = sumLap / count;
    final variance = (sumLapSq / count) - (mean * mean);

    if (variance < minSharpness) {
      return const ImageValidationResult.invalid(
        errorTitle: 'Ảnh quá mờ',
        errorMessage:
            'Trang phục không hiển thị đủ rõ để hệ thống nhận diện.',
        errorHint:
            'Chụp lại ảnh rõ hơn, giữ tay thật ổn định và đảm bảo trang phục '
            'nằm trong vùng lấy nét.',
      );
    }
    return const ImageValidationResult.valid();
  }
}
