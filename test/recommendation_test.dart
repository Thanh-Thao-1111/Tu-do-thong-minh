import 'package:flutter_test/flutter_test.dart';

import 'package:smart_wardrobe/models/enums.dart';
import 'package:smart_wardrobe/models/wardrobe_item.dart';
import 'package:smart_wardrobe/models/weather_info.dart';
import 'package:smart_wardrobe/repositories/sample_data.dart';
import 'package:smart_wardrobe/services/outfit_recommendation_service.dart';

void main() {
  final service = OutfitRecommendationService();
  final wardrobe = sampleWardrobe();

  group('OutfitRecommendationService', () {
    test('sinh được outfit từ tủ đồ mẫu', () {
      final outfits = service.recommend(wardrobe, count: 5);
      expect(outfits, isNotEmpty);
      expect(outfits.length, lessThanOrEqualTo(5));
    });

    test('mọi outfit đều hợp lệ (áo+quần hoặc váy, không trùng vai trò)', () {
      final outfits = service.recommend(wardrobe, count: 5);
      for (final o in outfits) {
        expect(o.isValid, isTrue, reason: 'Outfit ${o.id} không hợp lệ');
        // Không trùng vai trò: số category phân biệt = số món.
        final categories = o.items.map((i) => i.category).toList();
        expect(categories.toSet().length, categories.length,
            reason: 'Outfit có 2 món cùng vai trò');
      }
    });

    test('các outfit được xếp hạng theo điểm giảm dần', () {
      final outfits = service.recommend(wardrobe, count: 5);
      for (var i = 1; i < outfits.length; i++) {
        expect(outfits[i - 1].score, greaterThanOrEqualTo(outfits[i].score));
      }
    });

    test('điểm phù hợp nằm trong khoảng [0, 1]', () {
      final outfits = service.recommend(wardrobe, count: 5);
      for (final o in outfits) {
        expect(o.score, inInclusiveRange(0.0, 1.0));
      }
    });

    test('tham số count giới hạn số lượng kết quả', () {
      final outfits = service.recommend(wardrobe, count: 2);
      expect(outfits.length, lessThanOrEqualTo(2));
    });

    test('tủ đồ rỗng -> không có outfit', () {
      final outfits = service.recommend([], count: 5);
      expect(outfits, isEmpty);
    });

    test('chọn phong cách giúp ưu tiên outfit khớp phong cách', () {
      final formal =
          service.recommend(wardrobe, style: StyleTag.formal, count: 5);
      expect(formal, isNotEmpty);
      // Outfit top phải chứa ít nhất 1 món thuộc phong cách formal.
      final best = formal.first;
      expect(best.items.any((i) => i.styles.contains(StyleTag.formal)), isTrue);
    });

    test('outfit có kèm phụ kiện khi tủ có phụ kiện', () {
      final items = [
        WardrobeItem(
            id: 't',
            name: 'Áo',
            category: ClothingCategory.top,
            styles: const [StyleTag.casual]),
        WardrobeItem(
            id: 'b',
            name: 'Quần',
            category: ClothingCategory.bottom,
            styles: const [StyleTag.casual]),
        WardrobeItem(
            id: 'a',
            name: 'Túi xách',
            category: ClothingCategory.accessory,
            styles: const [StyleTag.casual]),
      ];
      final outfits = service.recommend(items, count: 5);
      expect(outfits, isNotEmpty);
      expect(
          outfits.first.items
              .any((i) => i.category == ClothingCategory.accessory),
          isTrue);
    });

    test('lọc thời tiết: thêm áo khoác khi trời lạnh', () {
      const cold = WeatherInfo(
        temperatureC: 10,
        description: 'Trời lạnh',
        condition: WeatherCondition.clouds,
      );
      final outfits = service.recommend(wardrobe, weather: cold, count: 5);
      expect(outfits, isNotEmpty);
      // Có ít nhất một outfit kèm áo khoác.
      final anyOuter = outfits.any(
          (o) => o.items.any((i) => i.category == ClothingCategory.outerwear));
      expect(anyOuter, isTrue);
    });
  });
}
