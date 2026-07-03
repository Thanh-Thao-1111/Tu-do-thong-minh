import '../models/clothing_color.dart';
import '../models/enums.dart';
import '../models/wardrobe_item.dart';

/// Dữ liệu tủ đồ mẫu để demo UI khi chưa nối Firebase / chưa thêm đồ thật.
/// Sau khi tích hợp Firestore, nguồn dữ liệu này sẽ được thay thế.
List<WardrobeItem> sampleWardrobe() {
  ClothingColor c(String name) => ColorPalette.byName(name)!;
  final base = DateTime(2026, 6, 1);

  return [
    WardrobeItem(
      id: 'seed-1',
      name: 'Áo thun trắng basic',
      category: ClothingCategory.top,
      colors: [c('Trắng')],
      styles: [StyleTag.casual, StyleTag.minimalist],
      seasons: [Season.spring, Season.summer],
      occasions: [Occasion.casual, Occasion.school],
      material: 'Cotton',
      pattern: 'Trơn',
      createdAt: base,
    ),
    WardrobeItem(
      id: 'seed-2',
      name: 'Sơ mi xanh navy',
      category: ClothingCategory.top,
      colors: [c('Xanh navy')],
      styles: [StyleTag.formal, StyleTag.elegant],
      seasons: [Season.spring, Season.fall],
      occasions: [Occasion.work, Occasion.date],
      material: 'Kate',
      createdAt: base,
    ),
    WardrobeItem(
      id: 'seed-3',
      name: 'Quần jean xanh',
      category: ClothingCategory.bottom,
      colors: [c('Xanh dương')],
      styles: [StyleTag.casual, StyleTag.streetwear],
      seasons: [Season.spring, Season.fall, Season.winter],
      occasions: [Occasion.casual, Occasion.school],
      material: 'Denim',
      createdAt: base,
    ),
    WardrobeItem(
      id: 'seed-4',
      name: 'Quần tây đen',
      category: ClothingCategory.bottom,
      colors: [c('Đen')],
      styles: [StyleTag.formal],
      seasons: [Season.spring, Season.fall, Season.winter],
      occasions: [Occasion.work],
      material: 'Vải tây',
      createdAt: base,
    ),
    WardrobeItem(
      id: 'seed-5',
      name: 'Váy hoa nhí',
      category: ClothingCategory.dress,
      colors: [c('Hồng'), c('Trắng')],
      styles: [StyleTag.elegant, StyleTag.vintage],
      seasons: [Season.summer],
      occasions: [Occasion.date, Occasion.party],
      pattern: 'Hoa nhí',
      createdAt: base,
    ),
    WardrobeItem(
      id: 'seed-6',
      name: 'Áo khoác jean',
      category: ClothingCategory.outerwear,
      colors: [c('Xanh dương')],
      styles: [StyleTag.streetwear, StyleTag.casual],
      seasons: [Season.fall, Season.winter],
      occasions: [Occasion.casual],
      material: 'Denim',
      createdAt: base,
    ),
    WardrobeItem(
      id: 'seed-7',
      name: 'Giày sneaker trắng',
      category: ClothingCategory.shoes,
      colors: [c('Trắng')],
      styles: [StyleTag.casual, StyleTag.sporty],
      seasons: [Season.spring, Season.summer, Season.fall],
      occasions: [Occasion.casual, Occasion.school, Occasion.sport],
      createdAt: base,
    ),
    WardrobeItem(
      id: 'seed-8',
      name: 'Giày tây da nâu',
      category: ClothingCategory.shoes,
      colors: [c('Nâu')],
      styles: [StyleTag.formal, StyleTag.elegant],
      seasons: [Season.spring, Season.fall, Season.winter],
      occasions: [Occasion.work, Occasion.date],
      material: 'Da',
      createdAt: base,
    ),
  ];
}
