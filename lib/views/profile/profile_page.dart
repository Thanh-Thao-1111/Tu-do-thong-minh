import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../models/user_profile.dart';
import '../../services/local_image_store.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import 'pages/edit_profile_page.dart';

/// Trang Cá nhân: hồ sơ người dùng + thống kê sử dụng tủ đồ.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().load();
    });
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _openEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppPalette.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthViewModel>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final profile = vm.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
      ),
      body: vm.loading || profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<ProfileViewModel>().load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  _Header(profile: profile),
                  const SizedBox(height: 18),
                  _StatsRow(
                    itemCount: vm.itemCount,
                    diaryCount: vm.diaryCount,
                    totalWears: vm.totalWears,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('Thông tin'),
                  const SizedBox(height: 10),
                  _InfoCard(profile: profile, formatDate: _formatDate),
                  const SizedBox(height: 24),
                  _SectionTitle('Phong cách yêu thích'),
                  const SizedBox(height: 10),
                  _StyleSection(profile: profile),
                  const SizedBox(height: 26),
                  FilledButton.icon(
                    onPressed: _openEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Chỉnh sửa hồ sơ'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context),
                    icon: const Icon(Icons.logout_rounded,
                        color: AppPalette.error),
                    label: const Text('Đăng xuất',
                        style: TextStyle(color: AppPalette.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFECACA)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.profile, this.radius = 40});
  final UserProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final id = profile.avatarId;
    if (id != null && id.startsWith('http')) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(id));
    }
    final bytes = id == null ? null : context.read<LocalImageStore>().get(id);
    if (bytes != null) {
      return CircleAvatar(radius: radius, backgroundImage: MemoryImage(bytes));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF10B981), // primary green
      child: Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: radius * 1.1,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});
  final UserProfile profile;

  String _generateRandomCode(String userId) {
    final cleanId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (cleanId.length >= 6) {
      return 'User_${cleanId.substring(cleanId.length - 6).toUpperCase()}';
    }
    return 'User_${userId.hashCode.abs().toString().padLeft(6, '0').substring(0, 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final emailText = auth.user?.email ?? 'minh@gmail.com';
    
    final hasName = profile.displayName.isNotEmpty && profile.displayName != 'Người dùng';
    final nameText = hasName ? profile.displayName : _generateRandomCode(profile.id);

    return Column(
      children: [
        const SizedBox(height: 12),
        ProfileAvatar(profile: profile, radius: 56),
        const SizedBox(height: 16),
        Text(
          nameText,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937), // slate-800
          ),
        ),
        const SizedBox(height: 6),
        Text(
          emailText,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280), // grey-500
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.itemCount,
    required this.diaryCount,
    required this.totalWears,
  });
  final int itemCount;
  final int diaryCount;
  final int totalWears;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCell(value: '$itemCount', label: 'Món đồ'),
        const SizedBox(width: 12),
        _StatCell(value: '$diaryCount', label: 'Nhật ký'),
        const SizedBox(width: 12),
        _StatCell(value: '$totalWears', label: 'Lượt mặc'),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
  });
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppPalette.softShadow,
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.inkSoft)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800));
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.profile, required this.formatDate});
  final UserProfile profile;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppPalette.softShadow,
      ),
      child: Column(
        children: [
          _row(Icons.wc_rounded, 'Giới tính',
              profile.gender?.label ?? 'Chưa thiết lập'),
          _divider(),
          _row(Icons.location_on_outlined, 'Thành phố',
              profile.city?.isNotEmpty == true ? profile.city! : 'Chưa thiết lập'),
          _divider(),
          _row(Icons.cake_outlined, 'Ngày sinh',
              profile.birthday != null
                  ? formatDate(profile.birthday!)
                  : 'Chưa thiết lập'),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 56, endIndent: 16);

  Widget _row(IconData icon, String label, String value) => ListTile(
        leading: Icon(icon, color: AppPalette.lavender),
        title: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppPalette.inkSoft)),
        trailing: Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      );
}

class _StyleSection extends StatelessWidget {
  const _StyleSection({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    if (profile.preferredStyles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppPalette.softShadow,
        ),
        child: const Text('Chưa chọn phong cách yêu thích',
            style: TextStyle(color: AppPalette.inkSoft, fontWeight: FontWeight.w600)),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: profile.preferredStyles
          .map((s) => Chip(
                label: Text(s.label),
                backgroundColor: AppPalette.lavenderTint,
              ))
          .toList(),
    );
  }
}
