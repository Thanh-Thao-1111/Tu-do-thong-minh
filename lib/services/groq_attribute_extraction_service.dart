import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/config/groq_config.dart';
import '../models/clothing_color.dart';
import '../models/enums.dart';
import 'attribute_extraction_service.dart';

/// Nhận diện thuộc tính trang phục bằng Groq (Llama 4 đa phương thức),
/// API tương thích OpenAI. Lỗi → trả về dự đoán mặc định để vẫn sửa & lưu được.
class GroqAttributeExtractionService implements AttributeExtractionService {
  static const _colorNames = [
    'Đen', 'Trắng', 'Xám', 'Be', 'Nâu', 'Đỏ', 'Hồng', 'Cam', 'Vàng',
    'Xanh lá', 'Xanh dương', 'Xanh navy', 'Tím',
  ];

  String get _prompt {
    final cats = ClothingCategory.values.map((e) => e.name).join(', ');
    final styles = StyleTag.values.map((e) => e.name).join(', ');
    final seasons = Season.values.map((e) => e.name).join(', ');
    final occasions = Occasion.values.map((e) => e.name).join(', ');
    final colors = _colorNames.join(', ');
    return 'Phân tích món trang phục trong ảnh. CHỈ trả về một JSON object '
        '(không markdown, không giải thích) với các khóa:\n'
        '"category": một trong [$cats];\n'
        '"suggestedName": tên ngắn gọn TIẾNG VIỆT (vd "Áo thun trắng");\n'
        '"colors": mảng 1-3 màu, CHỈ chọn trong [$colors];\n'
        '"styles": mảng các giá trị trong [$styles];\n'
        '"seasons": mảng các giá trị trong [$seasons];\n'
        '"occasions": mảng các giá trị trong [$occasions];\n'
        '"pattern": hoa văn tiếng Việt (vd "Trơn", "Kẻ sọc") hoặc "";\n'
        '"material": chất liệu tiếng Việt (vd "Cotton", "Jean") hoặc "".';
  }

  @override
  Future<ExtractedAttributes> extract(Uint8List imageBytes) async {
    if (!GroqConfig.isConfigured) return _fallback();
    try {
      final uri =
          Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      final body = jsonEncode({
        'model': GroqConfig.model,
        'temperature': 0.2,
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': _prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url':
                      'data:image/jpeg;base64,${base64Encode(imageBytes)}',
                }
              },
            ],
          }
        ],
      });

      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${GroqConfig.apiKey}',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (resp.statusCode != 200) return _fallback();

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final content =
          decoded['choices']?[0]?['message']?['content'] as String?;
      if (content == null) return _fallback();

      final json = jsonDecode(content) as Map<String, dynamic>;
      return _parse(json);
    } catch (_) {
      return _fallback();
    }
  }

  ExtractedAttributes _parse(Map<String, dynamic> json) {
    List<T> mapList<T>(String key, T Function(String) f) =>
        (((json[key] as List?) ?? [])
            .map((e) => f(e.toString()))
            .toSet()
            .toList());

    final colors = (((json['colors'] as List?) ?? [])
        .map((e) => ColorPalette.byName(e.toString()))
        .whereType<ClothingColor>()
        .toSet()
        .toList());

    String? nonEmpty(dynamic v) {
      final s = v?.toString();
      return (s == null || s.trim().isEmpty) ? null : s.trim();
    }

    return ExtractedAttributes(
      suggestedName: nonEmpty(json['suggestedName']) ?? 'Trang phục mới',
      category: ClothingCategory.fromName(json['category']?.toString()),
      colors: colors,
      styles: mapList('styles', (s) => StyleTag.fromName(s)),
      seasons: mapList('seasons', (s) => Season.fromName(s)),
      occasions: mapList('occasions', (s) => Occasion.fromName(s)),
      pattern: nonEmpty(json['pattern']),
      material: nonEmpty(json['material']),
    );
  }

  ExtractedAttributes _fallback() => ExtractedAttributes(
        suggestedName: 'Trang phục mới',
        category: ClothingCategory.top,
        colors: [ColorPalette.byName('Trắng')!],
        styles: [StyleTag.casual],
        seasons: [Season.spring, Season.summer],
        occasions: [Occasion.casual],
      );
}
