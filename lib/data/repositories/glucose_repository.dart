import '../models/glucose_reading.dart';
class InMemoryGlucoseRepository {
  final List<GlucoseReading> _store = [];
  Future<void> save(GlucoseReading r) async { _store.add(r); if (_store.length > 2016) _store.removeAt(0); }
  Future<List<GlucoseReading>> getLast(int n) async { final s = (_store.length - n).clamp(0, _store.length); return List.unmodifiable(_store.sublist(s)); }
  Future<GlucoseReading?> getLatest() async => _store.isEmpty ? null : _store.last;
  double timeInRange({required double low, required double high, int lastN = 288}) {
    final r = _store.length > lastN ? _store.sublist(_store.length - lastN) : _store;
    if (r.isEmpty) return 0.0;
    return r.where((x) => x.valueMgdl >= low && x.valueMgdl <= high).length / r.length;
  }
  double average({int lastN = 288}) {
    if (_store.isEmpty) return 0.0;
    final r = _store.length > lastN ? _store.sublist(_store.length - lastN) : _store;
    return r.map((x) => x.valueMgdl).reduce((a, b) => a + b) / r.length;
  }
  int get totalReadings => _store.length;
}
