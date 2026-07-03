# Ứng Dụng Quản Lý Tủ Đồ Thông Minh

Ứng dụng di động Flutter giúp người dùng quản lý tủ đồ cá nhân và nhận gợi ý phối đồ thông minh dựa trên thời tiết, phong cách và ngữ cảnh sử dụng.

## Tính năng chính

- **Quản lý tủ đồ**: Thêm trang phục bằng cách chụp ảnh hoặc chọn từ thư viện; hệ thống tự động tách nền và nhận diện thuộc tính (màu sắc, phong cách, chất liệu...) bằng AI.
- **Gợi ý phối đồ**: Sinh gợi ý outfit phù hợp theo thời tiết thực tế, ngữ cảnh (đi làm, dạo phố, hẹn hò...) và phong cách cá nhân; xếp hạng theo điểm tổng hợp.
- **Nhật ký thời trang**: Lưu lại các bộ đồ đã mặc, xem lịch sử theo ngày/tháng.
- **Hồ sơ cá nhân**: Thiết lập thành phố, phong cách yêu thích; xem thống kê tủ đồ.

## Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter (Dart) |
| Kiến trúc | MVVM + Provider |
| Backend | Firebase (Authentication, Firestore, Storage) |
| Lưu ảnh | Cloudinary (CDN) |
| Tách nền | Google ML Kit Subject Segmentation (on-device) |
| Nhận diện thuộc tính | Groq API (Llama 4) / Gemini API |
| Thời tiết | OpenWeatherMap API |

## Cài đặt & Chạy thử

1. Cài Flutter SDK (>= 3.x)
2. Chạy `flutter pub get` để tải dependencies
3. Kết nối thiết bị Android hoặc mở máy ảo
4. Chạy `flutter run`

> **Lưu ý**: Ứng dụng hỗ trợ Android. Tính năng tách nền bằng ML Kit chỉ hoạt động trên Android thực (không hỗ trợ máy ảo).

## Cấu trúc thư mục

```
lib/
├── core/           # Cấu hình API, theme, icon
├── models/         # Data models (WardrobeItem, Outfit, DiaryEntry...)
├── repositories/   # Truy xuất dữ liệu (Firebase / local)
├── services/       # Logic nghiệp vụ (AI, thời tiết, ảnh...)
├── viewmodels/     # Quản lý trạng thái (MVVM)
└── views/          # Giao diện người dùng
```
