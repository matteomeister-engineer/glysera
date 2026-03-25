import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/glucose_reading.dart';
import '../core/constants/constants.dart';

// ─────────────────────────────────────────────────────────────
// GlucoseSharedStore
//
// 1. Writes latest reading + history to glucose_latest.json
//    (shared App Group file — WidgetKit reads this)
// 2. Pushes data to Apple Watch via WatchConnectivity
//    (method channel → AppDelegate → WCSession.sendMessage)
// ─────────────────────────────────────────────────────────────

class GlucoseSharedStore {
  static const String _appGroupId = 'group.com.matteomeister.glysera';
  static const String _fileName   = 'glucose_latest.json';

  static const MethodChannel _channel =
      MethodChannel('com.matteomeister.glysera/widget');

  // History buffer — last 36 readings (~3 hours at 5-min intervals)
  static final List<double> _historyBuffer = [];

  static Future<void> write(
    GlucoseReading reading,
    GlucoseUnit unit, {
    List<GlucoseReading>? fullHistory,
  }) async {
    try {
      // Build history buffer from full history if provided
      if (fullHistory != null && fullHistory.isNotEmpty) {
        _historyBuffer
          ..clear()
          ..addAll(fullHistory.takeLast(36).map((r) => r.valueMgdl));
      } else {
        _historyBuffer.add(reading.valueMgdl);
        if (_historyBuffer.length > 36) _historyBuffer.removeAt(0);
      }

      final isMmol  = unit == GlucoseUnit.mmoll;
      final value   = isMmol
          ? GlucoseConverter.toMmol(reading.valueMgdl)
          : reading.valueMgdl;
      final history = isMmol
          ? _historyBuffer.map((v) => GlucoseConverter.toMmol(v)).toList()
          : List<double>.from(_historyBuffer);

      final payload = {
        'value':     value.toStringAsFixed(isMmol ? 1 : 0),
        'valueMgdl': reading.valueMgdl,
        'trend':     _trendArrow(reading.trend),
        'trendName': reading.trend.name,
        'unit':      unit.label,
        'status':    reading.status.name,
        'timestamp': reading.timestamp.toIso8601String(),
        'history':   history,
      };

      // 1. Write JSON file for WidgetKit
      final file = await _sharedFile();
      await file.writeAsString(jsonEncode(payload));

      // 2. Push to Watch via WatchConnectivity (method channel)
      await _channel
          .invokeMethod('sendToWatch', payload)
          .catchError((_) {});

      // 3. Reload WidgetKit timeline
      await _channel
          .invokeMethod('reloadWidgets')
          .catchError((_) {});

    } catch (_) {
      // Never crash the main app
    }
  }

  static Future<File> _sharedFile() async {
    try {
      final result = await _channel
          .invokeMethod<String>('appGroupPath', _appGroupId)
          .catchError((_) => null);
      if (result != null) return File('$result/$_fileName');
    } catch (_) {}
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static String _trendArrow(GlucoseTrend trend) {
    switch (trend) {
      case GlucoseTrend.rapidlyRising:  return '↑↑';
      case GlucoseTrend.rising:         return '↑';
      case GlucoseTrend.slowlyRising:   return '↗';
      case GlucoseTrend.stable:         return '→';
      case GlucoseTrend.slowlyFalling:  return '↘';
      case GlucoseTrend.falling:        return '↓';
      case GlucoseTrend.rapidlyFalling: return '↓↓';
    }
  }
}

extension _ListTakeLast<T> on List<T> {
  List<T> takeLast(int n) =>
      length <= n ? this : sublist(length - n);
}
