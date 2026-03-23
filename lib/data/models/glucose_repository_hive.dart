import 'glucose_reading.dart';
import '../../services/hive_service.dart';

// ─────────────────────────────────────────────────────────────
// HiveGlucoseRepository
// Drop-in replacement for InMemoryGlucoseRepository.
// All reads AND writes go through Hive — data survives restarts.
// ─────────────────────────────────────────────────────────────

class HiveGlucoseRepository {
  final List<GlucoseReading> _cache = [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _cache
      ..clear()
      ..addAll(HiveService.loadReadings());
    _loaded = true;
  }

  Future<void> save(GlucoseReading reading) async {
    await HiveService.saveReading(reading);
    _cache.add(reading);
    if (_cache.length > 288) _cache.removeAt(0);
  }

  List<GlucoseReading> getAll() => List.unmodifiable(_cache);

  List<GlucoseReading> getLast(int n) {
    if (_cache.length <= n) return List.unmodifiable(_cache);
    return List.unmodifiable(_cache.sublist(_cache.length - n));
  }

  GlucoseReading? getLatest() =>
      _cache.isEmpty ? null : _cache.last;

  double timeInRange({required double low, required double high}) {
    if (_cache.isEmpty) return 0;
    final inRange = _cache
        .where((r) => r.valueMgdl >= low && r.valueMgdl <= high)
        .length;
    return inRange / _cache.length;
  }

  double average() {
    if (_cache.isEmpty) return 100;
    return _cache.map((r) => r.valueMgdl).reduce((a, b) => a + b) /
        _cache.length;
  }

  int get totalReadings => _cache.length;
}
