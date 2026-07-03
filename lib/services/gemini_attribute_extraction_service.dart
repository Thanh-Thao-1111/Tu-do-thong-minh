import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/config/gemini_config.dart';
import '../models/clothing_color.dart';
import '../models/enums.dart';
import 'attribute_extraction_service.dart';

/// Nhận diện thuộc tính trang phục bằng Gemini (đa phương thức) qua REST API.
/// Trả về metadata đã chuẩn hóa; nếu lỗi → trả về dự đoán mặc định để người
/// dùng vẫn chỉnh sửa & lưu được.
class GeminiAttributeExtractionService implements AttributeExtractionService {
  static const _colorNames = [
    'Đen', 'Trắng', 'Xám', 'Be', 'Nâu', 'Đỏ', 'Hồng', 'Cam', 'Vàng',
    'Xanh lá', 'Xanh dương', 'Xanh navy', 'Tím',
  ];

  static const _prompt =
      'Bạn là trợ lý phân loại trang phục. Phân tích ảnh món đồ trong ảnh và '
      'trả về JSON đúng schema. Quy tắc: '
      'category = loại chính của món đồ; '
      'suggestedName = tên ngắn gọn TIẾNG VIỆT (vd "Áo thun trắng", "Quần jean xanh"); '
      'colors = 1-3 màu chính, CHỈ chọn trong danh sách cho sẵn; '
      'styles/seasons/occasions = chọn các giá trị phù hợp; '
      'pattern = hoa văn tiếng Việt (vd "Trơn", "Kẻ sọc", "Hoa nhí"); '
      'material = chất liệu tiếng Việt (vd "Cotton", "Jean", "Len"). '
      'Chỉ trả JSON, không giải thích.';

  Map<String, dynamic> get _schema => {
        'type': 'OBJECT',
        'properties': {
          'suggestedName': {'type': 'STRING'},
          'category': {
            'type': 'STRING',
            'enum': ClothingCategory.values.map((e) => e.name).toList(),
          },
          'colors': {
            'type': 'ARRAY',
            'items': {'type': 'STRING', 'enum': _colorNames},
          },
          'styles': {
            'type': 'ARRAY',
            'items': {
              'type': 'STRING',
              'enum': StyleTag.values.map((e) => e.name).toList(),
            },
          },
          'seasons': {
            'type': 'ARRAY',
            'items': {
              'type': 'STRING',
              'enum': Season.values.map((e) => e.name).toList(),
            },
          },
          'occasions': {
            'type': 'ARRAY',
            'items': {
              'type': 'STRING',
              'enum': Occasion.values.map((e) => e.name).toList(),
            },
          },
          'pattern': {'type': 'STRING'},
          'material': {'type': 'STRING'},
        },
        'required': ['category', 'suggestedName'],
      };

  @override
  Future<ExtractedAttributes> extract(Uint8List imageBytes) async {
    if (!GeminiConfig.isConfigured) return _fallback();
    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '${GeminiConfig.model}:generateContent?key=${GeminiConfig.apiKey}',
      );
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': _prompt},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Encode(imageBytes),
                }
              },
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseSchema': _schema,
          'temperature': 0.2,
        },
      });

      final resp = await http.post(uri,
          headers: {'Content-Type': 'application/json'}, body: body);
      if (resp.statusCode != 200) return _fallback();

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text']
          as String?;
      if (text == null) return _fallback();

      final json = jsonDecode(text) as Map<String, dynamic>;
      return _parse(json);
    } catch (_) {
      return _fallback();
    }
  }

  ExtractedAttributes _parse(Map<String, dynamic> json) {
    List<T> mapList<T>(String key, T Function(String) f) =>
        (((json[key] as List?) ?? [])
                .map((e) => f(e as String))
                .toSet()
                .toList());

    final colors = (((json['colors'] as List?) ?? [])
        .map((e) => ColorPalette.byName(e as String))
        .whereType<ClothingColor>()
        .toSet()
        .toList());

    String? nonEmpty(dynamic v) {
      final s = v as String?;
      return (s == null || s.trim().isEmpty) ? null : s.trim();
    }

    return ExtractedAttributes(
      suggestedName: nonEmpty(json['suggestedName']) ?? 'Trang phục mới',
      category: ClothingCategory.fromName(json['category'] as String?),
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
