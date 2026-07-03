import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/openweather_config.dart';
import '../models/weather_info.dart';
import 'weather_service.dart';

/// Thời tiết thật từ OpenWeatherMap — tối ưu tốc độ:
/// - Hiển thị NGAY thời tiết đã lưu phiên trước (stale-while-revalidate).
/// - Ưu tiên vị trí GPS biết gần nhất (getLastKnownPosition) -> gần như tức thì.
/// - Cache 10 phút trong RAM + lưu xuống đĩa cho lần mở app sau.
class OpenWeatherService implements WeatherService {
  OpenWeatherService() {
    _restore();
  }

  static const _prefsKey = 'last_weather';
  static const _cacheTtl = Duration(minutes: 10);

  WeatherInfo? _cache;
  DateTime? _cacheAt;
  bool _restored = false;

  @override
  WeatherInfo? get cached => _cache;

  @override
  Future<void> prefetch() => current();

  /// Khôi phục thời tiết đã lưu (coi như "cũ" -> sẽ được làm mới khi gọi current).
  Future<void> _restore() async {
    if (_restored) return;
    _restored = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_prefsKey);
      if (s != null && _cache == null) {
        _cache = WeatherInfo.fromJson(
            jsonDecode(s) as Map<String, dynamic>);
      }
    } catch (_) {/* bỏ qua */}
  }

  @override
  Future<WeatherInfo> current() async {
    if (!OpenWeatherConfig.isConfigured) return _cache ?? _defaultInfo();
    await _restore();

    // Cache còn mới -> trả ngay.
    if (_cache != null &&
        _cacheAt != null &&
        DateTime.now().difference(_cacheAt!) < _cacheTtl) {
      return _cache!;
    }

    try {
      final pos = await _tryPosition();
      final base =
          'https://api.openweathermap.org/data/2.5/weather?appid=${OpenWeatherConfig.apiKey}&units=metric&lang=vi';
      final uri = Uri.parse(pos != null
          ? '$base&lat=${pos.$1}&lon=${pos.$2}'
          : '$base&q=${OpenWeatherConfig.defaultCity}');

      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final info = _parse(jsonDecode(resp.body) as Map<String, dynamic>);
        _cache = info;
        _cacheAt = DateTime.now();
        _persist(info);
        return info;
      }
    } catch (_) {/* bỏ qua -> fallback */}
    return _cache ?? _defaultInfo();
  }

  Future<void> _persist(WeatherInfo info) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(info.toJson()));
    } catch (_) {/* bỏ qua */}
  }

  /// Lấy (lat, lon): ưu tiên vị trí biết gần nhất (tức thì), nếu không có mới
  /// lấy vị trí hiện tại (timeout ngắn). Trả null nếu bị từ chối / lỗi.
  Future<(double, double)?> _tryPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }
      // 1) Vị trí biết gần nhất — gần như 0 giây (không hỗ trợ trên web).
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return (last.latitude, last.longitude);
      } catch (_) {/* web không hỗ trợ -> bỏ qua */}
      // 2) Vị trí hiện tại — timeout ngắn để khỏi chờ lâu.
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 5));
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  WeatherInfo _parse(Map<String, dynamic> json) {
    final main = (json['main'] as Map?) ?? {};
    final temp = (main['temp'] as num?)?.toDouble() ?? 28;
    final humidity = (main['humidity'] as num?)?.toInt();
    final tempMax = (main['temp_max'] as num?)?.toDouble();
    final tempMin = (main['temp_min'] as num?)?.toDouble();
    final list = json['weather'] as List?;
    final w = (list != null && list.isNotEmpty) ? list.first as Map : null;
    final desc = (w?['description'] as String?) ?? '';
    final cond = (w?['main'] as String?) ?? '';

    return WeatherInfo(
      temperatureC: temp,
      description: desc.isEmpty ? 'Thời tiết' : _capitalize(desc),
      condition: _mapCondition(cond),
      city: json['name'] as String?,
      humidity: humidity,
      tempMax: tempMax,
      tempMin: tempMin,
    );
  }

  WeatherCondition _mapCondition(String main) {
    switch (main) {
      case 'Clear':
        return WeatherCondition.clear;
      case 'Clouds':
        return WeatherCondition.clouds;
      case 'Rain':
      case 'Drizzle':
        return WeatherCondition.rainy;
      case 'Thunderstorm':
        return WeatherCondition.storm;
      case 'Snow':
        return WeatherCondition.snow;
      default:
        return WeatherCondition.mist;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  WeatherInfo _defaultInfo() => const WeatherInfo(
        temperatureC: 30,
        description: 'Trời nắng',
        condition: WeatherCondition.clear,
        city: 'TP. Hồ Chí Minh',
        humidity: 70,
        tempMax: 32,
        tempMin: 26,
      );
}
