import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/config/cloudinary_config.dart';
import 'core/config/gemini_config.dart';
import 'core/config/groq_config.dart';
import 'core/config/openweather_config.dart';
import 'core/config/removebg_config.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'repositories/diary_repository.dart';
import 'repositories/firebase/firebase_auth_repository.dart';
import 'repositories/firebase/firestore_diary_repository.dart';
import 'repositories/firebase/firestore_outfit_repository.dart';
import 'repositories/firebase/firestore_profile_repository.dart';
import 'repositories/firebase/firestore_wardrobe_repository.dart';
import 'repositories/outfit_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/wardrobe_repository.dart';
import 'services/attribute_extraction_service.dart';
import 'services/background_removal_service.dart';
import 'services/cloudinary_image_storage_service.dart';
import 'services/gemini_attribute_extraction_service.dart';
import 'services/groq_attribute_extraction_service.dart';
import 'services/image_storage_service.dart';
import 'services/fallback_background_removal_service.dart';
import 'services/mlkit_background_removal_service.dart';
import 'services/removebg_background_removal_service.dart';
import 'services/local_image_store.dart';
import 'services/open_weather_service.dart';
import 'services/outfit_recommendation_service.dart';
import 'services/weather_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/diary_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/main_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/suggestion_viewmodel.dart';
import 'viewmodels/wardrobe_viewmodel.dart';
import 'views/auth/auth_page.dart';
import 'views/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nạp dữ liệu định dạng ngày/tháng tiếng Việt cho lịch.
  await initializeDateFormatting('vi_VN', null);
  var firebaseReady = false;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase chưa sẵn sàng, dùng dữ liệu cục bộ: $e');
  }

  runApp(SmartWardrobeApp(firebaseReady: firebaseReady));
}

/// Ứng dụng Quản lý tủ đồ thông minh & gợi ý phối đồ (MVVM + provider).
class SmartWardrobeApp extends StatelessWidget {
  const SmartWardrobeApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalImageStore>(create: (_) => LocalImageStore()),

        // ----- Repositories: Firebase nếu sẵn sàng, ngược lại cục bộ -----
        Provider<WardrobeRepository>(
          create: (_) => firebaseReady
              ? FirestoreWardrobeRepository(
                  FirebaseFirestore.instance, FirebaseAuth.instance)
              : InMemoryWardrobeRepository(),
        ),
        Provider<DiaryRepository>(
          create: (_) => firebaseReady
              ? FirestoreDiaryRepository(
                  FirebaseFirestore.instance, FirebaseAuth.instance)
              : InMemoryDiaryRepository(),
        ),
        Provider<ProfileRepository>(
          create: (_) => firebaseReady
              ? FirestoreProfileRepository(
                  FirebaseFirestore.instance, FirebaseAuth.instance)
              : InMemoryProfileRepository(),
        ),
        Provider<AuthRepository>(
          create: (_) => firebaseReady
              ? FirebaseAuthRepository(FirebaseAuth.instance)
              : MockAuthRepository(),
        ),
        Provider<OutfitRepository>(
          create: (_) => firebaseReady
              ? FirestoreOutfitRepository(
                  FirebaseFirestore.instance, FirebaseAuth.instance)
              : InMemoryOutfitRepository(),
        ),

        // ----- Services -----
        Provider<BackgroundRemovalService>(
          create: (_) => RemoveBgConfig.isConfigured
              ? FallbackBackgroundRemovalService(
                  // Ưu tiên remove.bg (API cloud chất lượng cao nhất)
                  primary: RemoveBgBackgroundRemovalService(),
                  // Dự phòng sang Google ML Kit (chạy offline, miễn phí) nếu API lỗi/hết lượt
                  secondary: MlKitBackgroundRemovalService(),
                )
              : MlKitBackgroundRemovalService(),
        ),
        Provider<AttributeExtractionService>(
          create: (_) {
            if (GroqConfig.isConfigured) {
              return GroqAttributeExtractionService();
            }
            if (GeminiConfig.isConfigured) {
              return GeminiAttributeExtractionService();
            }
            return MockAttributeExtractionService();
          },
        ),
        Provider<WeatherService>(
          create: (_) {
            final WeatherService s = OpenWeatherConfig.isConfigured
                ? OpenWeatherService()
                : MockWeatherService();
            s.prefetch(); // tải sớm chạy ngầm để dữ liệu sẵn khi cần
            return s;
          },
        ),

        Provider<OutfitRecommendationService>(
            create: (_) => OutfitRecommendationService()),
        Provider<ImageStorageService>(
          create: (ctx) {
            final fallback = ctx.read<LocalImageStore>();
            // Cloudinary: CDN + tự tối ưu ảnh (WebP/AVIF), không cần Blaze.
            if (CloudinaryConfig.isConfigured) {
              return CloudinaryImageStorageService(fallback);
            }
            if (firebaseReady) {
              return FirebaseImageStorageService(
                  FirebaseStorage.instance, FirebaseAuth.instance, fallback);
            }
            return LocalImageStorageService(fallback);
          },
        ),

        // ----- Auth (toàn cục) -----
        ChangeNotifierProvider(
            create: (ctx) => AuthViewModel(ctx.read<AuthRepository>())),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, auth, _) {
          final Widget home;
          if (auth.initializing) {
            home = const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          } else if (auth.user == null) {
            home = const AuthPage();
          } else {
            home = const MainPage();
          }
          final app = MaterialApp(
            title: 'TỦ ĐỒ THÔNG MINH',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            // Tiếng Việt cho lịch, định dạng ngày tháng & nhãn hệ thống.
            locale: const Locale('vi'),
            supportedLocales: const [Locale('vi'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: home,
          );
          if (auth.user == null) return app;
          // Đã đăng nhập: bọc các ViewModel dữ liệu BÊN TRÊN MaterialApp để
          // mọi route (kể cả push) truy cập được; key theo uid -> đổi tài khoản
          // sẽ tạo lại & nạp đúng dữ liệu.
          return _DataProviders(key: ValueKey(auth.user!.uid), child: app);
        },
      ),
    );
  }
}

/// Bọc các ViewModel dữ liệu theo người dùng hiện tại (đặt trên MaterialApp).
class _DataProviders extends StatelessWidget {
  const _DataProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        ChangeNotifierProvider(
          create: (ctx) =>
              WardrobeViewModel(ctx.read<WardrobeRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => HomeViewModel(
            ctx.read<WeatherService>(),
            ctx.read<WardrobeRepository>(),
            ctx.read<OutfitRecommendationService>(),
            ctx.read<DiaryRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SuggestionViewModel(
            ctx.read<WardrobeRepository>(),
            ctx.read<OutfitRecommendationService>(),
            ctx.read<WeatherService>(),
            ctx.read<OutfitRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DiaryViewModel(
            ctx.read<DiaryRepository>(),
            ctx.read<WardrobeRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ProfileViewModel(
            ctx.read<ProfileRepository>(),
            ctx.read<WardrobeRepository>(),
            ctx.read<DiaryRepository>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
