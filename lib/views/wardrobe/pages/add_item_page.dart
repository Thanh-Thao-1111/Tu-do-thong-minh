import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../models/clothing_color.dart';
import '../../../models/enums.dart';
import '../../../services/attribute_extraction_service.dart';
import '../../../services/background_removal_service.dart';
import '../../../services/image_storage_service.dart';
import '../../../viewmodels/add_item_viewmodel.dart';
import '../../../viewmodels/wardrobe_viewmodel.dart';
import '../widgets/attribute_dropdown.dart';

/// Màn hình thêm trang phục — thể hiện pipeline lõi của hệ thống.
/// [initialImage] (nếu có) được truyền sẵn từ bottom sheet → vào thẳng bước xử lý.
class AddItemPage extends StatelessWidget {
  const AddItemPage({super.key, this.initialImage});

  final Uint8List? initialImage;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddItemViewModel>(
      create: (ctx) => AddItemViewModel(
        ctx.read<BackgroundRemovalService>(),
        ctx.read<AttributeExtractionService>(),
        ctx.read<ImageStorageService>(),
      ),
      child: _AddItemView(initialImage: initialImage),
    );
  }
}

class _AddItemView extends StatefulWidget {
  const _AddItemView({this.initialImage});

  final Uint8List? initialImage;

  @override
  State<_AddItemView> createState() => _AddItemViewState();
}

class _AddItemViewState extends State<_AddItemView> {
  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddItemViewModel>().onImagePicked(widget.initialImage!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddItemViewModel>();

    // Hiển thị dialog lỗi validation khi có lỗi.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.validationErrorTitle != null && mounted) {
        _showValidationErrorDialog(context, vm);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm trang phục')),
      body: switch (vm.step) {
        AddStep.pickImage => _PickImageStep(vm: vm),
        AddStep.validating => const _ValidatingStep(),
        AddStep.processing => const _ProcessingStep(),
        AddStep.editing => _EditForm(vm: vm),
      },
    );
  }

  /// Hiển thị dialog lỗi chất lượng ảnh và cho phép người dùng chọn lại.
  Future<void> _showValidationErrorDialog(
      BuildContext context, AddItemViewModel vm) async {
    // Lấy thông tin trước khi xóa để hiển thị trong dialog.
    final title = vm.validationErrorTitle!;
    final message = vm.validationErrorMessage!;
    final hint = vm.validationErrorHint;

    vm.clearValidationError();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ValidationErrorDialog(
        title: title,
        message: message,
        hint: hint,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog lỗi validation
// ---------------------------------------------------------------------------

class _ValidationErrorDialog extends StatelessWidget {
  const _ValidationErrorDialog({
    required this.title,
    required this.message,
    this.hint,
  });

  final String title;
  final String message;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.image_not_supported_outlined,
            color: scheme.onErrorContainer, size: 28),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (hint != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 16, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hint!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.photo_camera_outlined, size: 18),
          label: const Text('Chọn ảnh khác'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bước chọn ảnh
// ---------------------------------------------------------------------------

class _PickImageStep extends StatelessWidget {
  const _PickImageStep({required this.vm});
  final AddItemViewModel vm;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: source, maxWidth: 1280, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await vm.onImagePicked(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 80, color: scheme.primary),
            const SizedBox(height: 16),
            Text('Chụp hoặc chọn ảnh trang phục',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Hệ thống sẽ tách nền và tự nhận diện thuộc tính để bạn xác nhận.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            // Gợi ý chất lượng ảnh
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates_outlined,
                          size: 15, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Để có kết quả tốt nhất:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ..._tips.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 13,
                              color: scheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(t,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: scheme.onSurfaceVariant)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => _pick(context, ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Chụp ảnh'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
              onPressed: () => _pick(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Chọn từ thư viện'),
            ),
          ],
        ),
      ),
    );
  }

  static const _tips = [
    'Ảnh sáng, rõ nét, trang phục chiếm phần lớn khung hình',
    'Nền đơn màu hoặc tương phản với trang phục',
    'Độ phân giải tối thiểu 200×200 px, dung lượng dưới 15 MB',
  ];
}

// ---------------------------------------------------------------------------
// Bước kiểm tra chất lượng ảnh
// ---------------------------------------------------------------------------

class _ValidatingStep extends StatelessWidget {
  const _ValidatingStep();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: scheme.primary,
                ),
              ),
              Icon(Icons.image_search_outlined,
                  size: 32, color: scheme.primary),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Đang kiểm tra chất lượng ảnh...',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Hệ thống đảm bảo ảnh đủ điều kiện\ntrước khi xử lý.',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bước xử lý (tách nền + nhận diện)
// ---------------------------------------------------------------------------

class _ProcessingStep extends StatelessWidget {
  const _ProcessingStep();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tách nền và nhận diện thuộc tính...'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form chỉnh sửa metadata
// ---------------------------------------------------------------------------

class _EditForm extends StatefulWidget {
  const _EditForm({required this.vm});
  final AddItemViewModel vm;

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  late final TextEditingController _name;
  late final TextEditingController _pattern;
  late final TextEditingController _material;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.vm.name);
    _pattern = TextEditingController(text: widget.vm.pattern ?? '');
    _material = TextEditingController(text: widget.vm.material ?? '');
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
    try {
      final vm = widget.vm;
      final wardrobeVM = context.read<WardrobeViewModel>();
      final item = await vm.buildItem();
      await wardrobeVM.add(item);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm "${item.name}" vào tủ đồ')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddItemViewModel>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (vm.processedBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.memory(vm.processedBytes!, height: 240, fit: BoxFit.cover),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          onChanged: vm.setName,
          decoration: const InputDecoration(
            labelText: 'Tên món đồ',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ClothingCategory>(
          initialValue: vm.category,
          decoration: const InputDecoration(
            labelText: 'Kiểu trang phục',
            border: OutlineInputBorder(),
          ),
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
          onChanged: (v) => vm.setCategory(v ?? vm.category),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String?>(
          key: ValueKey('subtype-${vm.category.name}'),
          initialValue: vm.subtype,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Loại trang phục',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String?>(
                value: null, child: Text('Không xác định')),
            ...vm.category.subtypes.map(
                (s) => DropdownMenuItem<String?>(value: s, child: Text(s))),
          ],
          onChanged: vm.setSubtype,
        ),
        const SizedBox(height: 16),
        MultiSelectDropdownField<ClothingColor>(
          title: 'Màu sắc',
          fieldLabel: 'Màu sắc',
          options: ColorPalette.basics,
          selected: vm.colors,
          labelOf: (c) => c.name,
          colorOf: (c) => c.color,
          onChanged: vm.setColors,
        ),
        const SizedBox(height: 16),
        MultiSelectDropdownField<StyleTag>(
          title: 'Phong cách',
          fieldLabel: 'Phong cách',
          options: StyleTag.values,
          selected: vm.styles,
          labelOf: (s) => s.label,
          onChanged: vm.setStyles,
        ),
        const SizedBox(height: 16),
        MultiSelectDropdownField<Season>(
          title: 'Mùa phù hợp',
          fieldLabel: 'Mùa phù hợp',
          options: Season.values,
          selected: vm.seasons,
          labelOf: (s) => s.label,
          onChanged: vm.setSeasons,
        ),
        const SizedBox(height: 16),
        MultiSelectDropdownField<Occasion>(
          title: 'Ngữ cảnh sử dụng',
          fieldLabel: 'Ngữ cảnh sử dụng',
          options: Occasion.values,
          selected: vm.occasions,
          labelOf: (o) => o.label,
          iconOf: (o) => o.icon,
          onChanged: vm.setOccasions,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pattern,
                onChanged: vm.setPattern,
                decoration: const InputDecoration(
                  labelText: 'Hoa văn',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _material,
                onChanged: vm.setMaterial,
                decoration: const InputDecoration(
                  labelText: 'Chất liệu',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: (vm.canSave && !_saving) ? _save : null,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check),
          label: Text(_saving ? 'Đang lưu...' : 'Lưu vào tủ đồ'),
        ),
      ],
    );
  }
}
