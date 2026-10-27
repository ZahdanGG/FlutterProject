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
  bool _submitting = false;
  String? _error;

  Future<void> _save() async {
    if (_submitting || !_form.currentState!.validate()) return;
    final store = AppScope.of(context);
    final user = store.user;
    if (user == null) return;
    setState(() { _submitting = true; _error = null; });
    try {
      await store.updateProfile(user.copyWith(name: _name.text.trim(), email: _email.text.trim(),
        phone: _phone.text.trim(), institution: _institution.text.trim(), department: _department.text.trim()));
      if (!mounted) return;
      showMessage(context, 'Profil berhasil disimpan. Perubahan data profilmu sudah tersimpan.');
      Navigator.pop(context);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

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
  Widget build(BuildContext context) {
    final role = AppScope.of(context).user?.role;
    final labels = switch (role) {
      'Pekerja' => ('Perusahaan', 'Divisi'),
      'Dosen/Staf' => ('Institusi', 'Unit'),
      'Lainnya' => ('Kategori', 'Keterangan'),
      _ => ('Kampus', 'Program studi'),
    };
    return Scaffold(
    appBar: AppBar(title: const Text('Edit profil')),
    body: Form(
      key: _form,
      child: FormScrollView(padding: const EdgeInsets.all(20), children: [
        AccountField(label: 'Nama lengkap', controller: _name, validator: requiredAccountValue),
        AccountField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, validator: accountEmailValidator),
        AccountField(label: 'Nomor HP', controller: _phone, keyboardType: TextInputType.phone, validator: requiredAccountValue),
        AccountField(label: labels.$1, controller: _institution, validator: requiredAccountValue),
        AccountField(label: labels.$2, controller: _department, validator: requiredAccountValue),
        if (_error != null) InfoBox(_error!, error: true),
      ]),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AppButton(label: 'Simpan perubahan', onPressed: _save, loading: _submitting),
      ),
    ),
    );
  }
}
