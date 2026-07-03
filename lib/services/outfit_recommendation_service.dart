import '../models/diary_entry.dart';
import '../models/enums.dart';
import '../models/outfit.dart';
import '../models/wardrobe_item.dart';
import '../models/weather_info.dart';

/// Module gợi ý phối đồ: kết hợp luật phối (rule-based) và so khớp thuộc tính
/// (metadata matching) để sinh & xếp hạng các outfit hợp lệ từ tủ đồ.
class OutfitRecommendationService {
  /// Các màu trung tính — luôn dễ phối với mọi màu khác.
  static const _neutralColors = {
    'Đen', 'Trắng', 'Xám', 'Be', 'Nâu', 'Xanh navy',
  };

  /// Trọng số các tiêu chí khi tính điểm tổng.
  static const _wColor = 0.25;
  static const _wStyle = 0.25;
  static const _wWeather = 0.15;
  static const _wOccasion = 0.25;
  static const _wDiversity = 0.10;

  /// Sinh tối đa [count] outfit phù hợp nhất.
  ///
  /// [recentDiary] — danh sách nhật ký gần đây (từ Firestore/local).
  /// [hardExcludeDays] — số ngày "cấm" tuyệt đối (mặc định 1 = không lặp hôm nay/hôm qua).
  /// [penaltyWindowDays] — cửa sổ tính điểm penalty (mặc định 3 ngày).
  List<Outfit> recommend(
    List<WardrobeItem> wardrobe, {
    Occasion? occasion,
    WeatherInfo? weather,
    StyleTag? style,
    int count = 5,
    List<DiaryEntry> recentDiary = const [],
    int hardExcludeDays = 3,
    int penaltyWindowDays = 3,
  }) {
    final now = DateTime.now();

    // ── Lọc cứng: món mặc trong [hardExcludeDays] ngày gần nhất bị loại hoàn toàn ──
    final hardCutoff = now.subtract(Duration(days: hardExcludeDays));
    final hardExcludedIds = <String>{
      for (final entry in recentDiary)
        if (entry.date.isAfter(hardCutoff))
          ...entry.itemIds,
    };

    // ── Bảng tra nhanh: item id → ngày mặc gần nhất (trong penaltyWindowDays) ──
    final penaltyCutoff = now.subtract(Duration(days: penaltyWindowDays));
    final lastWornMap = <String, DateTime>{};
    for (final entry in recentDiary) {
      if (entry.date.isBefore(penaltyCutoff)) continue;
      for (final id in entry.itemIds) {
        final existing = lastWornMap[id];
        if (existing == null || entry.date.isAfter(existing)) {
          lastWornMap[id] = entry.date;
        }
      }
    }

    List<WardrobeItem> exclude(List<WardrobeItem> list) =>
        list.where((i) => !hardExcludedIds.contains(i.id)).toList();

    // Lọc cứng đồ bị cấm ra khỏi mọi danh sách trước khi tổ hợp.
    final tops    = exclude(wardrobe.where((i) => i.category == ClothingCategory.top).toList());
    final bottoms = exclude(wardrobe.where((i) => i.category == ClothingCategory.bottom).toList());
    final dresses = exclude(wardrobe.where((i) => i.category == ClothingCategory.dress).toList());
    final shoes   = exclude(wardrobe.where((i) => i.category == ClothingCategory.shoes).toList());
    final outers  = exclude(wardrobe.where((i) => i.category == ClothingCategory.outerwear).toList());
    final accessories = exclude(wardrobe.where((i) => i.category == ClothingCategory.accessory).toList());

    final candidates = <Outfit>[];

    void buildFrom(List<WardrobeItem> core) {
      // Phần lõi + các thành phần bổ sung (tùy chọn): giày, áo khoác, phụ kiện.
      final base = [...core];
      final shoe = _bestMatch(shoes, base);
      if (shoe != null) base.add(shoe);
      if (weather != null && weather.isCold) {
        final outer = _bestMatch(outers, base);
        if (outer != null) base.add(outer);
      }
      // Thêm tối đa 3 phụ kiện khớp nhất (túi, mũ, kính, trang sức...) nếu tủ có
      // -> một bộ đồ có thể phối 2-3 phụ kiện cùng lúc.
      base.addAll(_bestMatches(accessories, base, 3));
      final outfit = Outfit(
        id: Outfit.generateId(),
        items: base,
        occasion: occasion,
      );
      if (outfit.isValid) {
        final scored = _score(
          outfit,
          occasion: occasion,
          weather: weather,
          style: style,
          lastWornMap: lastWornMap,
          now: now,
          penaltyWindowDays: penaltyWindowDays,
        );
        candidates.add(scored);
      }
    }

    // Outfit dạng áo + quần.
    for (final t in tops) {
      for (final b in bottoms) {
        buildFrom([t, b]);
      }
    }
    // Outfit dạng váy/đầm.
    for (final d in dresses) {
      buildFrom([d]);
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.take(count).toList();
  }

  /// Chọn tối đa [max] món khớp nhất theo lối tham lam (greedy): mỗi lần chọn
  /// món hợp nhất với phần lõi hiện có rồi thêm vào lõi để chọn tiếp.
  /// Dùng để phối 2-3 phụ kiện trong cùng một bộ đồ.
  List<WardrobeItem> _bestMatches(
    List<WardrobeItem> options,
    List<WardrobeItem> core,
    int max,
  ) {
    final chosen = <WardrobeItem>[];
    final pool = [...options];
    final base = [...core];
    while (chosen.length < max && pool.isNotEmpty) {
      final pick = _bestMatch(pool, base);
      if (pick == null) break;
      chosen.add(pick);
      base.add(pick);
      pool.remove(pick);
    }
    return chosen;
  }

  /// Chọn món (giày/áo khoác...) khớp nhất với phần lõi hiện có.
  WardrobeItem? _bestMatch(List<WardrobeItem> options, List<WardrobeItem> core) {
    if (options.isEmpty) return null;
    WardrobeItem? best;
    double bestScore = -1;
    for (final o in options) {
      final s = _styleScore([...core, o]) + _colorScore([...core, o]);
      if (s > bestScore) {
        bestScore = s;
        best = o;
      }
    }
    return best;
  }

  Outfit _score(
    Outfit outfit, {
    Occasion? occasion,
    WeatherInfo? weather,
    StyleTag? style,
    Map<String, DateTime> lastWornMap = const {},
    DateTime? now,
    int penaltyWindowDays = 7,
  }) {
    final color = _colorScore(outfit.items);
    final styleConsistency = _styleScore(outfit.items);
    final weatherScore = _weatherScore(outfit.items, weather);
    final occasionScore = _occasionScore(outfit.items, occasion);
    final diversity = _diversityScore(
      outfit.items,
      lastWornMap: lastWornMap,
      now: now ?? DateTime.now(),
      penaltyWindowDays: penaltyWindowDays,
    );

    // Hệ số ưu tiên phong cách người dùng chọn (1.0 khi không lọc phong cách).
    final styleMult = style == null
        ? 1.0
        : (0.6 +
            0.4 *
                (outfit.items.where((i) => i.styles.contains(style)).length /
                    outfit.items.length));

    final total = (color * _wColor +
            styleConsistency * _wStyle +
            weatherScore * _wWeather +
            occasionScore * _wOccasion +
            diversity * _wDiversity) *
        styleMult;

    // scoreBreakdown được scale cùng hệ số → tổng pills luôn = điểm tổng.
    return Outfit(
      id: outfit.id,
      items: outfit.items,
      occasion: outfit.occasion,
      score: total,
      scoreBreakdown: {
        'Màu sắc': color * styleMult,
        'Phong cách': styleConsistency * styleMult,
        'Thời tiết': weatherScore * styleMult,
        'Ngữ cảnh': occasionScore * styleMult,
        'Đa dạng': diversity * styleMult,
      },
    );
  }

  /// Hòa hợp màu: trung tính luôn tốt; ít màu nổi khác nhau thì điểm cao.
  double _colorScore(List<WardrobeItem> items) {
    final nonNeutral = <String>{};
    for (final i in items) {
      final c = i.primaryColor;
      if (c == null) continue;
      if (!_neutralColors.contains(c.name)) nonNeutral.add(c.name);
    }
    if (nonNeutral.isEmpty) return 1.0; // toàn trung tính
    if (nonNeutral.length == 1) return 0.9; // 1 điểm nhấn
    if (nonNeutral.length == 2) return 0.7;
    return 0.45; // quá nhiều màu nổi
  }

  /// Đồng nhất phong cách: tỉ lệ các món chia sẻ ít nhất một phong cách chung.
  double _styleScore(List<WardrobeItem> items) {
    final counts = <StyleTag, int>{};
    for (final i in items) {
      for (final s in i.styles) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return 0.5;
    final maxShared = counts.values.reduce((a, b) => a > b ? a : b);
    return (maxShared / items.length).clamp(0.0, 1.0);
  }

  double _weatherScore(List<WardrobeItem> items, WeatherInfo? weather) {
    if (weather == null) return 0.7;
    final season = weather.season;
    var ok = 0;
    for (final i in items) {
      if (i.seasons.isEmpty || i.seasons.contains(season)) ok++;
    }
    return items.isEmpty ? 0.0 : ok / items.length;
  }

  double _occasionScore(List<WardrobeItem> items, Occasion? occasion) {
    if (occasion == null) return 0.7;
    var ok = 0;
    for (final i in items) {
      if (i.occasions.isEmpty || i.occasions.contains(occasion)) ok++;
    }
    return items.isEmpty ? 0.0 : ok / items.length;
  }

  /// Điểm đa dạng: kết hợp wearCount tổng thể và penalty theo ngày mặc gần nhất.
  ///
  /// Công thức penalty cho từng món:
  ///   daysSince = số ngày kể từ lần mặc gần nhất
  ///   itemPenalty = max(0, 1 - daysSince / penaltyWindowDays)
  /// → Mặc hôm qua: penalty ≈ 0.86 (rất cao), mặc 7 ngày trước: penalty = 0.
  double _diversityScore(
    List<WardrobeItem> items, {
    Map<String, DateTime> lastWornMap = const {},
    required DateTime now,
    int penaltyWindowDays = 7,
  }) {
    if (items.isEmpty) return 0.0;

    // Thành phần 1: tần suất tổng (wearCount thấp → điểm cao)
    final avgWear =
        items.map((i) => i.wearCount).reduce((a, b) => a + b) / items.length;
    final wearScore = (1.0 / (1.0 + avgWear)).clamp(0.0, 1.0);

    // Thành phần 2: penalty ngày gần nhất
    var totalPenalty = 0.0;
    for (final item in items) {
      final lastWorn = lastWornMap[item.id];
      if (lastWorn == null) continue; // chưa mặc trong cửa sổ → không bị phạt
      final daysSince = now.difference(lastWorn).inHours / 24.0;
      totalPenalty += (1.0 - daysSince / penaltyWindowDays).clamp(0.0, 1.0);
    }
    final avgPenalty = totalPenalty / items.length;

    // Điểm cuối: giảm theo penalty (penalty = 1 → điểm giảm 60%)
    return (wearScore * (1.0 - 0.6 * avgPenalty)).clamp(0.0, 1.0);
  }
}
