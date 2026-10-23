import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  String? _slot;
  @override
  Widget build(BuildContext context) {
    _slot ??= AppScope.of(context).preferredPickupSlot;
    return Scaffold(
      appBar: AppBar(title: const Text('Preferensi waktu ambil')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Waktu ambil pilihanmu', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Text('Pilih waktu yang biasanya sesuai dengan waktu istirahatmu. Ketersediaan slot akan diperiksa kembali saat checkout.'),
        const SizedBox(height: 20),
        AppCard(padding: EdgeInsets.zero, child: Column(children: [
          for (final slot in const ['11.30–11.45', '11.45–12.00', '12.00–12.15', '12.15–12.30', '12.30–12.45'])
            RadioListTile<String>(title: Text(slot), value: slot, groupValue: _slot, onChanged: (value) => setState(() => _slot = value)),
        ])),
        const SizedBox(height: 20),
        AppButton(label: 'Simpan preferensi', onPressed: () => foundationNotice(context)),
      ]),
    );
  }
}
