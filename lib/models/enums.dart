import 'package:flutter/material.dart';

import '../core/icons/ph_icons.dart';

/// Bộ từ vựng (controlled vocabulary) chuẩn hóa cho metadata trang phục.
/// Mọi thuộc tính phân loại của một món đồ đều dùng các enum này để đảm bảo
/// tính nhất quán phục vụ truy vấn, lọc và gợi ý phối đồ.

/// Nhóm loại trang phục — đồng thời đóng vai trò "role" khi ghép outfit.
enum ClothingCategory {
  top(label: 'Áo', icon: PhIcons.tShirt),
  bottom(label: 'Quần/Chân váy', icon: PhIcons.pants),
  dress(label: 'Váy/Đầm', icon: PhIcons.dress),
  outerwear(label: 'Áo khoác', icon: PhIcons.hoodie),
  shoes(label: 'Giày/Dép', icon: PhIcons.sneaker),
  accessory(label: 'Phụ kiện', icon: PhIcons.sunglasses);

  const ClothingCategory({required this.label, required this.icon});
  final String label;
  final IconData icon;

  /// Ảnh đại diện của danh mục (asset bundle).
  String get imageAsset => switch (this) {
        ClothingCategory.top => 'assets/categories/ao.jpg',
        ClothingCategory.bottom => 'assets/categories/quanchanvay.jpg',
        ClothingCategory.dress => 'assets/categories/vay.jpg',
        ClothingCategory.outerwear => 'assets/categories/aokhoac.jpg',
        ClothingCategory.shoes => 'assets/categories/giaydep.jpg',
        ClothingCategory.accessory => 'assets/categories/phukien.jpg',
      };

  /// Thành phần bắt buộc tối thiểu của một outfit hợp lệ.
  bool get isCore =>
      this == ClothingCategory.top ||
      this == ClothingCategory.bottom ||
      this == ClothingCategory.dress;

  /// Các loại cụ thể (subtype) thuộc danh mục này — dùng cho bộ lọc & gắn nhãn.
  List<String> get subtypes => switch (this) {
        ClothingCategory.top => const [
            'Áo thun',
            'Áo sơ mi',
            'Áo polo',
            'Áo len',
            'Áo ba lỗ',
            'Áo dài tay',
          ],
        ClothingCategory.bottom => const [
            'Quần dài',
            'Quần short',
            'Quần jeans',
            'Quần tây',
            'Quần thể thao',
            'Quần legging',
            'Chân váy',
          ],
        ClothingCategory.dress => const [
            'Váy ngắn',
            'Váy dài',
            'Đầm dạ hội',
            'Đầm công sở',
          ],
        ClothingCategory.outerwear => const [
            'Áo khoác',
            'Blazer',
            'Hoodie',
            'Cardigan',
            'Áo vest',
            'Áo gió',
          ],
        ClothingCategory.shoes => const [
            'Giày thể thao',
            'Giày cao gót',
            'Giày lười',
            'Boots',
            'Sandal',
            'Dép',
          ],
        ClothingCategory.accessory => const [
            'Mũ/Nón',
            'Túi xách',
            'Thắt lưng',
            'Kính',
            'Đồng hồ',
            'Trang sức',
          ],
      };

  static ClothingCategory fromName(String? name) =>
      ClothingCategory.values.firstWhere(
        (e) => e.name == name,
        orElse: () => ClothingCategory.top,
      );
}

/// Phong cách trang phục.
enum StyleTag {
  casual(label: 'Thường ngày', description: 'Thoải mái, tự nhiên'),
  formal(label: 'Trang trọng', description: 'Lịch sự, chuyên nghiệp'),
  sporty(label: 'Thể thao', description: 'Năng động, khỏe khoắn'),
  streetwear(label: 'Đường phố', description: 'Cá tính, hiện đại'),
  elegant(label: 'Thanh lịch', description: 'Sang trọng, tinh tế'),
  vintage(label: 'Cổ điển', description: 'Hoài cổ, retro'),
  minimalist(label: 'Tối giản', description: 'Đơn giản, gọn gàng'),
  trendy(label: 'Thời thượng', description: 'Hợp mốt, nổi bật');

  const StyleTag({required this.label, required this.description});
  final String label;
  final String description;

  static StyleTag fromName(String? name) => StyleTag.values.firstWhere(
        (e) => e.name == name,
        orElse: () => StyleTag.casual,
      );
}

/// Mùa / điều kiện thời tiết phù hợp.
enum Season {
  spring(label: 'Xuân'),
  summer(label: 'Hè'),
  fall(label: 'Thu'),
  winter(label: 'Đông');

  const Season({required this.label});
  final String label;

  static Season fromName(String? name) => Season.values.firstWhere(
        (e) => e.name == name,
        orElse: () => Season.summer,
      );

  /// Suy ra mùa phù hợp từ nhiệt độ (°C) — dùng cho lọc gợi ý theo thời tiết.
  static Season fromTemperature(double celsius) {
    if (celsius >= 28) return Season.summer;
    if (celsius >= 20) return Season.spring;
    if (celsius >= 12) return Season.fall;
    return Season.winter;
  }
}

/// Ngữ cảnh sử dụng.
enum Occasion {
  school(label: 'Đi học', icon: Icons.school),
  work(label: 'Đi làm', icon: Icons.work),
  casual(label: 'Dạo phố', icon: Icons.local_cafe),
  party(label: 'Tiệc', icon: Icons.celebration),
  sport(label: 'Thể thao', icon: Icons.sports_basketball),
  date(label: 'Hẹn hò', icon: Icons.favorite),
  coffee(label: 'Cà phê', icon: Icons.coffee),
  picnic(label: 'Dã ngoại', icon: Icons.park),
  home(label: 'Ở nhà', icon: Icons.home);

  const Occasion({required this.label, required this.icon});
  final String label;
  final IconData icon;

  static Occasion fromName(String? name) => Occasion.values.firstWhere(
        (e) => e.name == name,
        orElse: () => Occasion.casual,
      );
}
