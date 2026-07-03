import 'package:flutter/material.dart';

import '../../models/enums.dart';

/// Hệ thống màu sắc và kiểu dáng chung của ứng dụng (Design System).
/// Phong cách "Fresh Emerald" — xanh ngọc lá chủ đạo, nền sáng kiểu iOS.
class AppPalette {
  AppPalette._(); // Constructor private — không tạo instance, chỉ dùng static

  // ----- Màu chính (Emerald) -----

  /// Xanh ngọc đậm (emerald-500, #10B981).
  /// Dùng cho: nút bấm chính, icon tab active, progress bar, viền thẻ outfit hàng đầu.
  static const Color primary = Color(0xFF10B981);

  /// Xanh ngọc sáng hơn (emerald-400, #34D399).
  /// Dùng cho: màu đầu gradient, chấm marker lịch nhật ký.
  static const Color secondary = Color(0xFF34D399);

  /// Xanh ngọc rất nhạt (emerald-100, #D1FAE5).
  /// Dùng cho: nền chip/tag phong cách, nền badge xếp hạng outfit.
  static const Color primaryTint = Color(0xFFD1FAE5);

  /// Gần trắng xanh (emerald-50, #ECFDF5).
  /// Dùng cho: nền container nhẹ, nền badge số thứ hạng outfit.
  static const Color primarySurface = Color(0xFFECFDF5);

  // ----- Màu nền & chữ -----

  /// Trắng xám nhạt (slate-50, #F8FAFC).
  /// Dùng cho: màu nền toàn màn hình (Scaffold background).
  static const Color background = Color(0xFFF8FAFC);

  /// Trắng thuần (#FFFFFF).
  /// Dùng cho: nền thẻ (wardrobe item, outfit card, weather card, diary card...).
  static const Color card = Color(0xFFFFFFFF);

  /// Gần đen (gray-900, #111827).
  /// Dùng cho: chữ tiêu đề, tên món đồ, nội dung chính.
  static const Color ink = Color(0xFF111827);

  /// Xám trung (gray-500, #6B7280).
  /// Dùng cho: chữ phụ — mô tả, số đếm, subtitle, hint text.
  static const Color inkSoft = Color(0xFF6B7280);

  /// Xám nhạt (gray-200, #E5E7EB).
  /// Dùng cho: viền thẻ ngày nhật ký, viền ô nhập liệu, đường kẻ phân cách.
  static const Color border = Color(0xFFE5E7EB);

  // ----- Màu trạng thái -----

  /// Màu thành công — dùng lại màu chính emerald (nhất quán với toàn app).
  static const Color success = primary;

  /// Đỏ (red-500, #EF4444).
  /// Dùng cho: nút "Xóa khỏi nhật ký", icon/thông báo lỗi, cảnh báo.
  static const Color error = Color(0xFFEF4444);

  // ----- Bán kính bo góc -----

  /// 20px — bo góc thẻ (wardrobe item card, outfit card, diary card...).
  static const double rCard = 20;

  /// 16px — bo góc nút bấm (FilledButton, OutlinedButton...).
  static const double rButton = 16;

  /// 14px — bo góc ô nhập liệu (TextField, DropdownButtonFormField...).
  static const double rInput = 14;

  /// 999px — bo góc chip / pill / tag (tạo hình viên thuốc hoàn toàn tròn).
  static const double rChip = 999;

  /// 28px — bo góc phần đầu bottom sheet (add source, filter, outfit detail...).
  static const double rSheet = 28;

  // ----- Alias tương thích ngược -----
  // Giữ lại tên cũ để các widget chưa cập nhật vẫn biên dịch được.

  static const Color lavender = primary;         // alias của primary
  static const Color lavenderSoft = secondary;   // alias của secondary
  static const Color lavenderTint = primaryTint; // alias của primaryTint

  /// Xanh dương (sky-500, #0EA5E9) — màu nhấn phụ cho thống kê, biểu đồ.
  static const Color blush = Color(0xFF0EA5E9);

  /// Xanh dương rất nhạt (sky-100, #E0F2FE) — nền nhạt cho biểu đồ.
  static const Color blushTint = Color(0xFFE0F2FE);

  static const Color mint = primary; // alias của primary

  // ----- Màu placeholder theo danh mục trang phục -----
  // Khi món đồ chưa có ảnh, ô ảnh hiển thị màu nền tương ứng loại trang phục.

  static const Map<ClothingCategory, Color> _categoryColor = {
    ClothingCategory.top:       Color(0xFF34D399), // emerald-400 — áo trên
    ClothingCategory.bottom:    Color(0xFF38BDF8), // sky-400     — quần/váy dưới
    ClothingCategory.dress:     Color(0xFFF472B6), // pink-400    — đầm/váy liền thân
    ClothingCategory.outerwear: Color(0xFFA78BFA), // violet-400  — áo khoác ngoài
    ClothingCategory.shoes:     Color(0xFFFBBF24), // amber-400   — giày dép
    ClothingCategory.accessory: Color(0xFF2DD4BF), // teal-400    — phụ kiện (túi, mũ...)
  };

  /// Trả về màu placeholder của danh mục [c].
  /// Fallback về [primary] nếu không tìm thấy trong bảng.
  static Color categoryColor(ClothingCategory c) =>
      _categoryColor[c] ?? primary;

  // ----- Đổ bóng -----

  /// Đổ bóng mềm — dùng cho thẻ chính (outfit card, wardrobe item, weather card...).
  /// Tương đương CSS: box-shadow: 0 4px 20px rgba(0,0,0,0.06)
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0F000000), // đen ~6% alpha
      blurRadius: 20,           // vùng mờ lan rộng
      offset: Offset(0, 4),     // đổ xuống 4px
    ),
  ];

  /// Đổ bóng rất nhẹ — dùng cho thành phần nhỏ (ảnh trong grid, chip...).
  /// Tương đương CSS: box-shadow: 0 3px 12px rgba(0,0,0,0.04)
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x0A000000), // đen ~4% alpha
      blurRadius: 12,           // vùng mờ hẹp hơn
      offset: Offset(0, 3),     // đổ xuống 3px
    ),
  ];

  // ----- Gradient -----

  /// Gradient chính: emerald-500 (#10B981) → emerald-600 (#059669).
  /// Dùng cho: header trang chủ, nút "Gợi ý", thẻ outfit hạng 1, thẻ tóm tắt nhật ký.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,   // bắt đầu góc trên trái
    end: Alignment.bottomRight, // kết thúc góc dưới phải
    colors: [
      Color(0xFF10B981), // emerald-500 (sáng hơn)
      Color(0xFF059669), // emerald-600 (đậm hơn)
    ],
  );

  /// Gradient thẻ thời tiết: emerald-400 (#34D399) → cyan-400 (#22D3EE).
  /// Dùng cho: WeatherCard ở Trang chủ và trang Gợi ý.
  static const LinearGradient weatherGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF34D399), // emerald-400
      Color(0xFF22D3EE), // cyan-400
    ],
  );

  /// Gradient bầu trời nhẹ: emerald-300 (#6EE7B7) → emerald-400 (#34D399).
  /// Dùng cho: các thẻ phụ, nền nhẹ.
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6EE7B7), // emerald-300 (rất nhạt)
      Color(0xFF34D399), // emerald-400
    ],
  );
}
