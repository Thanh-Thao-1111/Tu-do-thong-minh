import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/main_viewmodel.dart';
import 'diary/diary_page.dart';
import 'home/home_page.dart';
import 'profile/profile_page.dart';
import 'suggestion/suggestion_page.dart';
import 'wardrobe/wardrobe_page.dart';

/// Khung điều hướng chính với thanh BottomNavigation 4 tab.
/// Dùng IndexedStack để giữ nguyên trạng thái mỗi tab khi chuyển qua lại.
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();

    return Scaffold(
      body: IndexedStack(
        index: vm.index,
        children: const [
          HomePage(),
          WardrobePage(),
          SuggestionPage(),
          DiaryPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: vm.index,
        onDestinationSelected: (i) {
          vm.setIndex(i);
          // Trang chủ được giữ sống trong IndexedStack -> tải lại khi quay lại
          // để mục "Trang phục gần đây" / "Sản phẩm mới" luôn cập nhật.
          if (i == 0) context.read<HomeViewModel>().load();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom),
            label: 'Tủ đồ',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Gợi ý',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Nhật ký',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
