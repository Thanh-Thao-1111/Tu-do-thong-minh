import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../models/wardrobe_item.dart';
import '../../services/local_image_store.dart';

/// Hiển thị ảnh của một món đồ, ưu tiên theo thứ tự:
/// 1) ảnh bytes trong kho tạm (món vừa thêm),
/// 2) ảnh URL trên mạng (Storage sau này),
/// 3) ảnh placeholder pastel theo loại + icon.
class ItemImage extends StatelessWidget {
  const ItemImage({super.key, required this.item, this.iconSize = 40});

  final WardrobeItem item;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final store = context.read<LocalImageStore>();
    final bytes = store.get(item.id);

    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    final url = item.imageUrl;
    if (url != null && url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => _placeholder(),
        errorWidget: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final base = AppPalette.categoryColor(item.category);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(base.withValues(alpha: 0.55), Colors.white),
            Color.alphaBlend(base.withValues(alpha: 0.95), Colors.white),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          item.category.icon,
          size: iconSize,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
  }
}
