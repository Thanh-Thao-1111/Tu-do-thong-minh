/// Cấu hình OpenWeatherMap (thời tiết thật theo vị trí).
///
/// API key miễn phí ở https://openweathermap.org/api (đăng ký → API keys).
/// Để trống thì dùng thời tiết mock.
class OpenWeatherConfig {
  OpenWeatherConfig._();

  static const String apiKey = 'f37f929188255038f893c2dc3ad2d776';

  /// Thành phố mặc định khi không lấy được vị trí GPS (vd quyền bị từ chối).
  static const String defaultCity = 'Hanoi,VN';

  static bool get isConfigured => apiKey.isNotEmpty;
}
