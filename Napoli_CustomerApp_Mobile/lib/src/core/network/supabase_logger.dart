// ignore_for_file: avoid_print
// This file intentionally uses print() for terminal debugging visibility.

import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase logging wrapper for debugging database communication.
/// Wrap queries with this to see them in the terminal.
class SupabaseLogger {
  SupabaseLogger._();

  static bool enabled = true;
  static const String _tag = 'SUPABASE';

  /// Log a query operation
  static void logQuery(
    String table,
    String operation, {
    Map<String, dynamic>? filters,
    String? select,
  }) {
    if (!enabled) return;

    final buffer = StringBuffer();
    buffer.write('[$_tag] $operation FROM $table');

    if (select != null && select.isNotEmpty) {
      buffer.write(
        ' SELECT: ${select.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim()}',
      );
    }

    if (filters != null && filters.isNotEmpty) {
      buffer.write(' WHERE: $filters');
    }

    developer.log(buffer.toString(), name: _tag);
    print(buffer.toString()); // Also print to console for visibility
  }

  /// Log a response
  static void logResponse(String table, dynamic data, {int? count}) {
    if (!enabled) return;

    final actualCount = count ?? (data is List ? data.length : 1);
    final preview = data is List && data.isNotEmpty
        ? data.first.toString().substring(
            0,
            (data.first.toString().length).clamp(0, 100),
          )
        : data.toString().substring(0, (data.toString().length).clamp(0, 100));

    final message =
        '[$_tag] RESPONSE $table: $actualCount rows | Preview: $preview...';
    developer.log(message, name: _tag);
    print(message);
  }

  /// Log an error
  static void logError(String table, String operation, Object error) {
    if (!enabled) return;

    final message = '[$_tag] ERROR $operation $table: $error';
    developer.log(message, name: _tag, level: 1000);
    print('\x1B[31m$message\x1B[0m'); // Red color in terminal
  }

  /// Log an insert/update/delete operation
  static void logMutation(
    String table,
    String operation,
    Map<String, dynamic> data,
  ) {
    if (!enabled) return;

    // Sanitize sensitive fields
    final sanitized = Map<String, dynamic>.from(data);
    for (final key in ['password', 'token', 'secret']) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '***';
      }
    }

    final message =
        '[$_tag] $operation INTO $table: ${sanitized.keys.toList()}';
    developer.log(message, name: _tag);
    print(message);
  }
}

/// Extension on SupabaseQueryBuilder for logging
extension LoggingExtension on SupabaseQueryBuilder {
  /// Log this query before executing
  SupabaseQueryBuilder loggedSelect([String columns = '*']) {
    SupabaseLogger.logQuery(
      '', // Table name not easily accessible here
      'SELECT',
      select: columns,
    );
    return this;
  }
}
