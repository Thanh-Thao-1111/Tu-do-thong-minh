import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../models/wardrobe_item.dart';
import 'item_image.dart';

/// Ảnh ghép TẤT CẢ các món trong một bộ đồ thành một ô: 1 ảnh / 2 ảnh / lưới
/// 2x2 (ô thứ 4 hiện "+N" nếu dư). Tự lấp đầy không gian cha — dùng chung cho
/// Nhật ký thời trang và "Trang phục gần đây" ở Trang chủ.
class OutfitCollage extends StatelessWidget {
  const OutfitCollage({
    super.key,
    required this.items,
    this.cellIconSize = 14,
    this.singleIconSize = 24,
    this.borderRadius = 14,
  });

  final List<WardrobeItem> items;

  /// Cỡ icon mỗi ô khi ghép nhiều món.
  final double cellIconSize;

  /// Cỡ icon khi bộ đồ chỉ có 1 món.
  final double singleIconSize;

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _content(),
    );
  }

  Widget _cell(WardrobeItem item) =>
      ItemImage(item: item, iconSize: cellIconSize);
  Widget _blank() => Container(color: AppPalette.background);

  Widget _content() {
    if (items.isEmpty) return _blank();
    if (items.length == 1) {
      return ItemImage(item: items.first, iconSize: singleIconSize);
    }
    if (items.length == 2) {
      return Row(
        children: [
          Expanded(child: _cell(items[0])),
          const SizedBox(width: 1),
          Expanded(child: _cell(items[1])),
        ],
      );
    }
    // 3+ món -> lưới 2x2; nếu hơn 4 thì ô cuối hiện "+N".
    final tiles = <Widget>[_cell(items[0]), _cell(items[1]), _cell(items[2])];
    if (items.length == 3) {
      tiles.add(_blank());
    } else if (items.length == 4) {
      tiles.add(_cell(items[3]));
    } else {
      tiles.add(_moreTile(items[3], items.length - 4));
    }
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: tiles[0]),
              const SizedBox(width: 1),
              Expanded(child: tiles[1]),
            ],
          ),
        ),
        const SizedBox(height: 1),
        Expanded(
          child: Row(
            children: [
              Expanded(child: tiles[2]),
              const SizedBox(width: 1),
              Expanded(child: tiles[3]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moreTile(WardrobeItem item, int extra) => Stack(
    fit: StackFit.expand,
    children: [
      _cell(item),
      Container(
        color: Colors.black.withValues(alpha: 0.5),
        alignment: Alignment.center,
        child: Text(
          '+$extra',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    ],
  );
}
