import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/services/app_store.dart';
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
    _slot ??= AppScope.of(context).pickupSlot ?? AppScope.of(context).preferredPickupSlot;
    return Scaffold(
      appBar: AppBar(title: const Text('Preferensi waktu ambil')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Waktu ambil pilihanmu', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Text('Pilih waktu yang biasanya sesuai dengan waktu istirahatmu. Ketersediaan slot akan diperiksa kembali saat checkout.'),
        const SizedBox(height: 20),
        AppCard(padding: EdgeInsets.zero, child: Column(children: [
          for (final slot in AppStore.pickupSlots)
            RadioListTile<String>(title: Text(slot), value: slot, groupValue: _slot, onChanged: (value) => setState(() => _slot = value)),
        ])),
        const SizedBox(height: 20),
        AppButton(label: 'Gunakan untuk checkout ini', onPressed: () {
          try {
            AppScope.of(context).setPickupSlot(_slot);
            showMessage(context, 'Waktu pengambilan dipilih untuk checkout saat ini.');
          } catch (error) {
            showMessage(context, error.toString());
          }
        }),
        const SizedBox(height: 16),
        const InfoBox('Tahap 2: pilihan berlaku untuk checkout saat ini. Preferensi permanen dan tema tersedia pada paket final.'),
      ]),
    );
  }
}
