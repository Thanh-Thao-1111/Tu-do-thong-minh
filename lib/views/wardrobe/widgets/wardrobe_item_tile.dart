import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../models/wardrobe_item.dart';
import '../../widgets/item_image.dart';

/// Thẻ hiển thị một món đồ trong lưới tủ đồ (Container + shadow nhẹ).
class WardrobeItemTile extends StatelessWidget {
  const WardrobeItemTile({super.key, required this.item, this.onTap});

  final WardrobeItem item;
  final VoidCallback? onTap;

  /// Phụ đề: "Màu · Phong cách" (lấy mục đầu tiên), bỏ trống nếu chưa có.
  String _subtitle() {
    final parts = <String>[
      if (item.colors.isNotEmpty) item.colors.first.name,
      if (item.styles.isNotEmpty) item.styles.first.label,
    ];
    return parts.isEmpty ? item.category.label : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppPalette.rCard),
        boxShadow: AppPalette.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppPalette.rCard),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: ItemImage(item: item)),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppPalette.subtleShadow,
                          ),
                          child: Icon(item.category.icon,
                              size: 13, color: AppPalette.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.inkSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
