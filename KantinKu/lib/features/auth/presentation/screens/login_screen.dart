import 'package:flutter/material.dart';

import '../widgets/account_field.dart';
import '../../../../core/widgets/app_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Masuk')),
    body: const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: LoginPanel(),
    ),
  );
}

/// The guest Me tab and dedicated login route share the same form state.
class LoginPanel extends StatefulWidget {
  const LoginPanel({super.key, this.withBrand = false});
  final bool withBrand;

  @override
  State<LoginPanel> createState() => _LoginPanelState();
}

class _LoginPanelState extends State<LoginPanel> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.withBrand) ...[
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.restaurant, color: colors.onPrimary, size: 31),
                ),
                const SizedBox(width: 10),
                Text('KantinKu', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: colors.primary)),
              ],
            ),
            const SizedBox(height: 24),
          ],
          Text('Selamat datang kembali', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Text(
            widget.withBrand
                ? 'Masuk untuk memesan lebih awal dan melihat status makananmu.'
                : 'Masuk untuk memesan dari kantin favoritmu.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Form(
            key: _form,
            child: Container(
              padding: widget.withBrand ? const EdgeInsets.all(14) : EdgeInsets.zero,
              decoration: widget.withBrand
                  ? BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AccountField(
                    label: 'Email',
                    controller: _email,
                    hint: 'nama@email.com',
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: accountEmailValidator,
                  ),
                  AccountField(
                    label: 'Password',
                    controller: _password,
                    hint: 'Masukkan password',
                    secret: true,
                    autofillHints: const [AutofillHints.password],
                    validator: requiredAccountValue,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text('Lupa password?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      if (_form.currentState!.validate()) foundationNotice(context);
                    },
                    child: const Text('Masuk'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Belum punya akun?', textAlign: TextAlign.center),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/register-role'),
            child: const Text('Daftar'),
          ),
          const SizedBox(height: 12),
          const InfoBox('Tanpa akun, kamu tetap bisa melihat menu dan kantin di Home atau Browse.'),
        ],
      ),
    );
  }
}
