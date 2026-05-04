import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Performance-optimized provider with debouncing.
class DebouncedNotifier<T> extends StateNotifier<T> {
  DebouncedNotifier(T initialState, this._debounceTime) : super(initialState);
  
  final Duration _debounceTime;
  Timer? _debounceTimer;

  void updateDebounced(T newState) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceTime, () {
      state = newState;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Cached computation provider for expensive operations.
class CachedComputationProvider<T, R> {
  final Map<T, R> _cache = {};
  final Map<T, DateTime> _timestamps = {};
  final Duration _cacheTimeout;

  CachedComputationProvider({
    Duration? cacheTimeout,
  }) : _cacheTimeout = cacheTimeout ?? const Duration(minutes: 5);

  R? getCached(T key) {
    if (!_cache.containsKey(key)) return null;
    
    final timestamp = _timestamps[key];
    if (timestamp == null) return null;
    
    // Check if cache entry has expired
    if (DateTime.now().difference(timestamp) > _cacheTimeout) {
      _cache.remove(key);
      _timestamps.remove(key);
      return null;
    }
    
    return _cache[key];
  }

  void setCached(T key, R result) {
    _cache[key] = result;
    _timestamps[key] = DateTime.now();
  }

  void clearCache() {
    _cache.clear();
    _timestamps.clear();
  }

  void clearExpired() {
    final now = DateTime.now();
    final expiredKeys = <T>[];
    
    for (final entry in _timestamps.entries) {
      if (now.difference(entry.value) > _cacheTimeout) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _cache.remove(key);
      _timestamps.remove(key);
    }
  }
}

/// Batch operation helper for Hive performance.
class BatchOperationHelper {
  static Future<void> batchWrite<T>(
    String boxName,
    Map<String, T> operations,
  ) async {
    // Implementation would depend on actual Hive setup
    // This is a placeholder for batch write optimization
  }

  static Future<void> batchDelete(
    String boxName,
    List<String> keys,
  ) async {
    // Implementation for batch delete
  }
}

/// Memory usage optimizer.
class MemoryOptimizer {
  static void scheduleGC() {
    // Force garbage collection (use sparingly)
    // Only in critical memory situations
    Timer(const Duration(milliseconds: 100), () {
      // GC hint - actual implementation depends on platform
    });
  }

  static void clearImageCache() {
    // Clear image cache to free memory
    // Implementation depends on image caching strategy
  }

  static void optimizeForLowMemory() {
    // Implement low-memory optimizations
    clearImageCache();
    scheduleGC();
  }
}

/// Performance monitoring helper.
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  
  static void startTimer(String operation) {
    _startTimes[operation] = DateTime.now();
  }
  
  static Duration? endTimer(String operation) {
    final startTime = _startTimes.remove(operation);
    if (startTime == null) return null;
    
    return DateTime.now().difference(startTime);
  }
  
  static void logOperation(String operation, Duration duration) {
    // Log performance metrics
    print('Performance: $operation took ${duration.inMilliseconds}ms');
    
    // Log warning for slow operations
    if (duration.inMilliseconds > 1000) {
      print('WARNING: Slow operation detected: $operation');
    }
  }
}