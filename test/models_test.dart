import 'package:flutter_test/flutter_test.dart';

import 'package:smart_wardrobe/models/clothing_color.dart';
import 'package:smart_wardrobe/models/diary_entry.dart';
import 'package:smart_wardrobe/models/enums.dart';
import 'package:smart_wardrobe/models/outfit.dart';
import 'package:smart_wardrobe/models/wardrobe_item.dart';

WardrobeItem _item(String id, ClothingCategory category) => WardrobeItem(
      id: id,
      name: 'Món $id',
      category: category,
    );

void main() {
  group('WardrobeItem metadata', () {
    test('toMap/fromMap giữ nguyên thuộc tính (round-trip)', () {
      final item = WardrobeItem(
        id: 'x1',
        name: 'Áo sơ mi xanh',
        category: ClothingCategory.top,
        colors: const [ClothingColor(name: 'Xanh navy', hex: '#1A237E')],
        styles: const [StyleTag.formal, StyleTag.elegant],
        seasons: const [Season.spring, Season.fall],
        occasions: const [Occasion.work],
        pattern: 'Trơn',
        material: 'Kate',
        wearCount: 3,
        createdAt: DateTime(2026, 1, 2),
      );

      final restored = WardrobeItem.fromMap('x1', item.toMap());

      expect(restored.name, item.name);
      expect(restored.category, ClothingCategory.top);
      expect(restored.colors.first.name, 'Xanh navy');
      expect(restored.colors.first.hex, '#1A237E');
      expect(restored.styles, containsAll(item.styles));
      expect(restored.seasons, containsAll(item.seasons));
      expect(restored.occasions, contains(Occasion.work));
      expect(restored.pattern, 'Trơn');
      expect(restored.material, 'Kate');
      expect(restored.wearCount, 3);
    });

    test('copyWith cập nhật đúng trường', () {
      final item = _item('a', ClothingCategory.top);
      final worn = item.copyWith(wearCount: 5, lastWornAt: DateTime(2026, 6, 1));
      expect(worn.wearCount, 5);
      expect(worn.lastWornAt, DateTime(2026, 6, 1));
      expect(worn.name, item.name); // giữ nguyên phần còn lại
    });

    test('primaryColor là màu đầu tiên', () {
      final item = WardrobeItem(
        id: 'a',
        name: 'x',
        category: ClothingCategory.top,
        colors: const [
          ClothingColor(name: 'Đỏ', hex: '#FF0000'),
          ClothingColor(name: 'Đen', hex: '#000000'),
        ],
      );
      expect(item.primaryColor?.name, 'Đỏ');
    });
  });

  group('Outfit hợp lệ', () {
    test('áo + quần -> hợp lệ', () {
      final o = Outfit(id: 'o', items: [
        _item('t', ClothingCategory.top),
        _item('b', ClothingCategory.bottom),
      ]);
      expect(o.isValid, isTrue);
    });

    test('chỉ có váy -> hợp lệ', () {
      final o = Outfit(id: 'o', items: [_item('d', ClothingCategory.dress)]);
      expect(o.isValid, isTrue);
    });

    test('chỉ có áo -> KHÔNG hợp lệ', () {
      final o = Outfit(id: 'o', items: [_item('t', ClothingCategory.top)]);
      expect(o.isValid, isFalse);
    });
  });

  group('Helper', () {
    test('Season.fromTemperature ánh xạ đúng', () {
      expect(Season.fromTemperature(32), Season.summer);
      expect(Season.fromTemperature(22), Season.spring);
      expect(Season.fromTemperature(15), Season.fall);
      expect(Season.fromTemperature(5), Season.winter);
    });

    test('ClothingColor.color phân tích hex', () {
      const c = ClothingColor(name: 'Đỏ', hex: '#FF0000');
      expect(c.color.toARGB32(), 0xFFFF0000);
    });

    test('DiaryEntry.dayKey định dạng yyyy-MM-dd', () {
      final e = DiaryEntry(
          id: 'e', date: DateTime(2026, 6, 9), itemIds: const ['a']);
      expect(e.dayKey, '2026-06-09');
    });

    test('ColorPalette.byName không phân biệt hoa thường', () {
      expect(ColorPalette.byName('đen')?.hex, '#000000');
      expect(ColorPalette.byName('TRẮNG')?.hex, '#FFFFFF');
      expect(ColorPalette.byName('không-có'), isNull);
    });
  });
}
