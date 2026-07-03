import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../models/outfit.dart';
import '../../models/wardrobe_item.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../diary/diary_page.dart';
import '../wardrobe/pages/item_detail_page.dart';
import '../widgets/item_image.dart';
import '../widgets/outfit_collage.dart';
import '../widgets/weather_card.dart';

/// Trang chủ "Góc trang phục".
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _quote =
      '"Thời trang chính là vỏ bọc sắt để đấu tranh với thực tại trong cuộc sống hằng ngày."';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().load();
      context.read<ProfileViewModel>().load();
    });
  }

  Future<void> _refresh() async {
    await context.read<HomeViewModel>().load();
    if (mounted) await context.read<ProfileViewModel>().load();
  }

  void _openItem(WardrobeItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: item.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const _AppHeader(),
            const SizedBox(height: 16),
            WeatherCard(weather: vm.weather),
            const SizedBox(height: 14),
            _OutfitPromptCard(
              quote: _quote,
              onExplore: () => context.read<MainViewModel>().setIndex(2),
            ),
            const SizedBox(height: 22),
            _SectionHeader(
              title: 'Trang phục gần đây',
              onSeeAll: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AllOutfitsPage()),
              ),
            ),
            const SizedBox(height: 10),
            _HorizontalOutfits(
              outfits: vm.recentOutfits,
              emptyHint: 'Chưa mặc bộ đồ nào gần đây',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AllOutfitsPage()),
              ),
            ),
            const SizedBox(height: 22),
            _SectionHeader(
              title: 'Món đồ mới',
              onSeeAll: () => context.read<MainViewModel>().setIndex(1),
            ),
            const SizedBox(height: 10),
            _HorizontalItems(
              items: vm.recentlyAdded,
              emptyHint: 'Chưa có sản phẩm nào, hãy thêm trang phục',
              onTap: _openItem,
            ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header trang chủ: tên app in đậm (không icon).
class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'TỦ ĐỒ THÔNG MINH',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
    );
  }
}

class _OutfitPromptCard extends StatelessWidget {
  const _OutfitPromptCard({required this.quote, required this.onExplore});
  final String quote;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppPalette.rCard),
        boxShadow: AppPalette.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppPalette.primary, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('MẶC GÌ HÔM NAY',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                      color: AppPalette.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(quote,
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppPalette.inkSoft,
                  fontSize: 14,
                  height: 1.4)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onExplore,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppPalette.heroGradient,
                borderRadius: BorderRadius.circular(AppPalette.rButton),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Khám phá ngay',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text('Xem tất cả',
              style: TextStyle(
                  color: AppPalette.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ],
    );
  }
}

class _HorizontalItems extends StatelessWidget {
  const _HorizontalItems({
    required this.items,
    required this.emptyHint,
    required this.onTap,
  });

  final List<WardrobeItem> items;
  final String emptyHint;
  final void Function(WardrobeItem) onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppPalette.rCard),
          boxShadow: AppPalette.subtleShadow,
        ),
        child: Text(emptyHint,
            style: const TextStyle(color: AppPalette.inkSoft)),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return GestureDetector(
            onTap: () => onTap(item),
            child: Container(
              width: 124,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppPalette.rCard),
                boxShadow: AppPalette.softShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppPalette.rCard),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: ItemImage(item: item, iconSize: 30)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                      child: Text(item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Danh sách ngang các BỘ ĐỒ đã mặc gần đây — mỗi bộ ghép tất cả món thành 1
/// ảnh collage (giống thẻ ở Lịch sử phối đồ).
class _HorizontalOutfits extends StatelessWidget {
  const _HorizontalOutfits({
    required this.outfits,
    required this.emptyHint,
    required this.onTap,
  });

  final List<Outfit> outfits;
  final String emptyHint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (outfits.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppPalette.rCard),
          boxShadow: AppPalette.subtleShadow,
        ),
        child: Text(emptyHint,
            style: const TextStyle(color: AppPalette.inkSoft)),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: outfits.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final outfit = outfits[i];
          return GestureDetector(
            onTap: onTap,
            child: Container(
              width: 124,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppPalette.rCard),
                boxShadow: AppPalette.softShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppPalette.rCard),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: OutfitCollage(
                        items: outfit.items,
                        cellIconSize: 22,
                        singleIconSize: 40,
                        borderRadius: 0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                      child: Text('${outfit.items.length} món đồ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
