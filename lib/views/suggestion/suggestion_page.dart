import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../models/enums.dart';
import '../../viewmodels/suggestion_viewmodel.dart';
import '../widgets/weather_card.dart';
import 'pages/suggestion_result_page.dart';

/// Trang Gợi ý phối đồ — màn hình quan trọng nhất.
class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuggestionViewModel>().loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SuggestionViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gợi ý trang phục')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          WeatherCard(weather: vm.weather),
          const SizedBox(height: 24),
          const _SectionTitle('Bạn sẽ làm gì hôm nay?'),
          const SizedBox(height: 14),
          _OccasionGrid(vm: vm),
          const SizedBox(height: 26),
          const _SectionTitle('Phong cách mong muốn'),
          const SizedBox(height: 14),
          _StyleGrid(vm: vm),
          const SizedBox(height: 26),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: () => _onGenerate(context),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text(
                'Gợi ý phối đồ',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onGenerate(BuildContext context) {
    // Sinh gợi ý rồi chuyển sang trang kết quả riêng.
    context.read<SuggestionViewModel>().generate();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SuggestionResultPage()),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800));
}

class _OccasionGrid extends StatelessWidget {
  const _OccasionGrid({required this.vm});
  final SuggestionViewModel vm;

  @override
  Widget build(BuildContext context) {
    final occasions = Occasion.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 58,
      ),
      itemCount: occasions.length,
      itemBuilder: (context, i) {
        final o = occasions[i];
        final selected = vm.occasion == o;
        return GestureDetector(
          onTap: () => vm.setOccasion(o),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: selected ? AppPalette.primarySurface : Colors.white,
              borderRadius: BorderRadius.circular(AppPalette.rInput),
              boxShadow: selected ? null : AppPalette.subtleShadow,
              border: Border.all(
                color: selected ? AppPalette.primary : AppPalette.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Text(
              o.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: selected ? AppPalette.primary : AppPalette.ink,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StyleGrid extends StatelessWidget {
  const _StyleGrid({required this.vm});
  final SuggestionViewModel vm;

  @override
  Widget build(BuildContext context) {
    final styles = StyleTag.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 78,
      ),
      itemCount: styles.length,
      itemBuilder: (context, i) {
        final s = styles[i];
        final selected = vm.style == s;
        return GestureDetector(
          onTap: () => vm.setStyle(s),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? AppPalette.primarySurface : Colors.white,
              borderRadius: BorderRadius.circular(AppPalette.rInput),
              boxShadow: selected ? null : AppPalette.subtleShadow,
              border: Border.all(
                color: selected ? AppPalette.primary : AppPalette.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: selected ? AppPalette.primary : AppPalette.ink)),
                const SizedBox(height: 2),
                Text(s.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppPalette.inkSoft)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// (Kết quả gợi ý đã được tách sang SuggestionResultPage.)
