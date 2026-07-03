import 'package:flutter/foundation.dart';

import '../models/diary_entry.dart';
import '../models/outfit.dart';
import '../models/wardrobe_item.dart';
import '../models/weather_info.dart';
import '../repositories/diary_repository.dart';
import '../repositories/wardrobe_repository.dart';
import '../services/outfit_recommendation_service.dart';
import '../services/weather_service.dart';

/// Quản lý trạng thái Trang chủ:
/// thời tiết hôm nay, tổng số món trong tủ, gợi ý nhanh và trang phục gần đây.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel(
    this._weatherService,
    this._wardrobeRepo,
    this._reco,
    this._diaryRepo,
  );

  final WeatherService _weatherService;
  final WardrobeRepository _wardrobeRepo;
  final OutfitRecommendationService _reco;
  final DiaryRepository _diaryRepo;

  bool _loading = false;

  /// True khi đang tải dữ liệu lần đầu.
  bool get loading => _loading;

  WeatherInfo? _weather;

  /// Thông tin thời tiết hiện tại (null nếu chưa tải xong lần đầu).
  WeatherInfo? get weather => _weather;

  int _itemCount = 0;

  /// Tổng số món đồ trong tủ — hiển thị trên thẻ tóm tắt Trang chủ.
  int get itemCount => _itemCount;

  Outfit? _quickPick;

  /// Gợi ý outfit nhanh cho ngày hôm nay — dựa trên thời tiết và tủ đồ hiện có.
  Outfit? get quickPick => _quickPick;

  List<WardrobeItem> _recentlyAdded = [];

  /// Các món đồ mới thêm gần đây (tối đa 10) — hiển thị ở "Tủ đồ gần đây".
  List<WardrobeItem> get recentlyAdded => _recentlyAdded;

  List<Outfit> _recentOutfits = [];

  /// Các bộ đồ đã mặc gần đây (từ nhật ký) — hiển thị ở "Bộ đồ gần đây".
  List<Outfit> get recentOutfits => _recentOutfits;

  /// Tải toàn bộ dữ liệu Trang chủ: thời tiết + tủ đồ + nhật ký.
  ///
  /// **Chiến lược**: Hiển thị thời tiết cũ (cached) NGAY, sau đó lấy song song
  /// 3 nguồn dữ liệu để tránh chờ tuần tự.
  Future<void> load() async {
    _loading = true;
    _weather = _weatherService.cached ?? _weather; // hiện thời tiết cũ NGAY
    notifyListeners();

    // Lấy song song để tối thiểu thời gian chờ.
    final results = await Future.wait([
      _weatherService.current(),  // thời tiết mới
      _wardrobeRepo.fetchAll(),   // tủ đồ
      _diaryRepo.fetchAll(),      // nhật ký
    ]);
    _weather = results[0] as WeatherInfo;
    _applyData(
      results[1] as List<WardrobeItem>,
      results[2] as List<DiaryEntry>,
    );
    _loading = false;
    notifyListeners();
  }

  /// Tải lại tủ đồ + nhật ký mà không gọi lại thời tiết.
  /// Dùng sau khi người dùng bấm "Đã mặc" để "Bộ đồ gần đây" cập nhật tức thì.
  Future<void> refreshItems() async {
    final results = await Future.wait([
      _wardrobeRepo.fetchAll(),
      _diaryRepo.fetchAll(),
    ]);
    _applyData(
      results[0] as List<WardrobeItem>,
      results[1] as List<DiaryEntry>,
    );
    notifyListeners();
  }

  /// Xử lý dữ liệu thô → cập nhật các trường hiển thị.
  void _applyData(List<WardrobeItem> items, List<DiaryEntry> entries) {
    _itemCount = items.length;
    _recentlyAdded = items.take(10).toList(); // mới nhất trước (theo createdAt)

    // Gom các món của từng bộ đồ trong nhật ký thành 1 Outfit để hiển thị collage.
    final index = {for (final i in items) i.id: i}; // map id → item
    _recentOutfits = entries
        .take(10)
        .map(
          (e) => Outfit(
            id: e.id,
            items: e.itemIds
                .map((id) => index[id])
                .whereType<WardrobeItem>()  // bỏ null (món đã xóa)
                .toList(),
          ),
        )
        .where((o) => o.items.isNotEmpty) // bỏ bộ rỗng
        .toList();

    // Sinh 1 gợi ý nhanh dựa trên thời tiết hiện tại.
    final recs = _reco.recommend(items, weather: _weather, count: 1);
    _quickPick = recs.isNotEmpty ? recs.first : null;
  }
}
