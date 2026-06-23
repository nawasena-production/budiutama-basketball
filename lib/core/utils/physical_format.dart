/// Format angka fisik (tinggi/berat) untuk tampilan dan input form.
String formatPhysicalValue(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

int calculateAge(DateTime dateOfBirth) {
  final now = DateTime.now();
  var age = now.year - dateOfBirth.year;
  if (now.month < dateOfBirth.month ||
      (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
    age--;
  }
  return age;
}

double? calculateBmi(double heightCm, double weightKg) {
  if (heightCm <= 0) return null;
  final h = heightCm / 100;
  return weightKg / (h * h);
}
