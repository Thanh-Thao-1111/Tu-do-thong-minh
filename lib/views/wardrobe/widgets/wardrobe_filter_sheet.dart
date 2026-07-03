import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../models/clothing_color.dart';
import '../../../models/enums.dart';
import '../../../viewmodels/wardrobe_viewmodel.dart';

/// Mở bottom sheet bộ lọc nâng cao (phong cách + màu sắc).
Future<void> showWardrobeFilterSheet(
    BuildContext context, WardrobeViewModel vm) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (_) => _WardrobeFilterSheet(vm: vm),
  );
}

class _WardrobeFilterSheet extends StatefulWidget {
  const _WardrobeFilterSheet({required this.vm});
  final WardrobeViewModel vm;

  @override
  State<_WardrobeFilterSheet> createState() => _WardrobeFilterSheetState();
}

class _WardrobeFilterSheetState extends State<_WardrobeFilterSheet> {
  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppPalette.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text('Bộ lọc',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  if (vm.activeFilterCount > 0)
                    TextButton(
                      onPressed: () {
                        vm.clearFilters();
                        setState(() {});
                      },
                      child: const Text('Xóa lọc'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _label('Phong cách'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: StyleTag.values.map((s) {
                  return _pill(
                    label: s.label,
                    selected: vm.styleFilter == s,
                    onTap: () {
                      vm.setStyleFilter(s);
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              _label('Màu sắc'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ColorPalette.basics.map((c) {
                  final selected = vm.colorFilter == c.name;
                  return GestureDetector(
                    onTap: () {
                      vm.setColorFilter(c.name);
                      setState(() {});
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.fromLTRB(6, 6, 14, 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppPalette.primarySurface
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppPalette.rChip),
                        border: Border.all(
                          color: selected
                              ? AppPalette.primary
                              : AppPalette.border,
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
                              color: c.color,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppPalette.border),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(c.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: selected
                                      ? AppPalette.primary
                                      : AppPalette.ink)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Xem ${vm.items.length} kết quả'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15));

  Widget _pill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppPalette.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppPalette.rChip),
          border: Border.all(
              color: selected ? AppPalette.primary : AppPalette.border),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? Colors.white : AppPalette.ink)),
      ),
    );
  }
}
