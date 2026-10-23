String rupiah(num amount) {
  final digits = amount.round().toString();
  final formatted = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return 'Rp$formatted';
}

String dateTimeLabel(DateTime time) {
  final d = time.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} · ${two(d.hour)}.${two(d.minute)}';
}
