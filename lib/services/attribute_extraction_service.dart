import 'dart:typed_data';

import '../models/clothing_color.dart';
import '../models/enums.dart';

/// Kết quả nhận diện thuộc tính trang phục từ ảnh bằng AI.
/// Được chuẩn hóa về bộ enum metadata chuẩn của app.
/// Người dùng có thể xác nhận hoặc chỉnh sửa trước khi lưu vào tủ đồ.
class ExtractedAttributes {
  ExtractedAttributes({
    this.suggestedName,
    required this.category,
    this.colors = const [],
    this.styles = const [],
    this.seasons = const [],
    this.occasions = const [],
    this.pattern,
    this.material,
  });

  /// Tên gợi ý cho món đồ (vd: "Áo thun trắng basic"). Có thể null.
  final String? suggestedName;

  /// Danh mục trang phục được nhận diện (áo, quần, váy...).
  final ClothingCategory category;

  /// Danh sách màu sắc nhận diện được — chuẩn hóa về ColorPalette.basics.
  final List<ClothingColor> colors;

  /// Phong cách phù hợp được nhận diện (casual, formal, sporty...).
  final List<StyleTag> styles;

  /// Mùa phù hợp được nhận diện (spring, summer, fall, winter).
  final List<Season> seasons;

  /// Ngữ cảnh phù hợp được nhận diện (work, casual, date...).
  final List<Occasion> occasions;

  /// Hoa văn nhận diện được (vd: "Trơn", "Kẻ sọc"). Null nếu không rõ.
  final String? pattern;

  /// Chất liệu nhận diện được (vd: "Cotton", "Denim"). Null nếu không rõ.
  final String? material;
}

/// Interface dịch vụ trích xuất thuộc tính trang phục từ ảnh.
/// Sử dụng LLM đa phương thức (Groq/Gemini) để phân tích ảnh và trả về JSON.
abstract class AttributeExtractionService {
  /// Phân tích [imageBytes] và trả về [ExtractedAttributes] đã chuẩn hóa.
  Future<ExtractedAttributes> extract(Uint8List imageBytes);
}

/// Bản mock — trả về dự đoán mặc định (áo thun trắng, casual, xuân-hè)
/// để kiểm thử toàn bộ pipeline khi chưa có API key.
/// Người dùng vẫn có thể chỉnh sửa kết quả sau.
class MockAttributeExtractionService implements AttributeExtractionService {
  @override
  Future<ExtractedAttributes> extract(Uint8List imageBytes) async {
    await Future<void>.delayed(const Duration(milliseconds: 600)); // giả lập thời gian AI xử lý
    return ExtractedAttributes(
      suggestedName: 'Trang phục mới',
      category: ClothingCategory.top,                  // mặc định: áo trên
      colors: [ColorPalette.byName('Trắng')!],         // màu trắng
      styles: [StyleTag.casual],                       // phong cách thường ngày
      seasons: [Season.spring, Season.summer],         // phù hợp xuân-hè
      occasions: [Occasion.casual],                    // dịp thường ngày
      pattern: 'Trơn',                                 // không hoa văn
    );
  }
}
