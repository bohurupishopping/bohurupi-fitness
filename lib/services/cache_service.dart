import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheService {
  static final CacheService instance = CacheService._internal();
  CacheService._internal();

  CacheManager? _workoutImageCache;

  Future<void> initialize() async {
    _workoutImageCache = CacheManager(
      Config(
        'workout_images',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 100,
      ),
    );
  }

  CacheManager get workoutImageCache {
    if (_workoutImageCache == null) {
      throw StateError('CacheService not initialized. Call initialize() first.');
    }
    return _workoutImageCache!;
  }

  Future<void> clearCache() async {
    await _workoutImageCache?.emptyCache();
  }
} 