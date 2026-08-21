abstract final class Formatters {
  static String bytes(int bytes) {
    if (bytes < 1024) return '$bytes B';

    const units = ['KB', 'MB', 'GB'];
    var value = bytes / 1024;
    var unit = units.first;

    for (var i = 1; i < units.length && value >= 1024; i++) {
      value /= 1024;
      unit = units[i];
    }

    final decimals = value >= 10 ? 0 : 1;
    return '${value.toStringAsFixed(decimals)} $unit';
  }

  static String percent(double value) {
    return '${(value.clamp(0, 1) * 100).toStringAsFixed(0)}%';
  }
}
