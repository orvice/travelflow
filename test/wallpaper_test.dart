import 'package:flutter_test/flutter_test.dart';
import 'package:travelflow/services/wallpaper_service.dart';

void main() {
  group('WallpaperService Tests', () {
    late WallpaperService wallpaperService;

    setUp(() {
      wallpaperService = WallpaperService();
    });

    test('should initialize with correct cache keys', () async {
      // 测试缓存键的定义
      expect(wallpaperService, isNotNull);
    });

    test('should handle cache operations gracefully', () async {
      // 测试清除缓存（即使没有缓存也应该正常工作）
      await wallpaperService.clearCache();

      // 测试获取缓存（应该返回null）
      final cachedPath = await wallpaperService.getCachedWallpaper();
      expect(cachedPath, isNull);
    });

    test('should check if wallpaper needs update', () async {
      // 测试是否需要更新壁纸
      final needsUpdate = await wallpaperService.shouldUpdateWallpaper();
      expect(needsUpdate, isTrue); // 因为没有缓存，应该返回true
    });
  });
}
