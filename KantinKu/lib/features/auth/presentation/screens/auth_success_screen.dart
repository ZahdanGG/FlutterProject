import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';

class AuthSuccessScreen extends StatelessWidget {
  const AuthSuccessScreen({super.key});

  void _continue(BuildContext context) {
    final navigator = Navigator.of(context);
    var atLogin = false;
    navigator.popUntil((route) {
      if (route.settings.name == '/login') {
        atLogin = true;
        return true;
      }
      return route.isFirst || !const ['/auth-success', '/register', '/register-role'].contains(route.settings.name);
    });
    if (atLogin) navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).user;
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) { if (!didPop) _continue(context); },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Buat akun'),
        leading: IconButton(tooltip: 'Lanjut ke menu sebelumnya', icon: const Icon(Icons.arrow_back), onPressed: () => _continue(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 60),
        Icon(Icons.check, size: 44, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 26),
        Text('Akun berhasil dibuat', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Selamat datang, ${user?.name ?? ''}! Akun ${user?.role ?? ''} DEMO-mu sudah siap digunakan.', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        const AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Lanjutkan melihat menu', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Kembali ke menu yang kamu lihat sebelum mendaftar. Kamu bisa melanjutkan memilih makanan dari sana.'),
        ])),
        const SizedBox(height: 20),
        AppButton(label: 'Lanjut ke menu sebelumnya', onPressed: () => _continue(context)),
        const SizedBox(height: 16),
        Text('Belum ada pesanan yang dibuat. Checkout dilakukan setelah kamu memilih menu.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
      ]),
      ),
    );
  }
}
