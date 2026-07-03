import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../models/outfit.dart';
import '../../../viewmodels/diary_viewmodel.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../viewmodels/suggestion_viewmodel.dart';
import '../widgets/outfit_card.dart';

/// Trang hiển thị kết quả gợi ý phối đồ.
class SuggestionResultPage extends StatelessWidget {
  const SuggestionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SuggestionViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: vm.loading
          ? const _Loading()
          : vm.outfits.isEmpty
              ? const _EmptyResult()
              : CustomScrollView(
                  slivers: [
                    _SliverHeader(vm: vm),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                      sliver: SliverList.separated(
                        itemCount: vm.outfits.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final outfit = vm.outfits[i];
                          return OutfitCard(
                            outfit: outfit,
                            rank: i + 1,
                            saved: vm.isSaved(outfit.id),
                            onSave: () => _logOutfit(context, vm, outfit),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _logOutfit(
      BuildContext context, SuggestionViewModel vm, Outfit outfit) async {
    vm.markSaved(outfit.id);
    final messenger = ScaffoldMessenger.of(context);
    final homeVM = context.read<HomeViewModel>();
    try {
      await context.read<DiaryViewModel>().logOutfit(
            outfit.itemIds,
            date: DateTime.now(),
            occasion: vm.occasion.label,
            style: vm.style?.label,
          );
      homeVM.refreshItems();
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Đã lưu vào nhật ký hôm nay'),
            ],
          ),
          backgroundColor: AppPalette.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Lưu nhật ký thất bại, vui lòng thử lại')),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sliver App Bar + tổng quan
// ─────────────────────────────────────────────────────────────────────────────

class _SliverHeader extends StatelessWidget {
  const _SliverHeader({required this.vm});
  final SuggestionViewModel vm;

  @override
  Widget build(BuildContext context) {
    final count = vm.outfits.length;
    final topScore = count > 0
        ? (vm.outfits.first.score * 100).clamp(0, 100).round()
        : 0;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 160,
      backgroundColor: AppPalette.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          tooltip: 'Gợi ý lại',
          onPressed: vm.loading
              ? null
              : () => context.read<SuggestionViewModel>().generate(),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(gradient: AppPalette.heroGradient),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gợi ý cho bạn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.checkroom_rounded,
                    label: '$count bộ đồ phù hợp',
                  ),
                  const SizedBox(width: 8),
                  if (topScore > 0)
                    _StatChip(
                      icon: Icons.star_rounded,
                      label: 'Top $topScore/100 điểm',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading
// ─────────────────────────────────────────────────────────────────────────────

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppPalette.heroGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'Đang tạo gợi ý phối đồ...',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppPalette.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hệ thống đang phân tích tủ đồ và thời tiết',
            style: TextStyle(color: AppPalette.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppPalette.primarySurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.checkroom_outlined,
                  size: 44, color: AppPalette.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa đủ món đồ',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppPalette.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thêm ít nhất một áo và một quần\n(hoặc váy) vào tủ đồ để bắt đầu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppPalette.inkSoft, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
