import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../models/enums.dart';
import '../../viewmodels/wardrobe_viewmodel.dart';
import 'pages/add_item_page.dart';
import 'pages/category_items_page.dart';
import 'widgets/add_source_sheet.dart';

/// Trang Tủ đồ: lưới 6 danh mục (2 cột). Bấm 1 danh mục để xem các món bên trong.
class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  Future<void> _onAdd() async {
    final source = await showAddSourceSheet(context);
    if (source == null || !mounted) return;
    final file = await ImagePicker()
        .pickImage(source: source, maxWidth: 1280, imageQuality: 80);
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddItemPage(initialImage: bytes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WardrobeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tủ đồ của tôi'),
        actions: [
          IconButton(
            onPressed: _onAdd,
            tooltip: 'Thêm trang phục',
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: _categoryGrid(context, vm),
            ),
    );
  }

  /// 6 danh mục xếp 3 hàng × 2 cột, chia đều chiều cao -> vừa khít 1 màn hình,
  /// không cuộn (ClothingCategory hiện có đúng 6 mục).
  Widget _categoryGrid(BuildContext context, WardrobeViewModel vm) {
    final cats = ClothingCategory.values;

    Widget cell(ClothingCategory c) => _CategoryCard(
          category: c,
          count: vm.countByCategory(c),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CategoryItemsPage(category: c)),
          ),
        );

    Widget row(ClothingCategory a, ClothingCategory b) => Expanded(
          child: Row(
            children: [
              Expanded(child: cell(a)),
              const SizedBox(width: 16),
              Expanded(child: cell(b)),
            ],
          ),
        );

    return Column(
      children: [
        row(cats[0], cats[1]),
        const SizedBox(height: 16),
        row(cats[2], cats[3]),
        const SizedBox(height: 16),
        row(cats[4], cats[5]),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.onTap,
  });

  final ClothingCategory category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              // Ảnh đại diện danh mục; hiệu ứng nhấn/hover chỉ nằm trong ô ảnh.
              child: Material(
                color: AppPalette.primarySurface,
                child: Ink.image(
                  image: AssetImage(category.imageAsset),
                  fit: BoxFit.cover,
                  child: InkWell(onTap: onTap, child: const SizedBox.expand()),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(category.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 2),
          Text('$count món đồ',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppPalette.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
