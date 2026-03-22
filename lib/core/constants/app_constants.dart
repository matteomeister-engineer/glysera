abstract class AppConstants {
  static const String appName = 'Glysera';
  static const String appVersion = '1.0.0';
  static const String isoSafetyClass = 'B';
  static const double urgentLowThreshold = 54.0;
  static const double lowThreshold = 70.0;
  static const double highThreshold = 180.0;
  static const double urgentHighThreshold = 250.0;
  static const double defaultTargetLow = 70.0;
  static const double defaultTargetHigh = 180.0;
  static const Duration cgmSimulatedInterval = Duration(seconds: 10);
  static const double cgmMinGlucose = 40.0;
  static const double cgmMaxGlucose = 400.0;
  static const int predictionWindowSize = 6;
  static const int predictionHorizonMinutes = 30;
  static const String prefOnboardingComplete = 'onboarding_complete';
  static const String prefGlucoseUnit = 'glucose_unit';
  static const String prefTherapyMode = 'therapy_mode';
  static const String prefTargetLow = 'target_low';
  static const String prefTargetHigh = 'target_high';
  static const String prefPatientName = 'patient_name';
  static const String prefAlertLow = 'alert_low';
  static const String prefAlertHigh = 'alert_high';
  static const String prefAlertUrgentLow = 'alert_urgent_low';
  static const String prefAlertUrgentHigh = 'alert_urgent_high';
  static const int notifIdUrgentLow = 1;
  static const int notifIdLow = 2;
  static const int notifIdHigh = 3;
  static const int notifIdUrgentHigh = 4;
}

enum GlucoseUnit {
  mgdl('mg/dL'),
  mmoll('mmol/L');
  final String label;
  const GlucoseUnit(this.label);
}

enum TherapyMode {
  pump('Insulin pump', 'Type 1 — closed/open loop pump'),
  pen('Insulin pen (MDI)', 'Type 1 — multiple daily injections'),
  type2('Type 2', 'Oral medication or basal insulin'),
  gestational('Gestational', 'Pregnancy-related diabetes');
  final String label;
  final String description;
  const TherapyMode(this.label, this.description);
}

enum GlucoseTrend {
  rapidlyRising, rising, slowlyRising, stable, slowlyFalling, falling, rapidlyFalling;
  String get arrow {
    switch (this) {
      case rapidlyRising: return '↑↑';
      case rising: return '↑';
      case slowlyRising: return '↗';
      case stable: return '→';
      case slowlyFalling: return '↘';
      case falling: return '↓';
      case rapidlyFalling: return '↓↓';
    }
  }
  String get label {
    switch (this) {
      case rapidlyRising: return 'Rapidly rising';
      case rising: return 'Rising';
      case slowlyRising: return 'Slowly rising';
      case stable: return 'Stable';
      case slowlyFalling: return 'Slowly falling';
      case falling: return 'Falling';
      case rapidlyFalling: return 'Rapidly falling';
    }
  }
}
