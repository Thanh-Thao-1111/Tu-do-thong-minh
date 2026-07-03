import 'enums.dart';

/// Thông tin thời tiết hiện tại — đầu vào ngữ cảnh cho module gợi ý phối đồ.
/// Lấy từ OpenWeatherMap API hoặc dùng bản mock khi không có key.
class WeatherInfo {
  const WeatherInfo({
    required this.temperatureC,
    required this.description,
    required this.condition,
    this.city,
    this.humidity,
    this.tempMax,
    this.tempMin,
  });

  /// Nhiệt độ hiện tại (°C).
  final double temperatureC;

  /// Mô tả thời tiết bằng tiếng Việt (vd: "Trời nắng", "Mưa nhẹ", "Nhiều mây").
  final String description;

  /// Điều kiện thời tiết — dùng để lọc outfit phù hợp (ưu tiên áo mưa khi mưa...).
  final WeatherCondition condition;

  /// Tên thành phố — hiển thị trên WeatherCard.
  final String? city;

  /// Độ ẩm (%) — hiển thị trên WeatherCard.
  final int? humidity;

  /// Nhiệt độ cao nhất trong ngày (°C).
  final double? tempMax;

  /// Nhiệt độ thấp nhất trong ngày (°C).
  final double? tempMin;

  /// Mùa suy ra từ nhiệt độ — dùng để lọc món đồ phù hợp mùa.
  Season get season => Season.fromTemperature(temperatureC);

  /// True nếu trời đang mưa — ưu tiên outfit che chắn.
  bool get isRainy => condition == WeatherCondition.rainy;

  /// True nếu trời lạnh (dưới 18°C) — ưu tiên áo khoác, quần dài.
  bool get isCold => temperatureC < 18;

  /// True nếu trời nóng (từ 30°C trở lên) — ưu tiên trang phục thoáng mát.
  bool get isHot => temperatureC >= 30;

  /// Chuyển sang Map để cache xuống SharedPreferences.
  Map<String, dynamic> toJson() => {
        'temperatureC': temperatureC,
        'description': description,
        'condition': condition.name,
        'city': city,
        'humidity': humidity,
        'tempMax': tempMax,
        'tempMin': tempMin,
      };

  /// Khôi phục WeatherInfo từ JSON đã cache.
  factory WeatherInfo.fromJson(Map<String, dynamic> m) => WeatherInfo(
        temperatureC: (m['temperatureC'] as num).toDouble(),
        description: (m['description'] ?? '') as String,
        condition: WeatherCondition.values.firstWhere(
          (e) => e.name == m['condition'],
          orElse: () => WeatherCondition.clear, // fallback: quang đãng
        ),
        city: m['city'] as String?,
        humidity: (m['humidity'] as num?)?.toInt(),
        tempMax: (m['tempMax'] as num?)?.toDouble(),
        tempMin: (m['tempMin'] as num?)?.toDouble(),
      );
}

/// Điều kiện thời tiết — dùng để phân loại và lọc gợi ý outfit.
enum WeatherCondition {
  clear(label: 'Quang đãng'),  // nắng, trời trong
  clouds(label: 'Nhiều mây'),  // trời âm u
  rainy(label: 'Mưa'),         // mưa nhẹ đến vừa
  storm(label: 'Giông bão'),   // mưa lớn, sấm sét
  snow(label: 'Tuyết'),        // tuyết rơi
  mist(label: 'Sương mù');     // sương mù, tầm nhìn hạn chế

  const WeatherCondition({required this.label});

  /// Tên hiển thị tiếng Việt.
  final String label;
}
