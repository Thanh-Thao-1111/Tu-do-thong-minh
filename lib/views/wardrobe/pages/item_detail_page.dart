import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../models/clothing_color.dart';
import '../../../models/enums.dart';
import '../../../models/wardrobe_item.dart';
import '../../../viewmodels/wardrobe_viewmodel.dart';
import '../../widgets/item_image.dart';
import '../widgets/attribute_dropdown.dart';

/// Trang chi tiết & chỉnh sửa một món đồ (premium, form dạng section card).
class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.itemId});
  final String itemId;

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  WardrobeItem? _item;
  late final TextEditingController _name;
  late final TextEditingController _pattern;
  late final TextEditingController _material;
  late ClothingCategory _category;
  String? _subtype;
  late final List<ClothingColor> _colors;
  late final List<StyleTag> _styles;
  late final List<Season> _seasons;
  late final List<Occasion> _occasions;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = context.read<WardrobeViewModel>().byId(widget.itemId);
    _item = item;
    _name = TextEditingController(text: item?.name ?? '');
    _pattern = TextEditingController(text: item?.pattern ?? '');
    _material = TextEditingController(text: item?.material ?? '');
    _category = item?.category ?? ClothingCategory.top;
    _subtype = item?.subtype;
    _colors = [...?item?.colors];
    _styles = [...?item?.styles];
    _seasons = [...?item?.seasons];
    _occasions = [...?item?.occasions];
  }

  @override
  void dispose() {
    _name.dispose();
    _pattern.dispose();
    _material.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final vm = context.read<WardrobeViewModel>();
    final updated = _item!.copyWith(
      name: _name.text.trim().isEmpty ? _item!.name : _name.text.trim(),
      category: _category,
      subtype: _subtype,
      colors: List.of(_colors),
      styles: List.of(_styles),
      seasons: List.of(_seasons),
      occasions: List.of(_occasions),
      pattern: _pattern.text.trim().isEmpty ? null : _pattern.text.trim(),
      material: _material.text.trim().isEmpty ? null : _material.text.trim(),
    );
    await vm.update(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu thay đổi')),
    );
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa món đồ?'),
        content: Text('Xóa "${_item!.name}" khỏi tủ đồ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppPalette.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<WardrobeViewModel>().delete(_item!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Món đồ không tồn tại')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin trang phục'),
        actions: [
          IconButton(
            tooltip: 'Xóa',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _delete,
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(saving: _saving, onSave: _save),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1,
              child: ItemImage(item: item, iconSize: 80),
            ),
          ),
          const SizedBox(height: 18),
          _section(
            'Tên trang phục',
            TextField(
              controller: _name,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          _section(
            'Kiểu trang phục',
            DropdownButtonFormField<ClothingCategory>(
              initialValue: _category,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ClothingCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(children: [
                          Icon(c.icon, size: 18, color: AppPalette.primary),
                          const SizedBox(width: 10),
                          Text(c.label),
                        ]),
                      ))
                  .toList(),
              onChanged: (v) => setState(() {
                _category = v ?? _category;
                if (_subtype != null &&
                    !_category.subtypes.contains(_subtype)) {
                  _subtype = null;
                }
              }),
            ),
          ),
          _section(
            'Loại trang phục',
            DropdownButtonFormField<String?>(
              key: ValueKey('subtype-${_category.name}'),
              initialValue: _subtype,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('Không xác định')),
                ..._category.subtypes.map(
                    (s) => DropdownMenuItem<String?>(value: s, child: Text(s))),
              ],
              onChanged: (v) => setState(() => _subtype = v),
            ),
          ),
          _section(
            'Màu sắc',
            MultiSelectDropdownField<ClothingColor>(
              title: 'Màu sắc',
              options: ColorPalette.basics,
              selected: _colors,
              labelOf: (c) => c.name,
              colorOf: (c) => c.color,
              onChanged: (v) => setState(() => _colors
                ..clear()
                ..addAll(v)),
            ),
          ),
          _section(
            'Phong cách',
            MultiSelectDropdownField<StyleTag>(
              title: 'Phong cách',
              options: StyleTag.values,
              selected: _styles,
              labelOf: (s) => s.label,
              onChanged: (v) => setState(() => _styles
                ..clear()
                ..addAll(v)),
            ),
          ),
          _section(
            'Mùa phù hợp',
            MultiSelectDropdownField<Season>(
              title: 'Mùa phù hợp',
              options: Season.values,
              selected: _seasons,
              labelOf: (s) => s.label,
              onChanged: (v) => setState(() => _seasons
                ..clear()
                ..addAll(v)),
            ),
          ),
          _section(
            'Ngữ cảnh sử dụng',
            MultiSelectDropdownField<Occasion>(
              title: 'Ngữ cảnh sử dụng',
              options: Occasion.values,
              selected: _occasions,
              labelOf: (o) => o.label,
              iconOf: (o) => o.icon,
              onChanged: (v) => setState(() => _occasions
                ..clear()
                ..addAll(v)),
            ),
          ),
          _section(
            'Chi tiết khác',
            Column(children: [
              TextField(
                controller: _pattern,
                decoration: const InputDecoration(
                  labelText: 'Hoa văn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _material,
                decoration: const InputDecoration(
                  labelText: 'Chất liệu',
                  border: OutlineInputBorder(),
                ),
              ),
            ]),
          ),
          _WearInfo(count: item.wearCount),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppPalette.rCard),
        boxShadow: AppPalette.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

}

class _WearInfo extends StatelessWidget {
  const _WearInfo({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppPalette.rCard),
        boxShadow: AppPalette.softShadow,
      ),
      child: Row(
        children: [
          const Icon(Icons.repeat_rounded, color: AppPalette.primary),
          const SizedBox(width: 12),
          const Text('Số lần đã mặc',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('$count',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.saving, required this.onSave});
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppPalette.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: saving ? null : onSave,
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
