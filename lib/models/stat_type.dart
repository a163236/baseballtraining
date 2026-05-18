enum StatType {
  pitchSpeed('球速'),
  breakingBall('変化球'),
  meet('ミート'),
  power('パワー'),
  speed('走力'),
  defense('守備力');

  const StatType(this.label);
  final String label;
}
