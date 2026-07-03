/// Một mục nhật ký thời trang (OOTD) — ghi lại bộ đồ đã mặc trong một ngày cụ thể.
class DiaryEntry {
  DiaryEntry({
    required this.id,
    required this.date,
    required this.itemIds,
    this.note,
    this.occasion,
    this.style,
  });

  /// ID duy nhất của mục nhật ký (UUID v4).
  final String id;

  /// Ngày mặc — chuẩn hóa về 00:00:00 để nhóm theo ngày.
  final DateTime date;

  /// Danh sách ID các món đồ tạo nên outfit của ngày hôm đó.
  final List<String> itemIds;

  /// Ghi chú của người dùng (tùy chọn, có thể null).
  final String? note;

  /// Ngữ cảnh mặc (vd: "Đi làm", "Dạo phố") — lấy từ lúc tạo gợi ý.
  final String? occasion;

  /// Phong cách người dùng đã chọn khi tạo gợi ý (vd "Đường phố"). Có thể null.
  final String? style;

  /// Khóa ngày dạng "yyyy-MM-dd" — tiện cho truy vấn và nhóm theo ngày.
  String get dayKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Tạo bản sao với một số field được thay thế.
  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    List<String>? itemIds,
    String? note,
    String? occasion,
    String? style,
  }) =>
      DiaryEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        itemIds: itemIds ?? this.itemIds,
        note: note ?? this.note,
        occasion: occasion ?? this.occasion,
        style: style ?? this.style,
      );

  /// Chuyển sang Map để lưu lên Firestore.
  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),    // ISO 8601 để parse lại dễ dàng
        'dayKey': dayKey,                  // lưu sẵn để truy vấn nhanh theo ngày
        'itemIds': itemIds,
        'note': note,
        'occasion': occasion,
        'style': style,
      };

  /// Khôi phục DiaryEntry từ dữ liệu Firestore.
  /// [id] là document ID của Firestore, [map] là dữ liệu trong document.
  factory DiaryEntry.fromMap(String id, Map<String, dynamic> map) => DiaryEntry(
        id: id,
        date: DateTime.tryParse((map['date'] ?? '') as String) ?? DateTime(2000),
        itemIds:
            ((map['itemIds'] as List?) ?? []).map((e) => e as String).toList(),
        note: map['note'] as String?,
        occasion: map['occasion'] as String?,
        style: map['style'] as String?,
      );
}
