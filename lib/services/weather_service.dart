import '../models/weather_info.dart';

/// Interface dịch vụ thời tiết — cung cấp ngữ cảnh thời tiết cho module gợi ý.
/// - Bản thật: gọi OpenWeatherMap API, cache vào SharedPreferences.
/// - Bản mock: trả dữ liệu cố định (30°C nắng) để demo không cần key.
abstract class WeatherService {
  /// Trả về thông tin thời tiết hiện tại.
  /// Ưu tiên cache nếu còn mới, gọi API nếu đã cũ hoặc chưa có.
  Future<WeatherInfo> current();

  /// Dữ liệu thời tiết đang có trong RAM (từ lần gọi current() trước).
  /// Dùng để hiển thị NGAY trong lúc chờ dữ liệu mới cập nhật.
  /// Null nếu chưa tải lần nào trong phiên này.
  WeatherInfo? get cached;

  /// Tải trước ở chế độ nền — gọi lúc khởi động để dữ liệu sẵn sàng khi cần.
  Future<void> prefetch();
}

/// Bản mock — trả thời tiết cố định (30°C, nắng, TP. HCM) sau 300ms giả lập.
/// Dùng khi không có OpenWeatherMap API key.
class MockWeatherService implements WeatherService {
  WeatherInfo? _cached;

  @override
  WeatherInfo? get cached => _cached;

  @override
  Future<void> prefetch() => current(); // gọi current() để nạp cache

  @override
  Future<WeatherInfo> current() async {
    await Future<void>.delayed(const Duration(milliseconds: 300)); // giả lập độ trễ mạng
    _cached = const WeatherInfo(
      temperatureC: 30,
      description: 'Trời nắng',
      condition: WeatherCondition.clear,
      city: 'TP. Hồ Chí Minh',
      humidity: 70,   // độ ẩm 70%
      tempMax: 32,    // cao nhất 32°C
      tempMin: 26,    // thấp nhất 26°C
    );
    return _cached!;
  }
}
