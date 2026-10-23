import 'package:flutter/material.dart';

import '../widgets/account_field.dart';
import '../../../../core/widgets/app_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.role});
  final String role;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _institution = TextEditingController();
  final _department = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_name, _email, _phone, _password, _confirm, _institution, _department]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = switch (widget.role) {
      'Pekerja' => ('Perusahaan', 'Divisi'),
      'Dosen/Staf' => ('Institusi', 'Unit'),
      'Lainnya' => ('Kategori', 'Keterangan'),
      _ => ('Kampus', 'Program studi'),
    };
    return Scaffold(
      appBar: AppBar(title: Text('Daftar ${widget.role}')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Langkah 2 dari 2', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 18),
            Text('Lengkapi identitasmu', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            AccountField(label: 'Nama lengkap', controller: _name, hint: 'Nama lengkap', validator: requiredAccountValue),
            AccountField(label: 'Email', controller: _email, hint: 'nama@email.com', keyboardType: TextInputType.emailAddress, validator: accountEmailValidator),
            AccountField(label: 'Nomor HP', controller: _phone, hint: '08xx xxxx xxxx', keyboardType: TextInputType.phone, validator: requiredAccountValue),
            AccountField(label: 'Password', controller: _password, hint: 'Minimal 8 karakter', secret: true, validator: accountPasswordValidator),
            AccountField(
              label: 'Konfirmasi password',
              controller: _confirm,
              hint: 'Ulangi password',
              secret: true,
              validator: (value) => value != _password.text ? 'Password tidak sama. Coba periksa kembali.' : accountPasswordValidator(value),
            ),
            AccountField(label: labels.$1, controller: _institution, hint: '${labels.$1} kamu', validator: requiredAccountValue),
            AccountField(label: labels.$2, controller: _department, hint: '${labels.$2} kamu', validator: requiredAccountValue),
            const Text('Data untuk profil; tanpa KTP atau nomor induk.', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (_form.currentState!.validate()) foundationNotice(context);
              },
              child: const Text('Buat akun'),
            ),
          ],
        ),
      ),
    );
  }
}
