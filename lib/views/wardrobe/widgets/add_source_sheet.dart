import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_palette.dart';

/// Bottom sheet kiểu iOS để chọn nguồn ảnh khi thêm trang phục.
/// Trả về [ImageSource] đã chọn (hoặc null nếu đóng).
Future<ImageSource?> showAddSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (ctx) => const _AddSourceSheet(),
  );
}

class _AddSourceSheet extends StatelessWidget {
  const _AddSourceSheet();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.62;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 22),
            const Text('Thêm trang phục',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Chụp ảnh mới hoặc chọn từ thư viện của bạn',
                style: TextStyle(color: AppPalette.inkSoft, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            _SourceCard(
              icon: Icons.camera_alt_rounded,
              title: 'Chụp ảnh',
              subtitle: 'Dùng camera chụp trực tiếp món đồ',
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 14),
            _SourceCard(
              icon: Icons.photo_library_rounded,
              title: 'Chọn từ thư viện',
              subtitle: 'Lấy ảnh có sẵn trong máy',
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.primarySurface,
      borderRadius: BorderRadius.circular(AppPalette.rCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppPalette.rCard),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppPalette.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppPalette.inkSoft,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppPalette.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
