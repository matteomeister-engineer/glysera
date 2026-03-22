import 'app_constants.dart';
abstract class GlucoseConverter {
  static const double _factor = 18.0182;
  static double toMmol(double mgdl) => mgdl / _factor;
  static double toMgdl(double mmol) => mmol * _factor;
  static String format(double mgdl, GlucoseUnit unit) {
    if (unit == GlucoseUnit.mgdl) return mgdl.round().toString();
    return toMmol(mgdl).toStringAsFixed(1);
  }
  static double threshold(double mgdl, GlucoseUnit unit) {
    if (unit == GlucoseUnit.mgdl) return mgdl;
    return double.parse(toMmol(mgdl).toStringAsFixed(1));
  }
}
