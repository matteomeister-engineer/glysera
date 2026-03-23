import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/glucose_reading.dart';
import '../core/constants/constants.dart';

// ─────────────────────────────────────────────────────────────
// HiveService
//
// Single entry point for all Hive reads and writes.
// Boxes:
//   'glucose'  — GlucoseReadingHive objects (ring buffer, max 288 = 24h at 5min)
//   'profile'  — UserProfile fields as primitives (key/value)
//   'logbook'  — LogbookEntryHive objects
//
// Call HiveService.init() once in main() before runApp().
// ─────────────────────────────────────────────────────────────

class HiveService {
  static const String _glucoseBox  = 'glucose';
  static const String _profileBox  = 'profile';
  static const int    _maxReadings = 288; // 24h at 5-min intervals

  // ── Initialisation ──────────────────────────────────────────

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_glucoseBox);
    await Hive.openBox(_profileBox);
  }

  // ── Glucose readings ────────────────────────────────────────

  static Box<Map> get _glucose => Hive.box<Map>(_glucoseBox);

  /// Persist a single reading. Automatically evicts oldest if over limit.
  static Future<void> saveReading(GlucoseReading r) async {
    await _glucose.put(r.id, _readingToMap(r));
    // Trim to ring buffer size — keep most recent
    if (_glucose.length > _maxReadings) {
      final oldest = _glucose.keys.first;
      await _glucose.delete(oldest);
    }
  }

  /// Return all stored readings, sorted oldest → newest.
  static List<GlucoseReading> loadReadings() {
    return _glucose.values
        .map((m) => _readingFromMap(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Most recent reading only, or null if box is empty.
  static GlucoseReading? loadLatestReading() {
    if (_glucose.isEmpty) return null;
    return _readingFromMap(Map<String, dynamic>.from(_glucose.values.last));
  }

  // ── User profile ────────────────────────────────────────────

  static Box get _profile => Hive.box(_profileBox);

  static Future<void> saveProfileField(String key, dynamic value) async {
    await _profile.put(key, value);
  }

  static T? loadProfileField<T>(String key) {
    final v = _profile.get(key);
    if (v == null) return null;
    return v as T;
  }

  // ── Serialisation helpers ───────────────────────────────────

  static Map<String, dynamic> _readingToMap(GlucoseReading r) => {
    'id':             r.id,
    'valueMgdl':      r.valueMgdl,
    'timestamp':      r.timestamp.toIso8601String(),
    'trend':          r.trend.name,
    'rateOfChange':   r.rateOfChange,
    'alertTriggered': r.alertTriggered,
  };

  static GlucoseReading _readingFromMap(Map<String, dynamic> m) =>
      GlucoseReading(
        id:             m['id'] as String,
        valueMgdl:      (m['valueMgdl'] as num).toDouble(),
        timestamp:      DateTime.parse(m['timestamp'] as String),
        trend:          GlucoseTrend.values.byName(m['trend'] as String),
        rateOfChange:   (m['rateOfChange'] as num).toDouble(),
        alertTriggered: m['alertTriggered'] as bool? ?? false,
      );
}
