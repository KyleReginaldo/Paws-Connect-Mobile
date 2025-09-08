extension DoubleExt on double {
  double progress(double targetAmount) {
    if (targetAmount <= 0) return 0; // avoid division by zero
    return (this / targetAmount).clamp(0.0, 1.0);
  }

  int get percentage => (this * 100).round();
}
