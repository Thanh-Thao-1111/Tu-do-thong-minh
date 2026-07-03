import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

/// Ô "dropdown nhiều lựa chọn": nhìn như một dropdown (viền + mũi tên), bấm vào
/// mở bảng tick chọn nhiều mục. Dùng cho màu sắc / phong cách / mùa / ngữ cảnh.
class MultiSelectDropdownField<T> extends StatelessWidget {
  const MultiSelectDropdownField({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.fieldLabel,
    this.iconOf,
    this.colorOf,
  });

  /// Tiêu đề hiển thị trên bảng chọn.
  final String title;

  /// Nhãn nổi trong ô (để null nếu bên ngoài đã có tiêu đề riêng).
  final String? fieldLabel;

  final List<T> options;
  final List<T> selected;
  final String Function(T) labelOf;
  final ValueChanged<List<T>> onChanged;
  final IconData? Function(T)? iconOf;
  final Color? Function(T)? colorOf;

  @override
  Widget build(BuildContext context) {
    final hasSel = selected.isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openSheet(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: fieldLabel,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
        ),
        child: Text(
          hasSel ? selected.map(labelOf).join(', ') : 'Chưa chọn',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            color: hasSel ? AppPalette.ink : AppPalette.inkSoft,
          ),
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final working = List<T>.of(selected);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 12, 4),
                child: Row(
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        onChanged(List<T>.of(working));
                        Navigator.pop(ctx);
                      },
                      child: const Text('Xong',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: options.map((o) {
                    final sel = working.contains(o);
                    final color = colorOf?.call(o);
                    final icon = iconOf?.call(o);
                    return CheckboxListTile(
                      value: sel,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppPalette.primary,
                      title: Row(
                        children: [
                          if (color != null) ...[
                            CircleAvatar(radius: 9, backgroundColor: color),
                            const SizedBox(width: 12),
                          ] else if (icon != null) ...[
                            Icon(icon, size: 20, color: AppPalette.primary),
                            const SizedBox(width: 12),
                          ],
                          Text(labelOf(o),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      onChanged: (_) => setSheet(
                          () => sel ? working.remove(o) : working.add(o)),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
