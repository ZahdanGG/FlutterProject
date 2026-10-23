import 'package:flutter/material.dart';

import '../../../../core/widgets/app_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tentang KantinKu')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [
        Icon(Icons.lunch_dining_outlined, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Text('KantinKu', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
      ]),
      const SizedBox(height: 24),
      Text('Pesan sebelum istirahat.\nAmbil saat siap.', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 18),
      const Text('KantinKu membantu mahasiswa, pekerja, dosen, staf, dan pengunjung memesan makanan dari kantin.'),
      const SizedBox(height: 24),
      Text('Versi desain 1.0', style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 20),
      FilledButton.tonal(onPressed: () => Navigator.pushNamed(context, '/privacy'), child: const Text('Tentang data dan privasi')),
      const SizedBox(height: 20),
      const InfoBox('DEMO pembelajaran. Tidak terhubung ke kantin, server autentikasi, atau penyedia pembayaran sungguhan.'),
    ]),
  );
}
