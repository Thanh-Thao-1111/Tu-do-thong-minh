import 'package:flutter/material.dart';

/// Màu sắc của trang phục: gồm tên hiển thị và mã hex.
/// Lưu hex để tính độ hòa hợp màu sắc trong module gợi ý phối đồ.
class ClothingColor {
  const ClothingColor({required this.name, required this.hex});

  /// Tên màu hiển thị cho người dùng (vd: "Trắng", "Đen", "Xanh navy").
  final String name;

  /// Mã màu hex dạng "#RRGGBB" (vd: "#FFFFFF", "#000000").
  final String hex;

  /// Chuyển hex sang [Color] của Flutter để hiển thị trực tiếp trên UI.
  /// Fallback về xám (#9E9E9E) nếu hex không hợp lệ.
  Color get color {
    final cleaned = hex.replaceAll('#', '');                          // bỏ dấu #
    final value = int.tryParse('FF$cleaned', radix: 16) ?? 0xFF9E9E9E; // thêm alpha FF
    return Color(value);
  }

  /// Chuyển sang Map để lưu vào Firestore.
  Map<String, dynamic> toMap() => {'name': name, 'hex': hex};

  /// Khôi phục từ Map Firestore. Dùng giá trị mặc định nếu field bị thiếu.
  factory ClothingColor.fromMap(Map<String, dynamic> map) => ClothingColor(
        name: (map['name'] ?? 'Không rõ') as String,
        hex: (map['hex'] ?? '#9E9E9E') as String,
      );

  /// Hai màu bằng nhau nếu cùng tên và cùng hex.
  @override
  bool operator ==(Object other) =>
      other is ClothingColor && other.name == name && other.hex == hex;

  @override
  int get hashCode => Object.hash(name, hex);

  @override
  String toString() => '$name ($hex)';
}

/// Bảng màu chuẩn của ứng dụng — dùng làm gợi ý khi người dùng
/// chỉnh sửa thủ công và làm chuẩn hóa output từ AI.
class ColorPalette {
  ColorPalette._(); // Utility class — không tạo instance

  /// Danh sách màu cơ bản được hỗ trợ.
  static const List<ClothingColor> basics = [
    ClothingColor(name: 'Đen',        hex: '#000000'),
    ClothingColor(name: 'Trắng',      hex: '#FFFFFF'),
    ClothingColor(name: 'Xám',        hex: '#9E9E9E'),
    ClothingColor(name: 'Be',         hex: '#D8C3A5'),
    ClothingColor(name: 'Nâu',        hex: '#795548'),
    ClothingColor(name: 'Đỏ',         hex: '#E53935'),
    ClothingColor(name: 'Hồng',       hex: '#EC407A'),
    ClothingColor(name: 'Cam',        hex: '#FB8C00'),
    ClothingColor(name: 'Vàng',       hex: '#FDD835'),
    ClothingColor(name: 'Xanh lá',    hex: '#43A047'),
    ClothingColor(name: 'Xanh dương', hex: '#1E88E5'),
    ClothingColor(name: 'Xanh navy',  hex: '#1A237E'),
    ClothingColor(name: 'Tím',        hex: '#8E24AA'),
  ];

  /// Tìm màu theo [name] (không phân biệt hoa thường).
  /// Trả về null nếu không tìm thấy trong bảng.
  static ClothingColor? byName(String name) {
    final lower = name.trim().toLowerCase();
    for (final c in basics) {
      if (c.name.toLowerCase() == lower) return c;
    }
    return null;
  }
}
