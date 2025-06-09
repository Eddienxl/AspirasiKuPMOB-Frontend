import 'dart:developer' as developer;

/// Custom logger utility for AspirasiKu app
/// Provides different log levels and proper formatting
class AppLogger {
  static const String _appName = 'AspirasiKu';
  
  /// Log error messages
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final logTag = tag ?? 'ERROR';
    developer.log(
      '🔴 $message',
      name: '$_appName.$logTag',
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log warning messages
  static void warning(String message, {String? tag}) {
    final logTag = tag ?? 'WARNING';
    developer.log(
      '⚠️ $message',
      name: '$_appName.$logTag',
      level: 900, // Warning level
    );
  }
  
  /// Log info messages
  static void info(String message, {String? tag}) {
    final logTag = tag ?? 'INFO';
    developer.log(
      'ℹ️ $message',
      name: '$_appName.$logTag',
      level: 800, // Info level
    );
  }
  
  /// Log debug messages (only in debug mode)
  static void debug(String message, {String? tag}) {
    final logTag = tag ?? 'DEBUG';
    developer.log(
      '🐛 $message',
      name: '$_appName.$logTag',
      level: 700, // Debug level
    );
  }
  
  /// Log network requests
  static void network(String message, {String? tag}) {
    final logTag = tag ?? 'NETWORK';
    developer.log(
      '🌐 $message',
      name: '$_appName.$logTag',
      level: 800, // Info level
    );
  }
  
  /// Log API responses
  static void api(String message, {String? tag}) {
    final logTag = tag ?? 'API';
    developer.log(
      '📡 $message',
      name: '$_appName.$logTag',
      level: 800, // Info level
    );
  }
  
  /// Log success messages
  static void success(String message, {String? tag}) {
    final logTag = tag ?? 'SUCCESS';
    developer.log(
      '✅ $message',
      name: '$_appName.$logTag',
      level: 800, // Info level
    );
  }
}
