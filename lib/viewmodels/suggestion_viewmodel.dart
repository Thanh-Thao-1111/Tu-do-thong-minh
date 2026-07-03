import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/outfit.dart';
import '../models/weather_info.dart';
import '../repositories/outfit_repository.dart';
import '../repositories/wardrobe_repository.dart';
import '../services/outfit_recommendation_service.dart';
import '../services/weather_service.dart';

/// Quản lý trạng thái tab Gợi ý: chọn ngữ cảnh, lấy thời tiết, sinh outfit.
class SuggestionViewModel extends ChangeNotifier {
  SuggestionViewModel(
    this._wardrobeRepo,
    this._service,
    this._weatherService,
    this._outfitRepo,
  );

  final WardrobeRepository _wardrobeRepo;
  final OutfitRecommendationService _service;
  final WeatherService _weatherService;
  final OutfitRepository _outfitRepo;

  Occasion _occasion = Occasion.casual;
  Occasion get occasion => _occasion;

  StyleTag? _style;
  StyleTag? get style => _style;

  WeatherInfo? _weather;
  WeatherInfo? get weather => _weather;

  bool _loading = false;
  bool get loading => _loading;

  List<Outfit> _outfits = [];
  List<Outfit> get outfits => List.unmodifiable(_outfits);

  bool _generated = false;
  bool get generated => _generated;

  // Các outfit đã được bấm "Đã mặc" (theo id) -> để đổi màu nút & chống lưu trùng.
  final Set<String> _saved = {};
  bool isSaved(String outfitId) => _saved.contains(outfitId);
  void markSaved(String outfitId) {
    _saved.add(outfitId);
    notifyListeners();
  }

  void setOccasion(Occasion o) {
    _occasion = o;
    notifyListeners();
  }

  void setStyle(StyleTag? s) {
    _style = _style == s ? null : s;
    notifyListeners();
  }

  Future<void> loadWeather() async {
    _weather ??= _weatherService.cached; // hiện ngay nếu có (cũ)
    notifyListeners();
    _weather = await _weatherService.current(); // làm mới
    notifyListeners();
  }

  Future<void> generate() async {
    _loading = true;
    _saved.clear(); // gợi ý mới -> bỏ trạng thái đã lưu cũ
    notifyListeners();

    _weather ??= await _weatherService.current();
    final items = await _wardrobeRepo.fetchAll();
    _outfits = _service.recommend(
      items,
      occasion: _occasion,
      weather: _weather,
      style: _style,
      count: 5,
    );

    // Lưu toàn bộ outfit vừa sinh lên Firestore (mỗi outfit có id mới).
    for (final outfit in _outfits) {
      try {
        await _outfitRepo.save(outfit);
      } catch (e) {
        // Không chặn UI nếu lưu thất bại (offline, quota...).
        debugPrint('Lưu outfit thất bại: $e');
      }
    }

    _generated = true;
    _loading = false;
    notifyListeners();
  }
}
