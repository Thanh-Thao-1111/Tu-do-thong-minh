import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_palette.dart';
import '../../models/diary_entry.dart';
import '../../models/wardrobe_item.dart';
import '../../viewmodels/diary_viewmodel.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../wardrobe/pages/item_detail_page.dart';
import '../widgets/item_image.dart';
import '../widgets/outfit_collage.dart';

/// Trang Nhật ký thời trang (OOTD) — phong cách app fitness: summary + lịch + lịch sử.
class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiaryViewModel>().load();
    });
  }

  List<DiaryEntry> _entriesForDay(DiaryViewModel vm, DateTime day) =>
      vm.entries.where((e) => isSameDay(e.date, day)).toList();

  int _monthCount(DiaryViewModel vm) => vm.entries
      .where(
        (e) =>
            e.date.month == _focusedDay.month &&
            e.date.year == _focusedDay.year,
      )
      .length;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiaryViewModel>();
    // Chỉ hiển thị bộ đồ khi người dùng đã CHỌN một ngày trên lịch.
    final dayHistory = _selectedDay == null
        ? const <DiaryEntry>[]
        : _entriesForDay(vm, _selectedDay!);

    return Scaffold(
      appBar: AppBar(title: const Text('Nhật ký thời trang')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                _SummaryCard(
                  count: _monthCount(vm),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AllOutfitsPage()),
                  ),
                ),
                const SizedBox(height: 16),
                _Calendar(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  eventsForDay: (d) => _entriesForDay(vm, d),
                  onDaySelected: (sel, foc) => setState(() {
                    _selectedDay = isSameDay(_selectedDay, sel) ? null : sel;
                    _focusedDay = foc;
                  }),
                  onPageChanged: (foc) => setState(() => _focusedDay = foc),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Text(
                      'Bộ đồ đã mặc',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedDay != null)
                      TextButton(
                        onPressed: () => setState(() => _selectedDay = null),
                        child: const Text('Bỏ chọn'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_selectedDay == null)
                  _pickDayHint()
                else if (dayHistory.isEmpty)
                  _dayEmpty(context)
                else
                  ..._dayGroupWidgets(vm, dayHistory),
              ],
            ),
    );
  }

  /// Gợi ý người dùng bấm chọn một ngày (mặc định khi chưa chọn ngày nào).
  Widget _pickDayHint() => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppPalette.rCard),
      boxShadow: AppPalette.softShadow,
    ),
    child: const Column(
      children: [
        Icon(Icons.touch_app_rounded, size: 48, color: AppPalette.inkSoft),
        SizedBox(height: 12),
        Text(
          'Chọn một ngày để xem bộ đồ',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          'Bấm vào một ngày trên lịch để xem các bộ đồ đã mặc hôm đó',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppPalette.inkSoft),
        ),
      ],
    ),
  );

  /// Ngày được chọn nhưng chưa có bộ đồ nào.
  Widget _dayEmpty(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppPalette.rCard),
      boxShadow: AppPalette.softShadow,
    ),
    child: Column(
      children: [
        const Icon(Icons.event_busy_rounded, size: 48, color: AppPalette.inkSoft),
        const SizedBox(height: 12),
        const Text(
          'Ngày này chưa có bộ đồ',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tạo gợi ý và bấm "Đã mặc" để lưu lại bộ đồ',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppPalette.inkSoft),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.read<MainViewModel>().setIndex(2),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Tới Gợi ý'),
        ),
      ],
    ),
  );
}

/// Gom các bộ đồ theo từng ngày: mỗi ngày = 1 khung viền (tiêu đề "Ngày X
/// Tháng Y" + số bộ đồ) rồi tới danh sách bộ đồ của ngày đó (mới nhất lên trên).
List<Widget> _dayGroupWidgets(
  DiaryViewModel vm,
  List<DiaryEntry> history, {
  bool collapsible = false,
}) {
  final groups = <String, List<DiaryEntry>>{};
  for (final e in history) {
    groups.putIfAbsent(e.dayKey, () => []).add(e);
  }
  final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

  return keys.map((k) {
    final dayEntries = groups[k]!;
    return _DayGroup(
      key: ValueKey(k),
      vm: vm,
      date: dayEntries.first.date,
      entries: dayEntries,
      collapsible: collapsible,
    );
  }).toList();
}

/// Trang riêng hiển thị TOÀN BỘ lịch sử phối đồ (gom theo ngày).
class AllOutfitsPage extends StatefulWidget {
  const AllOutfitsPage({super.key});

  @override
  State<AllOutfitsPage> createState() => _AllOutfitsPageState();
}

class _AllOutfitsPageState extends State<AllOutfitsPage> {
  @override
  void initState() {
    super.initState();
    // Mở từ Trang chủ thì nhật ký có thể chưa được nạp -> nạp nếu trống.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DiaryViewModel>();
      if (vm.entries.isEmpty) vm.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiaryViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử phối đồ')),
      body: vm.loading && vm.entries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : vm.entries.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có bộ đồ nào',
                    style: TextStyle(color: AppPalette.inkSoft),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: _dayGroupWidgets(vm, vm.entries, collapsible: true),
                ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.count, this.onTap});
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppPalette.heroGradient,
          borderRadius: BorderRadius.circular(AppPalette.rCard),
          boxShadow: AppPalette.softShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tháng này',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count bộ đồ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Xem tất cả',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.focusedDay,
    required this.selectedDay,
    required this.eventsForDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<DiaryEntry> Function(DateTime) eventsForDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppPalette.rCard),
        boxShadow: AppPalette.softShadow,
      ),
      child: TableCalendar<DiaryEntry>(
        locale: 'vi_VN',
        firstDay: DateTime(2022),
        lastDay: DateTime(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (d) => isSameDay(selectedDay, d),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        eventLoader: eventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: AvailableGestures.horizontalSwipe,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          // Hiển thị tiêu đề lịch dạng "Tháng 6 năm 2026".
          titleTextFormatter: (date, locale) =>
              'Tháng ${date.month} năm ${date.year}',
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: AppPalette.primary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: AppPalette.primary,
          ),
          titleTextStyle: const TextStyle(
            color: AppPalette.primary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppPalette.inkSoft,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: AppPalette.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: const TextStyle(fontWeight: FontWeight.w600),
          weekendTextStyle: const TextStyle(fontWeight: FontWeight.w600),
          selectedDecoration: const BoxDecoration(
            color: AppPalette.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          todayDecoration: BoxDecoration(
            color: AppPalette.primaryTint,
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: AppPalette.primary,
            fontWeight: FontWeight.w700,
          ),
          markerDecoration: const BoxDecoration(
            color: AppPalette.secondary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          markerSize: 6,
          markerMargin: const EdgeInsets.only(top: 6),
        ),
      ),
    );
  }
}

/// Khung bo viền cho 1 ngày: tiêu đề ngày + danh sách bộ đồ của ngày đó.
class _DayGroup extends StatefulWidget {
  const _DayGroup({
    super.key,
    required this.vm,
    required this.date,
    required this.entries,
    this.collapsible = false,
  });
  final DiaryViewModel vm;
  final DateTime date;
  final List<DiaryEntry> entries;

  /// Nếu true: mặc định thu gọn (chỉ hiện tiêu đề ngày), bấm để xổ ra bộ đồ.
  final bool collapsible;

  @override
  State<_DayGroup> createState() => _DayGroupState();
}

class _DayGroupState extends State<_DayGroup> {
  // Không thu gọn -> luôn mở. Có thu gọn -> mặc định đóng.
  late bool _expanded = !widget.collapsible;

  @override
  Widget build(BuildContext context) {
    final header = _DayHeader(
      date: widget.date,
      count: widget.entries.length,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.fromLTRB(14, widget.collapsible ? 6 : 14, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppPalette.rCard),
        border: Border.all(color: AppPalette.border),
        boxShadow: AppPalette.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.collapsible)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: header),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(
                        Icons.expand_more_rounded,
                        color: AppPalette.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            header,
          if (_expanded)
            for (var i = 0; i < widget.entries.length; i++)
              _HistoryCard(
                vm: widget.vm,
                entry: widget.entries[i],
                index: i + 1,
              ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.count});
  final DateTime date;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ngày ${date.day} Tháng ${date.month}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            '$count bộ đồ',
            style: const TextStyle(
              color: AppPalette.inkSoft,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ảnh thu nhỏ ghép TẤT CẢ các món trong một bộ đồ thành lưới (64x64).
class _OutfitThumb extends StatelessWidget {
  const _OutfitThumb({required this.items});
  final List<WardrobeItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: OutfitCollage(items: items),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.vm,
    required this.entry,
    required this.index,
  });
  final DiaryViewModel vm;
  final DiaryEntry entry;
  final int index;

  static const _weekdays = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];

  @override
  Widget build(BuildContext context) {
    final items = entry.itemIds.map(vm.item).whereType<WardrobeItem>().toList();
    final dateStr =
        '${_weekdays[entry.date.weekday - 1]}, ${entry.date.day}/${entry.date.month}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDetail(context, items, dateStr),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _OutfitThumb(items: items),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bộ $index',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitle(items),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppPalette.inkSoft,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppPalette.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Phụ đề thẻ: "Phong cách • Ngữ cảnh" (lấy phong cách của món đầu tiên).
  String _subtitle(List<WardrobeItem> items) {
    // Ưu tiên phong cách đã chọn lúc tạo gợi ý; nếu không có thì lấy phong cách
    // của món đồ đầu tiên trong bộ.
    final style = (entry.style != null && entry.style!.isNotEmpty)
        ? entry.style
        : (items.isNotEmpty && items.first.styles.isNotEmpty
            ? items.first.styles.first.label
            : null);
    final parts = <String>[
      ?style,
      if (entry.occasion != null && entry.occasion!.isNotEmpty) entry.occasion!,
    ];
    return parts.isEmpty ? '${items.length} món' : parts.join(' • ');
  }

  void _showDetail(
    BuildContext context,
    List<WardrobeItem> items,
    String dateStr,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => _OutfitDetailSheet(
        title: 'Bộ $index',
        subtitle: '${entry.occasion ?? 'Bộ đồ'} • $dateStr',
        items: items,
        onItemTap: (item) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: item.id)),
          );
        },
        onDelete: () => vm.delete(entry.id),
      ),
    );
  }
}

/// Bottom sheet chi tiết một bộ đồ trong nhật ký — liệt kê từng món.
class _OutfitDetailSheet extends StatelessWidget {
  const _OutfitDetailSheet({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.onItemTap,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final List<WardrobeItem> items;
  final void Function(WardrobeItem) onItemTap;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppPalette.inkSoft,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Flexible(
                child: items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Các món trong bộ đồ này đã bị xóa khỏi tủ đồ.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppPalette.inkSoft),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return GestureDetector(
                            onTap: () => onItemTap(item),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: AppPalette.subtleShadow,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: ItemImage(
                                        item: item,
                                        iconSize: 28,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  item.category.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppPalette.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await onDelete();
                  if (context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppPalette.error,
                ),
                label: const Text(
                  'Xóa khỏi nhật ký',
                  style: TextStyle(color: AppPalette.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFECACA)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
