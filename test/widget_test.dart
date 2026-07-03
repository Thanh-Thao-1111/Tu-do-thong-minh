import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:smart_wardrobe/core/theme/app_theme.dart';
import 'package:smart_wardrobe/repositories/diary_repository.dart';
import 'package:smart_wardrobe/repositories/profile_repository.dart';
import 'package:smart_wardrobe/repositories/wardrobe_repository.dart';
import 'package:smart_wardrobe/repositories/outfit_repository.dart';
import 'package:smart_wardrobe/repositories/auth_repository.dart';
import 'package:smart_wardrobe/viewmodels/auth_viewmodel.dart';
import 'package:smart_wardrobe/services/local_image_store.dart';
import 'package:smart_wardrobe/services/outfit_recommendation_service.dart';
import 'package:smart_wardrobe/services/weather_service.dart';
import 'package:smart_wardrobe/viewmodels/diary_viewmodel.dart';
import 'package:smart_wardrobe/viewmodels/home_viewmodel.dart';
import 'package:smart_wardrobe/viewmodels/main_viewmodel.dart';
import 'package:smart_wardrobe/viewmodels/profile_viewmodel.dart';
import 'package:smart_wardrobe/viewmodels/suggestion_viewmodel.dart';
import 'package:smart_wardrobe/viewmodels/wardrobe_viewmodel.dart';
import 'package:smart_wardrobe/views/main_page.dart';

void main() {
  setUpAll(() => initializeDateFormatting('vi_VN', null));

  testWidgets('MainPage hiển thị các tab điều hướng (dùng service mock)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LocalImageStore>(create: (_) => LocalImageStore()),
          Provider<WardrobeRepository>(
              create: (_) => InMemoryWardrobeRepository()),
          Provider<DiaryRepository>(create: (_) => InMemoryDiaryRepository()),
          Provider<ProfileRepository>(
              create: (_) => InMemoryProfileRepository()),
          Provider<OutfitRepository>(
              create: (_) => InMemoryOutfitRepository()),
          Provider<AuthRepository>(
              create: (_) => MockAuthRepository()),
          Provider<WeatherService>(create: (_) => MockWeatherService()),
          Provider<OutfitRecommendationService>(
              create: (_) => OutfitRecommendationService()),
          ChangeNotifierProvider(
              create: (ctx) => AuthViewModel(ctx.read<AuthRepository>())),
          ChangeNotifierProvider(create: (_) => MainViewModel()),
          ChangeNotifierProvider(
              create: (ctx) =>
                  WardrobeViewModel(ctx.read<WardrobeRepository>())..load()),
          ChangeNotifierProvider(
              create: (ctx) => HomeViewModel(
                    ctx.read<WeatherService>(),
                    ctx.read<WardrobeRepository>(),
                    ctx.read<OutfitRecommendationService>(),
                    ctx.read<DiaryRepository>(),
                  )),
          ChangeNotifierProvider(
              create: (ctx) => SuggestionViewModel(
                    ctx.read<WardrobeRepository>(),
                    ctx.read<OutfitRecommendationService>(),
                    ctx.read<WeatherService>(),
                    ctx.read<OutfitRepository>(),
                  )),
          ChangeNotifierProvider(
              create: (ctx) => DiaryViewModel(
                    ctx.read<DiaryRepository>(),
                    ctx.read<WardrobeRepository>(),
                  )),
          ChangeNotifierProvider(
              create: (ctx) => ProfileViewModel(
                    ctx.read<ProfileRepository>(),
                    ctx.read<WardrobeRepository>(),
                    ctx.read<DiaryRepository>(),
                  )),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('vi'),
          supportedLocales: const [Locale('vi'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MainPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MainPage), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Cá nhân'), findsWidgets);
  });
}
