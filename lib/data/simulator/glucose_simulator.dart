import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/glucose_reading.dart';
import '../../core/constants/constants.dart';
class GlucoseSimulator {
  final _uuid = const Uuid();
  final _random = Random();
  double _currentGlucose = 110.0;
  double _velocity = 0.0;
  bool _mealActive = false;
  int _mealStepsRemaining = 0;
  double _mealIntensity = 0.0;
  final List<double> _history = [];
  late StreamController<GlucoseReading> _controller;
  Timer? _timer;
  Stream<GlucoseReading> get stream => _controller.stream;
  void start() {
    _controller = StreamController<GlucoseReading>.broadcast();
    _currentGlucose = 100 + _random.nextDouble() * 30;
    _timer = Timer.periodic(AppConstants.cgmSimulatedInterval, (_) => _tick());
    _tick();
  }
  void stop() { _timer?.cancel(); _controller.close(); }
  void _tick() {
    _updateGlucose();
    final reading = _buildReading();
    _history.add(_currentGlucose);
    if (_history.length > 288) _history.removeAt(0);
    _controller.add(reading);
  }
  void _updateGlucose() {
    final rev = (110.0 - _currentGlucose) * 0.04;
    final noise = (_random.nextDouble() - 0.5) * 6.0;
    if (!_mealActive && _random.nextDouble() < 0.015) _triggerMeal();
    double meal = 0.0;
    if (_mealActive) {
      meal = _mealIntensity;
      _mealIntensity *= 0.85;
      if (--_mealStepsRemaining <= 0) { _mealActive = false; _mealIntensity = 0.0; }
    }
    final dawn = (DateTime.now().hour >= 4 && DateTime.now().hour <= 8) ? 0.4 : 0.0;
    _velocity = (_velocity * 0.7 + rev + noise + meal + dawn).clamp(-4.0, 4.0);
    _currentGlucose = (_currentGlucose + _velocity).clamp(AppConstants.cgmMinGlucose, AppConstants.cgmMaxGlucose);
  }
  void _triggerMeal() { _mealActive = true; _mealStepsRemaining = 4 + _random.nextInt(4); _mealIntensity = 3.0 + _random.nextDouble() * 5.0; }
  GlucoseReading _buildReading() {
    double roc = _history.length >= 2 ? (_currentGlucose - _history[_history.length - 1]) / (AppConstants.cgmSimulatedInterval.inSeconds / 60.0) : 0.0;
    return GlucoseReading(id: _uuid.v4(), valueMgdl: _currentGlucose, timestamp: DateTime.now(), trend: _trendFromRoc(roc), rateOfChange: roc);
  }
  GlucoseTrend _trendFromRoc(double r) {
    if (r > 3.0) return GlucoseTrend.rapidlyRising;
    if (r > 1.0) return GlucoseTrend.rising;
    if (r > 0.5) return GlucoseTrend.slowlyRising;
    if (r > -0.5) return GlucoseTrend.stable;
    if (r > -1.0) return GlucoseTrend.slowlyFalling;
    if (r > -3.0) return GlucoseTrend.falling;
    return GlucoseTrend.rapidlyFalling;
  }
  void simulateMeal() => _triggerMeal();
  List<double> get recentHistory => List.unmodifiable(_history);
}
