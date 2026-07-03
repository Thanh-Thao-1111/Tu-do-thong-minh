import 'package:flutter/foundation.dart';

/// Quản lý trạng thái điều hướng chính — tab đang được chọn trên BottomNavigationBar.
/// Được chia sẻ qua Provider để các widget con có thể chuyển tab bằng lập trình
/// (vd: nút "Tới Gợi ý" trên trang Nhật ký gọi setIndex(2)).
class MainViewModel extends ChangeNotifier {
  int _index = 0;

  /// Chỉ số tab đang active (0=Trang chủ, 1=Tủ đồ, 2=Gợi ý, 3=Nhật ký, 4=Hồ sơ).
  int get index => _index;

  /// Chuyển sang tab [value]. Không làm gì nếu đã đang ở tab đó.
  void setIndex(int value) {
    if (value == _index) return; // tránh rebuild thừa
    _index = value;
    notifyListeners();
  }
}
