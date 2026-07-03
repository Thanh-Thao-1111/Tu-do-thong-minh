import 'package:flutter/material.dart';

import '../../../core/icons/ph_icons.dart';
import '../../../core/theme/app_palette.dart';
import '../../../models/outfit.dart';
import '../../widgets/item_image.dart';

/// Thẻ outfit được gợi ý — thiết kế premium: hero image, score bar, pills màu.
class OutfitCard extends StatelessWidget {
  const OutfitCard({
    super.key,
    required this.outfit,
    required this.rank,
    this.onSave,
    this.saved = false,
  });

  final Outfit outfit;
  final int rank;
  final VoidCallback? onSave;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final scorePoint = (outfit.score * 100).clamp(0, 100).round();
    final isTop = rank == 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppPalette.rCard),
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: AppPalette.primary.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ]
            : AppPalette.softShadow,
        border: isTop
            ? Border.all(
                color: AppPalette.primary.withValues(alpha: 0.35), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header gradient ──────────────────────────────────────────────
          _CardHeader(rank: rank, scorePoint: scorePoint, onSave: onSave, saved: saved),

          // ── Lưới ảnh món đồ ──────────────────────────────────────────────
          _ItemsGrid(items: outfit.items),

          // ── Score breakdown ──────────────────────────────────────────────
          if (outfit.scoreBreakdown.isNotEmpty)
            _ScoreSection(breakdown: outfit.scoreBreakdown),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.rank,
    required this.scorePoint,
    required this.onSave,
    required this.saved,
  });

  final int rank;
  final int scorePoint;
  final VoidCallback? onSave;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final isTop = rank == 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 14),
      decoration: BoxDecoration(
        gradient: isTop ? AppPalette.heroGradient : null,
        color: isTop ? null : AppPalette.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppPalette.rCard),
        ),
      ),
      child: Row(
        children: [
          // Badge xếp hạng
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isTop
                  ? Colors.white.withValues(alpha: 0.25)
                  : AppPalette.primarySurface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isTop
                ? const Icon(PhIcons.crown, color: Colors.white, size: 24)
                : Text(
                    '$rank',
                    style: const TextStyle(
                      color: AppPalette.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Nhãn + điểm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _rankLabel(rank),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isTop ? Colors.white : AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                // Score progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: scorePoint / 100,
                    minHeight: 6,
                    backgroundColor: isTop
                        ? Colors.white.withValues(alpha: 0.30)
                        : AppPalette.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isTop ? Colors.white : AppPalette.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Độ phù hợp $scorePoint/100',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isTop
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppPalette.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          // Nút lưu
          if (onSave != null)
            _SaveButton(saved: saved, isTop: isTop, onSave: onSave),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton(
      {required this.saved, required this.isTop, required this.onSave});
  final bool saved;
  final bool isTop;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: IconButton(
        key: ValueKey(saved),
        onPressed: saved ? null : onSave,
        iconSize: 26,
        tooltip: saved ? 'Đã lưu vào nhật ký' : 'Lưu vào nhật ký',
        style: IconButton.styleFrom(
          foregroundColor: isTop ? Colors.white : AppPalette.primary,
          disabledForegroundColor:
              isTop ? Colors.white.withValues(alpha: 0.55) : AppPalette.primaryTint,
        ),
        icon: Icon(
          saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lưới ảnh món đồ
// ─────────────────────────────────────────────────────────────────────────────

class _ItemsGrid extends StatelessWidget {
  const _ItemsGrid({required this.items});
  final List items;

  @override
  Widget build(BuildContext context) {
    // Hiển thị tối đa 4 món theo layout linh hoạt.
    final display = items.take(4).toList();
    final extra = items.length - display.length; // số món bị ẩn

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        children: [
          if (display.length == 1)
            _OneItem(item: display[0])
          else if (display.length == 2)
            _TwoItems(items: display)
          else if (display.length == 3)
            _ThreeItems(items: display)
          else
            _FourItems(items: display, extra: extra),
        ],
      ),
    );
  }
}

class _OneItem extends StatelessWidget {
  const _OneItem({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ItemImage(item: item, iconSize: 56),
            _ItemLabel(item: item),
          ],
        ),
      ),
    );
  }
}

class _TwoItems extends StatelessWidget {
  const _TwoItems({required this.items});
  final List items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ItemTile(item: items[0], height: 160)),
        const SizedBox(width: 10),
        Expanded(child: _ItemTile(item: items[1], height: 160)),
      ],
    );
  }
}

class _ThreeItems extends StatelessWidget {
  const _ThreeItems({required this.items});
  final List items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _ItemTile(item: items[0], height: 160),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _ItemTile(item: items[1], height: 75),
              const SizedBox(height: 10),
              _ItemTile(item: items[2], height: 75),
            ],
          ),
        ),
      ],
    );
  }
}

class _FourItems extends StatelessWidget {
  const _FourItems({required this.items, required this.extra});
  final List items;
  final int extra;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ItemTile(item: items[0], height: 160)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              _ItemTile(item: items[1], height: 75),
              const SizedBox(height: 10),
              SizedBox(
                height: 75,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ItemImage(item: items[2], iconSize: 28),
                      if (extra > 0)
                        Container(
                          color: Colors.black.withValues(alpha: 0.45),
                          alignment: Alignment.center,
                          child: Text(
                            '+$extra',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      if (extra == 0) _ItemLabel(item: items[2]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tile ảnh đơn với nhãn tên ở dưới.
class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.height});
  final dynamic item;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ItemImage(item: item, iconSize: 32),
            _ItemLabel(item: item),
          ],
        ),
      ),
    );
  }
}

/// Nhãn tên món đồ nổi trên ảnh (bottom overlay gradient).
class _ItemLabel extends StatelessWidget {
  const _ItemLabel({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.62),
              Colors.transparent,
            ],
          ),
        ),
        child: Text(
          item.name as String,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Score section
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreSection extends StatelessWidget {
  const _ScoreSection({required this.breakdown});
  final Map<String, double> breakdown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết điểm',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppPalette.inkSoft,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: breakdown.entries.map((e) {
              final label = e.key == 'Thời tiết' ? 'Thời tiết' : e.key;
              final max = _maxFor(e.key);
              final pt = (e.value.clamp(0.0, 1.0) * max).round();
              final ratio = e.value.clamp(0.0, 1.0);
              return _ScorePill(
                label: label,
                point: pt,
                max: max,
                ratio: ratio,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  int _maxFor(String key) {
    if (key == 'Màu sắc') return 25;
    if (key == 'Phong cách') return 25;
    if (key == 'Ngữ cảnh') return 25;
    if (key == 'Thời tiết') return 15;
    if (key == 'Đa dạng') return 10;
    return 100;
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.label,
    required this.point,
    required this.max,
    required this.ratio,
  });

  final String label;
  final int point;
  final int max;
  final double ratio;

  Color get _color {
    if (ratio >= 0.8) return const Color(0xFF059669); // emerald-600
    if (ratio >= 0.6) return const Color(0xFF0EA5E9); // sky-500
    if (ratio >= 0.4) return const Color(0xFFF59E0B); // amber-500
    return const Color(0xFFEF4444); // red-500
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppPalette.rChip),
        border: Border.all(color: _color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$label  $point/$max',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _rankLabel(int rank) => switch (rank) {
      1 => '✨ Nổi bật nhất',
      2 => 'Nổi bật',
      3 => 'Phù hợp',
      4 => 'Đáng thử',
      5 => 'Cân nhắc',
      _ => 'Gợi ý #$rank',
    };
