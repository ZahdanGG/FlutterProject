import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/widgets/account_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _institution = TextEditingController();
  final _department = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final user = AppScope.of(context).user;
      _name.text = user?.name ?? '';
      _email.text = user?.email ?? '';
      _phone.text = user?.phone ?? '';
      _institution.text = user?.institution ?? '';
      _department.text = user?.department ?? '';
      _loaded = true;
    }
  }

  @override
  void dispose() {
    for (final controller in [_name, _email, _phone, _institution, _department]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit profil')),
    body: Form(
      key: _form,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        AccountField(label: 'Nama lengkap', controller: _name, validator: requiredAccountValue),
        AccountField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, validator: accountEmailValidator),
        AccountField(label: 'Nomor HP', controller: _phone, keyboardType: TextInputType.phone, validator: requiredAccountValue),
        AccountField(label: 'Kampus', controller: _institution, validator: requiredAccountValue),
        AccountField(label: 'Program studi', controller: _department, validator: requiredAccountValue),
      ]),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AppButton(label: 'Simpan perubahan', onPressed: () {
          if (_form.currentState!.validate()) foundationNotice(context);
        }),
      ),
    ),
  );
}
