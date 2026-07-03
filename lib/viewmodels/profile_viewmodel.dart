import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../repositories/diary_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/wardrobe_repository.dart';

/// Quản lý trạng thái trang Hồ sơ cá nhân:
/// tải/lưu hồ sơ người dùng và thống kê sử dụng tủ đồ.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._repo, this._wardrobeRepo, this._diaryRepo);

  final ProfileRepository _repo;
  final WardrobeRepository _wardrobeRepo;
  final DiaryRepository _diaryRepo;

  bool _loading = false;

  /// True khi đang tải dữ liệu từ kho.
  bool get loading => _loading;

  UserProfile? _profile;

  /// Hồ sơ người dùng hiện tại. Null cho đến khi load() hoàn thành.
  UserProfile? get profile => _profile;

  int _itemCount = 0;

  /// Tổng số món đồ trong tủ — hiển thị trên thẻ thống kê.
  int get itemCount => _itemCount;

  int _diaryCount = 0;

  /// Tổng số lần ghi nhật ký (bộ đồ đã mặc) — hiển thị trên thẻ thống kê.
  int get diaryCount => _diaryCount;

  int _totalWears = 0;

  /// Tổng số lần mặc (tổng wearCount của mọi món đồ) — hiển thị trên thẻ thống kê.
  int get totalWears => _totalWears;

  /// Tải hồ sơ người dùng + thống kê từ kho.
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _profile = await _repo.fetch();
    final items = await _wardrobeRepo.fetchAll();
    final entries = await _diaryRepo.fetchAll();
    _itemCount = items.length;
    _diaryCount = entries.length;
    _totalWears = items.fold(0, (sum, item) => sum + item.wearCount); // tổng wearCount
    _loading = false;
    notifyListeners();
  }

  /// Lưu [profile] đã chỉnh sửa và cập nhật state cục bộ ngay.
  Future<void> save(UserProfile profile) async {
    await _repo.save(profile);
    _profile = profile;
    notifyListeners();
  }
}
