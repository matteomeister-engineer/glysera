import '../../core/constants/constants.dart';

class GlucoseReading {
  final String id;
  final double valueMgdl;
  final DateTime timestamp;
  final GlucoseTrend trend;
  final double rateOfChange;
  final bool alertTriggered;

  const GlucoseReading({
    required this.id,
    required this.valueMgdl,
    required this.timestamp,
    required this.trend,
    required this.rateOfChange,
    this.alertTriggered = false,
  });

  double get valueMmol => GlucoseConverter.toMmol(valueMgdl);
  String formattedValue(GlucoseUnit unit) => GlucoseConverter.format(valueMgdl, unit);

  GlucoseStatus get status {
    if (valueMgdl < AppConstants.urgentLowThreshold) return GlucoseStatus.urgentLow;
    if (valueMgdl < AppConstants.lowThreshold) return GlucoseStatus.low;
    if (valueMgdl <= AppConstants.highThreshold) return GlucoseStatus.inRange;
    if (valueMgdl <= AppConstants.urgentHighThreshold) return GlucoseStatus.high;
    return GlucoseStatus.urgentHigh;
  }

  bool get isUrgent =>
      status == GlucoseStatus.urgentLow || status == GlucoseStatus.urgentHigh;

  GlucoseReading copyWith({
    String? id,
    double? valueMgdl,
    DateTime? timestamp,
    GlucoseTrend? trend,
    double? rateOfChange,
    bool? alertTriggered,
  }) =>
      GlucoseReading(
        id: id ?? this.id,
        valueMgdl: valueMgdl ?? this.valueMgdl,
        timestamp: timestamp ?? this.timestamp,
        trend: trend ?? this.trend,
        rateOfChange: rateOfChange ?? this.rateOfChange,
        alertTriggered: alertTriggered ?? this.alertTriggered,
      );
}

enum GlucoseStatus {
  urgentLow, low, inRange, high, urgentHigh;

  String get label {
    switch (this) {
      case urgentLow:  return 'Urgent low';
      case low:        return 'Low';
      case inRange:    return 'In range';
      case high:       return 'High';
      case urgentHigh: return 'Urgent high';
    }
  }
}

class UserProfile {
  final String id;
  final String name;
  final DateTime? dateOfBirth;
  final GlucoseUnit glucoseUnit;
  final TherapyMode therapyMode;
  final double targetLowMgdl;
  final double targetHighMgdl;
  final bool alertUrgentLow, alertLow, alertHigh, alertUrgentHigh;
  final String avatarShape; // ← NEW

  const UserProfile({
    required this.id,
    required this.name,
    this.dateOfBirth,
    this.glucoseUnit = GlucoseUnit.mgdl,
    this.therapyMode = TherapyMode.type2,
    this.targetLowMgdl = AppConstants.defaultTargetLow,
    this.targetHighMgdl = AppConstants.defaultTargetHigh,
    this.alertUrgentLow = true,
    this.alertLow = true,
    this.alertHigh = true,
    this.alertUrgentHigh = true,
    this.avatarShape = '', // ← NEW
  });

  UserProfile copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    GlucoseUnit? glucoseUnit,
    TherapyMode? therapyMode,
    double? targetLowMgdl,
    double? targetHighMgdl,
    bool? alertUrgentLow,
    bool? alertLow,
    bool? alertHigh,
    bool? alertUrgentHigh,
    String? avatarShape, // ← NEW
  }) =>
      UserProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        glucoseUnit: glucoseUnit ?? this.glucoseUnit,
        therapyMode: therapyMode ?? this.therapyMode,
        targetLowMgdl: targetLowMgdl ?? this.targetLowMgdl,
        targetHighMgdl: targetHighMgdl ?? this.targetHighMgdl,
        alertUrgentLow: alertUrgentLow ?? this.alertUrgentLow,
        alertLow: alertLow ?? this.alertLow,
        alertHigh: alertHigh ?? this.alertHigh,
        alertUrgentHigh: alertUrgentHigh ?? this.alertUrgentHigh,
        avatarShape: avatarShape ?? this.avatarShape, // ← NEW
      );
}
