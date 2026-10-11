/// 18000 -> "Rp18.000", -5000 -> "-Rp5.000"
String rupiah(int value) {
  final s = value.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${value < 0 ? '-' : ''}Rp$b';
}
