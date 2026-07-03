import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../models/weather_info.dart';

/// Thẻ thời tiết dùng chung cho Trang chủ và trang Gợi ý (hiển thị giống hệt
/// nhau) — phong cách iOS: tên thành phố, nhiệt độ lớn, mô tả, Cao/Thấp.
class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key, required this.weather});

  final WeatherInfo? weather;

  // Nền gradient sặc sỡ, mỗi điều kiện thời tiết một sắc riêng.
  LinearGradient _sky(WeatherCondition c) {
    final colors = switch (c) {
      // Nắng/quang đãng — xanh ngọc rực → xanh dương.
      WeatherCondition.clear => const [Color(0xFF2BC0E4), Color(0xFF1565C0)],
      // Nhiều mây — tím oải hương → chàm.
      WeatherCondition.clouds => const [Color(0xFF8E9EFB), Color(0xFF5A4FCF)],
      // Mưa — xanh ngọc → xám đậm.
      WeatherCondition.rainy => const [Color(0xFF4CA1AF), Color(0xFF223243)],
      // Giông bão — tím rực → tím đậm.
      WeatherCondition.storm => const [Color(0xFF8E2DE2), Color(0xFF3A0CA3)],
      // Tuyết — xanh băng sáng → xanh dương.
      WeatherCondition.snow => const [Color(0xFF56E0E0), Color(0xFF2D9CDB)],
      // Sương mù — tím nhạt → chàm.
      WeatherCondition.mist => const [Color(0xFF9D8EE0), Color(0xFF5C6BC0)],
    };
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = weather;
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _sky(w?.condition ?? WeatherCondition.clear),
        borderRadius: BorderRadius.circular(AppPalette.rCard),
        boxShadow: AppPalette.softShadow,
      ),
      child: w == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ClipRRect(
              borderRadius: BorderRadius.circular(AppPalette.rCard),
              child: Stack(
                children: [
                  // Mây mờ trang trí cho cảm giác bầu trời.
                  Positioned(
                    top: 4,
                    left: -20,
                    child: Icon(Icons.cloud,
                        size: 120, color: Colors.white.withValues(alpha: 0.16)),
                  ),
                  Positioned(
                    bottom: -10,
                    right: -16,
                    child: Icon(Icons.cloud,
                        size: 110, color: Colors.white.withValues(alpha: 0.13)),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Text(
                          w.city ?? 'Vị trí của bạn',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${w.temperatureC.round()}°',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 66,
                              fontWeight: FontWeight.w200,
                              height: 1.05),
                        ),
                        Text(
                          w.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        if (w.tempMax != null && w.tempMin != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'C:${w.tempMax!.round()}°   T:${w.tempMin!.round()}°',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
