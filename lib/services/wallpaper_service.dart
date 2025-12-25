import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperService {
  static const String _cacheKey = 'cached_wallpaper_path';
  static const String _timestampKey = 'wallpaper_timestamp';
  static const Duration _cacheDuration = Duration(hours: 24);

  // Unsplash Access Key (请替换为您的实际 Access Key)
  // 注意：如果没有 Access Key，可以使用 demo 模式，但有请求限制
  static const String _accessKey = 'YOUR_UNSPLASH_ACCESS_KEY';

  // 预定义的壁纸集合 ID（可以是您喜欢的旅行相关集合）
  static const List<String> _collectionIds = [
    '1065976', // Travel collection
    '336578', // Nature landscapes
    '1217973', // Mountains
  ];

  /// 获取缓存的壁纸路径
  Future<String?> getCachedWallpaper() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPath = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_timestampKey);

      if (cachedPath == null || timestamp == null) {
        return null;
      }

      // 检查缓存是否过期
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      if (now.difference(cacheTime) > _cacheDuration) {
        // 缓存过期，删除文件
        final file = File(cachedPath);
        if (await file.exists()) {
          await file.delete();
        }
        await prefs.remove(_cacheKey);
        await prefs.remove(_timestampKey);
        return null;
      }

      // 验证文件是否存在
      final file = File(cachedPath);
      if (await file.exists()) {
        return cachedPath;
      }

      return null;
    } catch (e) {
      // 缓存获取失败，返回 null
      return null;
    }
  }

  /// 从 Unsplash 获取随机壁纸
  Future<String?> fetchRandomWallpaper() async {
    try {
      // 如果没有设置 Access Key，使用 demo 模式（有请求限制）
      if (_accessKey == 'YOUR_UNSPLASH_ACCESS_KEY') {
        return await _fetchDemoWallpaper();
      }

      // 随机选择一个集合
      final random = Random();
      final collectionId =
          _collectionIds[random.nextInt(_collectionIds.length)];

      final url = Uri.parse(
        'https://api.unsplash.com/collections/$collectionId/photos?per_page=30&client_id=$_accessKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // 解析 JSON 并随机选择一张图片
        final List<dynamic> photos = response.body as List<dynamic>;
        if (photos.isEmpty) return null;

        final selectedPhoto = photos[random.nextInt(photos.length)];
        final imageUrl = selectedPhoto['urls']['regular'] as String;

        return await _downloadAndCacheImage(imageUrl);
      } else {
        // Unsplash API 错误，使用备用方案
        return await _fetchDemoWallpaper();
      }
    } catch (e) {
      // 获取壁纸失败，使用备用方案
      return await _fetchDemoWallpaper();
    }
  }

  /// Demo 模式：使用 Picsum Photos 作为替代
  Future<String?> _fetchDemoWallpaper() async {
    try {
      final random = Random();
      final imageId = random.nextInt(1000);
      final imageUrl = 'https://picsum.photos/id/$imageId/1200/800';

      return await _downloadAndCacheImage(imageUrl);
    } catch (e) {
      // 备用方案也失败，返回 null
      return null;
    }
  }

  /// 下载并缓存图片
  Future<String?> _downloadAndCacheImage(String imageUrl) async {
    try {
      final response = await http
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // 获取应用文档目录
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '${directory.path}/$fileName';

        // 保存图片
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // 更新缓存信息
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, filePath);
        await prefs.setInt(
          _timestampKey,
          DateTime.now().millisecondsSinceEpoch,
        );

        return filePath;
      }
    } catch (e) {
      // 图片下载失败
      return null;
    }

    return null;
  }

  /// 清除缓存
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPath = prefs.getString(_cacheKey);

      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      await prefs.remove(_cacheKey);
      await prefs.remove(_timestampKey);
    } catch (e) {
      // 清除缓存失败，静默处理
    }
  }

  /// 检查是否需要更新壁纸
  Future<bool> shouldUpdateWallpaper() async {
    final cachedPath = await getCachedWallpaper();
    return cachedPath == null;
  }

  /// 预加载壁纸（在应用启动时调用）
  Future<String?> preloadWallpaper() async {
    final cachedPath = await getCachedWallpaper();
    if (cachedPath != null) {
      return cachedPath;
    }

    // 如果没有缓存，获取新的壁纸
    return await fetchRandomWallpaper();
  }
}
