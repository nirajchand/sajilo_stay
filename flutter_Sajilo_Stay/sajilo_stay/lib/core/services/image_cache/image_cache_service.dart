import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final imageCacheServiceProvider = Provider<ImageCacheService>((ref) {
  return ImageCacheService();
});

class ImageCacheService {
  late Directory _cacheDir;
  final Dio _dio = Dio();

  Future<void> init() async {
    _cacheDir = await getApplicationCacheDirectory();
    final dir = Directory('${_cacheDir.path}/stay_images');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  String _getFileNameFromUrl(String url) {
    return url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }

  Future<void> cacheImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    try {
      final fileName = _getFileNameFromUrl(imageUrl);
      final file = File('${_cacheDir.path}/stay_images/$fileName');

      if (file.existsSync()) return;

      final response = await _dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      await file.writeAsBytes(response.data);
    } catch (_) {}
  }

  Future<void> cacheImages(List<String> imageUrls) async {
    final futures = imageUrls.map((url) => cacheImage(url)).toList();
    await Future.wait(futures, eagerError: false);
  }

  File? getCachedImage(String imageUrl) {
    if (imageUrl.isEmpty) return null;

    try {
      final fileName = _getFileNameFromUrl(imageUrl);
      final file = File('${_cacheDir.path}/stay_images/$fileName');

      if (file.existsSync()) {
        return file;
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearCache() async {
    try {
      final dir = Directory('${_cacheDir.path}/stay_images');
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } catch (_) {}
  }

  Future<int> getCacheSize() async {
    try {
      final dir = Directory('${_cacheDir.path}/stay_images');
      int size = 0;

      if (dir.existsSync()) {
        dir.listSync(recursive: true).forEach((file) {
          if (file is File) {
            size += file.lengthSync();
          }
        });
      }

      return size;
    } catch (_) {
      return 0;
    }
  }
}
