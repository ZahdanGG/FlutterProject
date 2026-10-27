import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/widgets/account_field.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _submitting = false;
  String? _error;

  Future<void> _save() async {
    if (_submitting || !_form.currentState!.validate()) return;
    final store = AppScope.of(context);
    setState(() { _submitting = true; _error = null; });
    try {
      await store.changePassword(currentPassword: _current.text, password: _password.text, confirmPassword: _confirm.text);
      if (!mounted) return;
      _current.clear(); _password.clear(); _confirm.clear();
      showMessage(context, 'Password berhasil diperbarui.');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
  @override
  void dispose() {
    _current.dispose(); _password.dispose(); _confirm.dispose(); super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Keamanan akun')),
    body: Form(key: _form, child: FormScrollView(padding: const EdgeInsets.all(20), children: [
      Text('Ubah password', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 24),
      AccountField(label: 'Password saat ini', controller: _current, secret: true, validator: requiredAccountValue),
      AccountField(label: 'Password baru', controller: _password, hint: 'Minimal 8 karakter', secret: true, validator: accountPasswordValidator),
      AccountField(label: 'Konfirmasi password baru', controller: _confirm, hint: 'Ulangi password', secret: true, validator: (value) => value != _password.text ? 'Kedua password harus sama.' : accountPasswordValidator(value)),
      if (_error != null) ...[InfoBox(_error!, error: true), const SizedBox(height: 12)],
      AppButton(label: 'Simpan password', onPressed: _save, loading: _submitting),
    ])),
  );
}
