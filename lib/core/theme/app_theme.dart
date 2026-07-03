import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

/// Cấu hình giao diện tổng thể của ứng dụng — phong cách "Fresh Emerald".
/// Header kiểu iOS: hòa vào nền, không có thanh màu, không đổ bóng.
/// Font chữ: Inter (Google Fonts) — hiện đại, dễ đọc.
class AppTheme {
  AppTheme._(); // Constructor private — dùng static method light()

  /// Tạo và trả về ThemeData cho chế độ sáng (Light Mode).
  /// Gọi một lần duy nhất trong MaterialApp ở main.dart.
  static ThemeData light() {
    // Tạo ColorScheme gốc từ màu seed (emerald), sau đó ghi đè từng slot
    // để đảm bảo màu sắc nhất quán với bảng màu AppPalette.
    final base = ColorScheme.fromSeed(
        seedColor: AppPalette.primary, brightness: Brightness.light);
    final scheme = base.copyWith(
      primary: AppPalette.primary,                        // màu chính — nút, icon active
      onPrimary: Colors.white,                            // chữ/icon trên nền primary
      primaryContainer: AppPalette.primaryTint,           // nền nhạt của primary (chip, badge)
      onPrimaryContainer: const Color(0xFF064E3B),        // chữ trên primaryContainer
      secondary: AppPalette.secondary,                    // màu phụ — gradient, marker lịch
      onSecondary: Colors.white,                          // chữ/icon trên nền secondary
      secondaryContainer: AppPalette.primarySurface,      // nền rất nhạt
      onSecondaryContainer: const Color(0xFF065F46),      // chữ trên secondaryContainer
      surface: Colors.white,                              // nền surface (card, sheet...)
      onSurface: AppPalette.ink,                          // chữ chính trên surface
      surfaceContainerHighest: const Color(0xFFF1F5F9),   // nền container đậm nhất
      onSurfaceVariant: AppPalette.inkSoft,               // chữ phụ trên surface variant
      outline: const Color(0xFFCBD5E1),                   // viền rõ
      outlineVariant: AppPalette.border,                  // viền mờ / phân cách
      error: AppPalette.error,                            // màu lỗi (đỏ)
      onError: Colors.white,                              // chữ/icon trên nền error
    );

    // Font Inter áp dụng cho toàn bộ text trong app.
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ).apply(bodyColor: AppPalette.ink, displayColor: AppPalette.ink);

    return ThemeData(
      useMaterial3: true,                               // dùng Material Design 3
      colorScheme: scheme,                              // bảng màu đã tuỳ chỉnh
      scaffoldBackgroundColor: AppPalette.background,   // nền toàn màn hình (trắng xám nhạt)
      textTheme: textTheme,                             // font Inter toàn app
      splashFactory: InkRipple.splashFactory,           // hiệu ứng gợn nước khi bấm

      // ----- AppBar -----
      // Kiểu iOS: nền hoà vào background, không shadow, không surface tint.
      appBarTheme: AppBarTheme(
        backgroundColor: AppPalette.background,         // cùng màu nền → hòa vào màn hình
        surfaceTintColor: Colors.transparent,           // tắt overlay màu khi cuộn
        foregroundColor: AppPalette.ink,                // màu icon/nút back trên AppBar
        centerTitle: false,                             // tiêu đề căn trái (iOS style)
        elevation: 0,                                   // không đổ bóng
        scrolledUnderElevation: 0,                      // không đổ bóng khi cuộn qua
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w800,                  // tiêu đề đậm, nổi bật
          color: AppPalette.ink,
        ),
      ),

      // ----- Card -----
      cardTheme: CardThemeData(
        elevation: 0,                                   // không đổ bóng mặc định (tự xử lý shadow)
        surfaceTintColor: Colors.transparent,           // tắt overlay màu Material 3
        color: Colors.white,                            // nền trắng
        clipBehavior: Clip.antiAlias,                   // ảnh bên trong được cắt bo góc mượt
        margin: EdgeInsets.zero,                        // không margin ngoài
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppPalette.rCard)), // bo góc 20px
      ),

      // ----- Chip (tag phong cách, bộ lọc) -----
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),                   // hình viên thuốc
        side: BorderSide.none,                          // không viền mặc định
        backgroundColor: Colors.white,                  // nền chip chưa chọn
        selectedColor: AppPalette.primary,              // nền chip đã chọn (xanh emerald)
        secondarySelectedColor: AppPalette.primary,
        checkmarkColor: Colors.white,                   // màu dấu tích khi chọn
        showCheckmark: false,                           // ẩn dấu tích — dùng màu nền thay thế
        labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600, fontSize: 13, color: AppPalette.ink),
        secondaryLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),

      // ----- Nút bấm chính (FilledButton) -----
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),               // chiều cao tối thiểu 54px
          textStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppPalette.rButton)), // bo góc 16px
        ),
      ),

      // ----- Nút viền (OutlinedButton) -----
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 54),               // chiều cao tối thiểu 54px
          foregroundColor: AppPalette.ink,              // màu chữ/icon
          backgroundColor: Colors.white,                // nền trắng
          side: const BorderSide(color: AppPalette.border, width: 1.5), // viền xám nhạt
          textStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppPalette.rButton)), // bo góc 16px
        ),
      ),

      // ----- Nút văn bản (TextButton) -----
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.primary,          // màu chữ xanh emerald
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),

      // ----- Nút nổi (FAB) -----
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppPalette.primary,            // nền xanh emerald
        foregroundColor: Colors.white,                  // icon trắng
        elevation: 2,                                   // đổ bóng nhẹ
        highlightElevation: 4,                          // đổ bóng khi nhấn
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // ----- Ô nhập liệu (TextField / TextFormField) -----
      inputDecorationTheme: InputDecorationTheme(
        filled: true,                                   // có nền fill
        fillColor: Colors.white,                        // nền trắng
        hintStyle: const TextStyle(color: AppPalette.inkSoft), // gợi ý màu xám
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppPalette.rInput), // bo góc 14px
          borderSide: BorderSide.none,                  // mặc định: không viền
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppPalette.rInput),
          borderSide:
              const BorderSide(color: AppPalette.border, width: 1.4),   // viền xám nhạt
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppPalette.rInput),
          borderSide:
              const BorderSide(color: AppPalette.primary, width: 1.8), // viền xanh khi focus
        ),
      ),

      // ----- Thanh điều hướng dưới (Bottom Navigation Bar) -----
      navigationBarTheme: NavigationBarThemeData(
        height: 70,                                     // chiều cao thanh nav
        elevation: 0,                                   // không đổ bóng
        backgroundColor: Colors.white,                  // nền trắng
        surfaceTintColor: Colors.transparent,           // tắt overlay màu
        indicatorColor: AppPalette.primaryTint,         // nền pill xanh nhạt khi active
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, // luôn hiện nhãn
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
              color: selected
                  ? AppPalette.primary    // icon active: xanh emerald
                  : AppPalette.inkSoft); // icon inactive: xám
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppPalette.primary    // nhãn active: xanh emerald
                : AppPalette.inkSoft,  // nhãn inactive: xám
          );
        }),
      ),

      // ----- Bottom Sheet (modal panel từ dưới lên) -----
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,                  // nền trắng
        surfaceTintColor: Colors.transparent,           // tắt overlay
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppPalette.rSheet)), // bo góc trên 28px
        ),
      ),

      // ----- Dialog (hộp thoại xác nhận, lỗi...) -----
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,                  // nền trắng
        surfaceTintColor: Colors.transparent,           // tắt overlay
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),   // bo góc 24px
      ),

      // ----- SnackBar (thông báo ngắn dưới màn hình) -----
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,            // nổi lên, không dính đáy
        backgroundColor: AppPalette.ink,                // nền tối (dark)
        contentTextStyle: GoogleFonts.inter(
            color: Colors.white, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),   // bo góc 14px
      ),

      // ----- Divider (đường kẻ phân cách) -----
      dividerTheme: const DividerThemeData(
          color: AppPalette.border, thickness: 1), // xám nhạt, dày 1px
    );
  }
}
