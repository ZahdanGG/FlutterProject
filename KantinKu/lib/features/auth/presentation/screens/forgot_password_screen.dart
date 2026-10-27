import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../widgets/account_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _token;
  String? _error;
  bool _submitting = false;

  @override
  void dispose() { _email.dispose(); super.dispose(); }

  Future<void> _requestReset() async {
    if (_submitting || !_form.currentState!.validate()) return;
    final store = AppScope.of(context);
    setState(() { _submitting = true; _error = null; });
    try {
      final token = await store.requestPasswordReset(_email.text.trim());
      if (mounted) setState(() => _token = token);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_token == null ? 'Lupa password' : 'Pemulihan password')),
    body: Form(
      key: _form,
      child: FormScrollView(padding: const EdgeInsets.all(20), children: [
        if (_token == null) ...[
          Text('Pulihkan akunmu', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          const Text('Masukkan email akun DEMO yang sudah terdaftar pada perangkat ini.'),
          const SizedBox(height: 24),
          AccountField(label: 'Email', controller: _email, hint: 'nama@email.com', keyboardType: TextInputType.emailAddress, validator: accountEmailValidator),
          if (_error != null) ...[InfoBox(_error!, error: true), const SizedBox(height: 12)],
          AppButton(label: 'Buat kode pemulihan DEMO', onPressed: _requestReset, loading: _submitting),
          const SizedBox(height: 16),
          const InfoBox('Mode DEMO tidak mengirim email. Kode pemulihan lokal ditampilkan di aplikasi untuk latihan.'),
        ] else ...[
          const SizedBox(height: 36),
          Icon(Icons.mark_email_read_outlined, size: 46, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text('Kode pemulihan DEMO', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          Text('Pemulihan lokal untuk ${_email.text.trim()}. Tidak ada email yang dikirim.', textAlign: TextAlign.center),
          const SizedBox(height: 30),
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Langkah selanjutnya', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Text('Lanjutkan untuk mengatur password baru. Kode hanya dapat digunakan sekali dan memiliki masa berlaku terbatas.'),
            const SizedBox(height: 14),
            SelectableText(_token!, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          ])),
          if (_error != null) ...[const SizedBox(height: 12), InfoBox(_error!, error: true)],
          const SizedBox(height: 20),
          AppButton(label: 'Buat password baru', onPressed: () => Navigator.pushNamed(context, '/reset-password', arguments: {'email': _email.text.trim(), 'token': _token!})),
          const SizedBox(height: 12),
          AppButton(label: 'Buat ulang kode', outlined: true, loading: _submitting, onPressed: _requestReset),
          const SizedBox(height: 24),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali ke Masuk')),
        ],
      ]),
    ),
  );
}
