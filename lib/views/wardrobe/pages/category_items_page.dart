import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../models/enums.dart';
import '../../../models/wardrobe_item.dart';
import '../../../viewmodels/wardrobe_viewmodel.dart';
import '../widgets/category_filter_sheet.dart';
import '../widgets/wardrobe_item_tile.dart';
import 'item_detail_page.dart';

/// Danh sách các món đồ trong MỘT danh mục (mở từ lưới danh mục ở Tủ đồ).
/// Thanh tìm kiếm + lọc theo phong cách chỉ xuất hiện ở màn này.
class CategoryItemsPage extends StatefulWidget {
  const CategoryItemsPage({super.key, required this.category});

  final ClothingCategory category;

  @override
  State<CategoryItemsPage> createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
  String _query = '';
  String? _subtype;
  CategoryFilters _filters = CategoryFilters();

  List<WardrobeItem> _filter(List<WardrobeItem> all) {
    return all.where((i) {
      if (i.category != widget.category) return false;
      if (_subtype != null && i.subtype != _subtype) return false;
      if (_query.isNotEmpty &&
          !i.name.toLowerCase().contains(_query.toLowerCase())) {
        return false;
      }
      // Bộ lọc thuộc tính (đa chọn): món phải khớp ÍT NHẤT một mục mỗi nhóm bật.
      if (_filters.colors.isNotEmpty &&
          !i.colors.any((c) => _filters.colors.contains(c.name))) {
        return false;
      }
      if (_filters.styles.isNotEmpty &&
          !i.styles.any(_filters.styles.contains)) {
        return false;
      }
      if (_filters.seasons.isNotEmpty &&
          !i.seasons.any(_filters.seasons.contains)) {
        return false;
      }
      if (_filters.occasions.isNotEmpty &&
          !i.occasions.any(_filters.occasions.contains)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _openFilter() async {
    final result = await showCategoryFilterSheet(context, _filters);
    if (result != null) setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WardrobeViewModel>();
    final items = _filter(vm.all);

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.label)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Tìm trang phục',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _FilterButton(count: _filters.count, onTap: _openFilter),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SubtypeChips(
            subtypes: widget.category.subtypes,
            selected: _subtype,
            onSelected: (s) => setState(() => _subtype = s),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text('${items.length} món đồ',
                  style: const TextStyle(
                      color: AppPalette.inkSoft,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const _Empty()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final cols =
                          (constraints.maxWidth / 180).floor().clamp(2, 5);
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return WardrobeItemTile(
                            item: item,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ItemDetailPage(itemId: item.id),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SubtypeChips extends StatelessWidget {
  const _SubtypeChips({
    required this.subtypes,
    required this.selected,
    required this.onSelected,
  });

  final List<String> subtypes;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _Chip(
            label: 'Tất cả',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          ...subtypes.map(
            (s) => _Chip(
              label: s,
              selected: selected == s,
              onTap: () => onSelected(selected == s ? null : s),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? AppPalette.primary : Colors.white,
        borderRadius: BorderRadius.circular(AppPalette.rChip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppPalette.rChip),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppPalette.rChip),
              border: Border.all(
                  color: selected ? AppPalette.primary : AppPalette.border),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppPalette.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: active ? AppPalette.primary : AppPalette.border,
                  width: active ? 1.6 : 1,
                ),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: active ? AppPalette.primary : AppPalette.ink,
              ),
            ),
          ),
        ),
        if (active)
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppPalette.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checkroom_rounded, size: 48, color: AppPalette.inkSoft),
          SizedBox(height: 12),
          Text('Chưa có món đồ nào ở đây',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppPalette.inkSoft)),
        ],
      ),
    );
  }
}
