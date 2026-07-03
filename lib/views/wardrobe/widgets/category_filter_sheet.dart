import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../models/clothing_color.dart';
import '../../../models/enums.dart';

/// Bộ lọc thuộc tính cho trang danh mục (đa chọn, độc lập với mỗi món).
class CategoryFilters {
  CategoryFilters({
    Set<StyleTag>? styles,
    Set<String>? colors,
    Set<Season>? seasons,
    Set<Occasion>? occasions,
  }) : styles = styles ?? {},
       colors = colors ?? {},
       seasons = seasons ?? {},
       occasions = occasions ?? {};

  final Set<StyleTag> styles;
  final Set<String> colors; // theo tên màu
  final Set<Season> seasons;
  final Set<Occasion> occasions;

  int get count =>
      styles.length + colors.length + seasons.length + occasions.length;

  CategoryFilters copy() => CategoryFilters(
    styles: {...styles},
    colors: {...colors},
    seasons: {...seasons},
    occasions: {...occasions},
  );
}

/// Mở bottom sheet lọc theo màu sắc / phong cách / mùa / ngữ cảnh.
/// Trả về [CategoryFilters] mới khi bấm "Áp dụng", null nếu đóng.
Future<CategoryFilters?> showCategoryFilterSheet(
  BuildContext context,
  CategoryFilters current,
) {
  return showModalBottomSheet<CategoryFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CategoryFilterSheet(initial: current),
  );
}

class _CategoryFilterSheet extends StatefulWidget {
  const _CategoryFilterSheet({required this.initial});
  final CategoryFilters initial;

  @override
  State<_CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<_CategoryFilterSheet> {
  late CategoryFilters _work = widget.initial.copy();

  void _toggle<T>(Set<T> set, T value) {
    setState(() => set.contains(value) ? set.remove(value) : set.add(value));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppPalette.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 4),
              child: Row(
                children: [
                  const Text(
                    'Bộ lọc',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  if (_work.count > 0)
                    TextButton(
                      onPressed: () => setState(() => _work = CategoryFilters()),
                      child: const Text('Xóa lọc'),
                    ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Màu sắc'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ColorPalette.basics.map((c) {
                        return _ColorPill(
                          color: c.color,
                          label: c.name,
                          selected: _work.colors.contains(c.name),
                          onTap: () => _toggle(_work.colors, c.name),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _label('Phong cách'),
                    _wrap(
                      StyleTag.values
                          .map(
                            (s) => _pill(
                              s.label,
                              _work.styles.contains(s),
                              () => _toggle(_work.styles, s),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    _label('Mùa phù hợp'),
                    _wrap(
                      Season.values
                          .map(
                            (s) => _pill(
                              s.label,
                              _work.seasons.contains(s),
                              () => _toggle(_work.seasons, s),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    _label('Ngữ cảnh sử dụng'),
                    _wrap(
                      Occasion.values
                          .map(
                            (o) => _pill(
                              o.label,
                              _work.occasions.contains(o),
                              () => _toggle(_work.occasions, o),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_work),
                  child: const Text('Áp dụng'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    ),
  );

  Widget _wrap(List<Widget> children) =>
      Wrap(spacing: 8, runSpacing: 8, children: children);

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppPalette.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppPalette.rChip),
          border: Border.all(
            color: selected ? AppPalette.primary : AppPalette.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? Colors.white : AppPalette.ink,
          ),
        ),
      ),
    );
  }
}

class _ColorPill extends StatelessWidget {
  const _ColorPill({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
        decoration: BoxDecoration(
          color: selected ? AppPalette.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(AppPalette.rChip),
          border: Border.all(
            color: selected ? AppPalette.primary : AppPalette.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: AppPalette.border),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? AppPalette.primary : AppPalette.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
