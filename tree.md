# Cấu trúc thư mục dự án (Directory Tree)

Dưới đây là sơ đồ chi tiết cấu trúc thư mục của dự án **Smart Wardrobe (Tủ Đồ Thông Minh)**:

```text
smart_wardrobe/
├── android/                             # Cấu hình dự án cho hệ điều hành Android
├── assets/                              # Tài nguyên tĩnh của ứng dụng
│   ├── categories/                      # Các hình ảnh biểu diễn loại trang phục
│   └── fonts/                           # Bộ phông chữ custom (ví dụ: Phosphor.ttf)
├── build/                               # Thư mục build của Flutter (tự sinh)
├── lib/                                 # Mã nguồn Dart chính của ứng dụng
│   ├── main.dart                        # File chạy chính, khởi động App & tiêm phụ thuộc (DI)
│   ├── firebase_options.dart            # Cấu hình kết nối Firebase tự động sinh
│   ├── core/                            # Chứa các cấu hình cốt lõi và giao diện chung
│   │   ├── config/                      # Cấu hình các API Key (Cloudinary, Gemini, Groq, v.v.)
│   │   │   ├── cloudinary_config.dart
│   │   │   ├── gemini_config.dart
│   │   │   ├── groq_config.dart
│   │   │   ├── openweather_config.dart
│   │   │   └── removebg_config.dart
│   │   ├── icons/                       # Chứa định nghĩa các Icon Phosphor custom
│   │   │   └── ph_icons.dart
│   │   └── theme/                       # Hệ thống màu sắc (palette) và ThemeData
│   │       ├── app_palette.dart
│   │       └── app_theme.dart
│   ├── models/                          # Định nghĩa cấu trúc dữ liệu (Models)
│   │   ├── clothing_color.dart          # Màu sắc quần áo
│   │   ├── diary_entry.dart             # Bản ghi nhật ký thời trang
│   │   ├── enums.dart                   # Các enum dùng chung (Category, StyleTag, Occasion, v.v.)
│   │   ├── outfit.dart                  # Bộ phối đồ (Outfit)
│   │   ├── user_profile.dart            # Thông tin người dùng
│   │   ├── wardrobe_item.dart           # Trang phục trong tủ đồ
│   │   └── weather_info.dart            # Thông tin thời tiết
│   ├── repositories/                    # Tầng giao tiếp dữ liệu (Repositories)
│   │   ├── auth_repository.dart         # Xác thực (Auth)
│   │   ├── diary_repository.dart        # Nhật ký
│   │   ├── profile_repository.dart      # Hồ sơ cá nhân
│   │   ├── sample_data.dart             # Dữ liệu mẫu ban đầu
│   │   ├── wardrobe_repository.dart     # Tủ đồ
│   │   └── firebase/                    # Cài đặt cụ thể kết nối Firebase/Firestore
│   │       ├── firebase_auth_repository.dart
│   │       ├── firestore_diary_repository.dart
│   │       ├── firestore_profile_repository.dart
│   │       └── firestore_wardrobe_repository.dart
│   ├── services/                        # Các nghiệp vụ Logic & tích hợp dịch vụ (Services)
│   │   ├── attribute_extraction_service.dart     # Trích xuất thuộc tính bằng AI
│   │   ├── background_removal_service.dart      # Tách nền ảnh (remove.bg)
│   │   ├── cloudinary_image_storage_service.dart # Lưu trữ ảnh Cloudinary
│   │   ├── gemini_attribute_extraction_service.dart # Tích hợp Gemini AI
│   │   ├── groq_attribute_extraction_service.dart   # Tích hợp Groq (Llama Vision)
│   │   ├── image_storage_service.dart            # Lưu trữ ảnh chung
│   │   ├── local_image_store.dart                # Lưu trữ ảnh cục bộ
│   │   ├── open_weather_service.dart             # Dịch vụ lấy thời tiết (OpenWeather)
│   │   ├── outfit_recommendation_service.dart    # Thuật toán gợi ý phối đồ
│   │   ├── removebg_background_removal_service.dart
│   │   └── weather_service.dart
│   ├── viewmodels/                      # Tầng quản lý trạng thái giao diện (ViewModels)
│   │   ├── add_item_viewmodel.dart
│   │   ├── auth_viewmodel.dart
│   │   ├── diary_viewmodel.dart
│   │   ├── home_viewmodel.dart
│   │   ├── main_viewmodel.dart
│   │   ├── profile_viewmodel.dart
│   │   ├── suggestion_viewmodel.dart
│   │   └── wardrobe_viewmodel.dart
│   └── views/                           # Tầng hiển thị giao diện người dùng (Views / Pages)
│       ├── main_page.dart               # Khung trang chính chứa BottomNavigationBar
│       ├── auth/                        # Trang Đăng nhập / Đăng ký
│       │   └── auth_page.dart
│       ├── diary/                       # Tab Nhật ký thời trang
│       │   └── diary_page.dart
│       ├── home/                        # Tab Trang chủ (Thời tiết + Gợi ý nhanh)
│       │   └── home_page.dart
│       ├── profile/                     # Tab Cá nhân & chỉnh sửa thông tin
│       │   ├── profile_page.dart
│       │   └── pages/
│       │       └── edit_profile_page.dart
│       ├── suggestion/                  # Tab Gợi ý phối đồ nâng cao
│       │   ├── suggestion_page.dart
│       │   ├── pages/
│       │   │   └── suggestion_result_page.dart
│       │   └── widgets/
│       │       └── outfit_card.dart
│       ├── wardrobe/                    # Tab Quản lý tủ đồ
│       │   ├── wardrobe_page.dart
│       │   ├── pages/
│       │   │   ├── add_item_page.dart
│       │   │   ├── category_items_page.dart
│       │   │   └── item_detail_page.dart
│       │   └── widgets/
│       │       ├── add_source_sheet.dart
│       │       ├── attribute_dropdown.dart
│       │       ├── category_filter_sheet.dart
│       │       ├── wardrobe_filter_sheet.dart
│       │       └── wardrobe_item_tile.dart
│       └── widgets/                     # Các widget dùng chung trong Views
│           ├── item_image.dart
│           ├── outfit_collage.dart
│           └── weather_card.dart
├── test/                                # Các file kiểm thử tự động (Unit / Widget Test)
│   ├── models_test.dart
│   ├── recommendation_test.dart
│   ├── wardrobe_filter_test.dart
│   └── widget_test.dart
├── firestore.rules                      # Luật bảo mật Firestore
├── firestore.indexes.json               # Các chỉ mục của Firestore
├── storage.rules                        # Luật bảo mật Firebase Storage
├── pubspec.yaml                         # Quản lý thư viện & cấu hình tài nguyên dự án
└── README.md                            # Hướng dẫn chạy & thông tin dự án
```
