import 'package:flutter/material.dart';

import '../widgets/account_field.dart';
import '../../../../core/widgets/app_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lupa password')),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Pulihkan akunmu', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          const Text('Masukkan email akun untuk melihat alur pemulihan password.'),
          const SizedBox(height: 24),
          AccountField(label: 'Email', controller: _email, hint: 'nama@email.com', keyboardType: TextInputType.emailAddress, validator: accountEmailValidator),
          FilledButton(
            onPressed: () {
              if (_form.currentState!.validate()) foundationNotice(context);
            },
            child: const Text('Kirim tautan pemulihan'),
          ),
        ],
      ),
    ),
  );
}
