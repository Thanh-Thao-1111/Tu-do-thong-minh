import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/config/removebg_config.dart';
import 'background_removal_service.dart';

/// Tách nền ảnh bằng remove.bg. Nếu chưa cấu hình hoặc lỗi → trả lại ảnh gốc.
class RemoveBgBackgroundRemovalService implements BackgroundRemovalService {
  @override
  Future<Uint8List> removeBackground(Uint8List imageBytes) async {
    if (!RemoveBgConfig.isConfigured) return imageBytes;
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.remove.bg/v1.0/removebg'),
      )
        ..headers['X-Api-Key'] = RemoveBgConfig.apiKey
        ..fields['size'] = 'auto'
        ..files.add(http.MultipartFile.fromBytes('image_file', imageBytes,
            filename: 'item.jpg'));

      final streamed = await request.send();
      if (streamed.statusCode == 200) {
        final bytes = await streamed.stream.toBytes();
        return bytes;
      }
      return imageBytes; // lỗi -> giữ ảnh gốc
    } catch (_) {
      return imageBytes;
    }
  }
}
