import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../models/enums.dart';
import '../../../models/user_profile.dart';
import '../../../services/image_storage_service.dart';
import '../../../services/local_image_store.dart';
import '../../../viewmodels/profile_viewmodel.dart';
import '../profile_page.dart' show ProfileAvatar;

/// Trang chỉnh sửa hồ sơ cá nhân.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _city;
  Gender? _gender;
  DateTime? _birthday;
  late final List<StyleTag> _styles;
  Uint8List? _avatarBytes;
  String? _avatarId;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileViewModel>().profile ?? UserProfile.initial();
    _name = TextEditingController(text: p.displayName);
    _bio = TextEditingController(text: p.bio ?? '');
    _city = TextEditingController(text: p.city ?? '');
    _gender = p.gender;
    _birthday = p.birthday;
    _styles = [...p.preferredStyles];
    _avatarId = p.avatarId;
    if (p.avatarId != null && !p.avatarId!.startsWith('http')) {
      _avatarBytes = context.read<LocalImageStore>().get(p.avatarId!);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 600, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _avatarBytes = bytes);
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<void> _save() async {
    final vm = context.read<ProfileViewModel>();
    final storage = context.read<ImageStorageService>();
    var avatarId = _avatarId;
    if (_avatarBytes != null) {
      avatarId = await storage.uploadAvatar(_avatarBytes!);
    }
    final base = vm.profile ?? UserProfile.initial();
    final updated = UserProfile(
      id: base.id,
      displayName:
          _name.text.trim().isEmpty ? 'Người dùng' : _name.text.trim(),
      avatarId: avatarId,
      gender: _gender,
      city: _city.text.trim().isEmpty ? null : _city.text.trim(),
      birthday: _birthday,
      preferredStyles: List.of(_styles),
      bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
    );
    await vm.save(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu hồ sơ')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(child: _avatarPicker()),
          const SizedBox(height: 24),
          _label('Tên hiển thị'),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'Nhập tên của bạn'),
          ),
          const SizedBox(height: 18),
          _label('Giới thiệu'),
          TextField(
            controller: _bio,
            maxLines: 2,
            decoration:
                const InputDecoration(hintText: 'Vài dòng về phong cách của bạn'),
          ),
          const SizedBox(height: 18),
          _label('Giới tính'),
          Wrap(
            spacing: 8,
            children: Gender.values
                .map((g) => ChoiceChip(
                      label: Text(g.label),
                      selected: _gender == g,
                      onSelected: (_) => setState(
                          () => _gender = _gender == g ? null : g),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          _label('Thành phố'),
          TextField(
            controller: _city,
            decoration: const InputDecoration(
                hintText: 'VD: TP. Hồ Chí Minh',
                prefixIcon: Icon(Icons.location_on_outlined)),
          ),
          const SizedBox(height: 18),
          _label('Ngày sinh'),
          InkWell(
            onTap: _pickBirthday,
            borderRadius: BorderRadius.circular(18),
            child: InputDecorator(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.cake_outlined)),
              child: Text(
                _birthday != null
                    ? '${_birthday!.day.toString().padLeft(2, '0')}/${_birthday!.month.toString().padLeft(2, '0')}/${_birthday!.year}'
                    : 'Chọn ngày sinh',
                style: TextStyle(
                  color: _birthday != null
                      ? AppPalette.ink
                      : AppPalette.inkSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _label('Phong cách yêu thích'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: StyleTag.values
                .map((s) => FilterChip(
                      label: Text(s.label),
                      selected: _styles.contains(s),
                      onSelected: (_) => setState(() {
                        _styles.contains(s)
                            ? _styles.remove(s)
                            : _styles.add(s);
                      }),
                    ))
                .toList(),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Lưu hồ sơ'),
          ),
        ],
      ),
    );
  }

  Widget _avatarPicker() {
    // Tạo profile tạm để dùng lại ProfileAvatar (đồng nhất với trang Cá nhân).
    // Dùng constructor trực tiếp thay vì copyWith vì copyWith không set được null.
    final base = context.read<ProfileViewModel>().profile ?? UserProfile.initial();
    final tempProfile = UserProfile(
      id: base.id,
      displayName: _name.text.trim().isEmpty ? base.displayName : _name.text.trim(),
      avatarId: _avatarId, // null nếu người dùng chưa có avatar
    );

    // Nếu người dùng vừa chọn ảnh mới trong phiên này → hiển thị preview bytes.
    final ImageProvider? previewImage =
        _avatarBytes != null ? MemoryImage(_avatarBytes!) : null;

    return Stack(
      children: [
        previewImage != null
            ? CircleAvatar(
                radius: 52,
                backgroundImage: previewImage,
              )
            : ProfileAvatar(profile: tempProfile, radius: 52),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _pickAvatar,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppPalette.lavender,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
      );
}
