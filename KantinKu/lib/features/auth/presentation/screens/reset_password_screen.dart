import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../widgets/account_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email, required this.token});
  final String email, token;
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _submitting = false;
  String? _error;
  @override
  void dispose() { _password.dispose(); _confirm.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_submitting || !_form.currentState!.validate()) return;
    final store = AppScope.of(context);
    setState(() { _submitting = true; _error = null; });
    try {
      await store.resetPassword(email: widget.email, token: widget.token, password: _password.text, confirmPassword: _confirm.text);
      if (!mounted) return;
      _password.clear(); _confirm.clear();
      await showDialog<void>(context: context, builder: (context) => AlertDialog(
        title: const Text('Password berhasil diubah'),
        content: const Text('Gunakan password baru untuk masuk ke akun DEMO lokalmu.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali ke Masuk'))],
      ));
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst || route.settings.name == '/login');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Password baru')),
    body: Form(key: _form, child: FormScrollView(padding: const EdgeInsets.all(20), children: [
      Text('Buat password baru', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16),
      const Text('Atur ulang password akun melalui kode pemulihan DEMO lokal.'),
      const SizedBox(height: 18),
      InfoBox('Pemulihan DEMO\nUntuk akun ${widget.email}'),
      const SizedBox(height: 24),
      AccountField(label: 'Password baru', controller: _password, hint: 'Masukkan password baru', secret: true, validator: accountPasswordValidator),
      const Text('Gunakan minimal 8 karakter. Pilih password khusus demo yang berbeda dari password layanan lain.', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 20),
      AccountField(label: 'Konfirmasi password baru', controller: _confirm, hint: 'Ulangi password baru', secret: true, validator: (value) => value != _password.text ? 'Kedua password harus sama.' : accountPasswordValidator(value)),
      if (_error != null) ...[InfoBox(_error!, error: true), const SizedBox(height: 12)],
      AppButton(label: 'Simpan password baru', onPressed: _save, loading: _submitting),
    ])),
  );
}
