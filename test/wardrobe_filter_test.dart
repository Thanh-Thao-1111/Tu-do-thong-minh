
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_wardrobe/models/enums.dart';
import 'package:smart_wardrobe/repositories/wardrobe_repository.dart';
import 'package:smart_wardrobe/viewmodels/wardrobe_viewmodel.dart';

void main() {
  Future<WardrobeViewModel> buildVm() async {
    final vm = WardrobeViewModel(InMemoryWardrobeRepository());
    await vm.load();
    return vm;
  }

  group('WardrobeViewModel lọc & tìm kiếm', () {
    test('lọc theo loại', () async {
      final vm = await buildVm();
      vm.setCategoryFilter(ClothingCategory.top);
      expect(vm.items.every((i) => i.category == ClothingCategory.top), isTrue);
    });

    test('lọc theo phong cách (và bấm lại để bỏ lọc)', () async {
      final vm = await buildVm();
      final total = vm.totalCount;
      vm.setStyleFilter(StyleTag.formal);
      expect(vm.items, isNotEmpty);
      expect(vm.items.every((i) => i.styles.contains(StyleTag.formal)), isTrue);
      expect(vm.items.length, lessThan(total));
      vm.setStyleFilter(StyleTag.formal); // toggle off
      expect(vm.items.length, total);
    });

    test('lọc theo màu', () async {
      final vm = await buildVm();
      vm.setColorFilter('Trắng');
      expect(vm.items, isNotEmpty);
      expect(vm.items.every((i) => i.colors.any((c) => c.name == 'Trắng')),
          isTrue);
    });

    test('tìm kiếm theo tên', () async {
      final vm = await buildVm();
      vm.setQuery('jean');
      expect(vm.items, isNotEmpty);
      expect(
          vm.items.every((i) => i.name.toLowerCase().contains('jean')), isTrue);
    });

    test('kết hợp nhiều bộ lọc + đếm bộ lọc đang bật', () async {
      final vm = await buildVm();
      vm.setStyleFilter(StyleTag.casual);
      vm.setColorFilter('Trắng');
      expect(vm.activeFilterCount, 2);
      expect(
          vm.items.every((i) =>
              i.styles.contains(StyleTag.casual) &&
              i.colors.any((c) => c.name == 'Trắng')),
          isTrue);
      vm.clearFilters();
      expect(vm.activeFilterCount, 0);
    });
  });
}
