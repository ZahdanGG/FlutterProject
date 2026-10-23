import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Data dan privasi')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Data untuk akun dan pengambilan', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 14),
      const Text('Berikut data profil yang digunakan di KantinKu.'),
      const SizedBox(height: 20),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final item in const [
          ('Nama lengkap', 'Untuk mengenali akun dan nama pemesan saat pengambilan.'),
          ('Email', 'Untuk masuk ke akun dan pemulihan password.'),
          ('Nomor HP', 'Untuk informasi kontak terkait akun dan pengambilan pesanan.'),
          ('Peran', 'Untuk menyesuaikan profil, seperti Mahasiswa, Pekerja, Dosen/Staf, atau Lainnya.'),
        ]) ...[
          Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(item.$2, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
        ],
      ])),
      const SizedBox(height: 16),
      const InfoBox('KantinKu tidak meminta KTP atau nomor induk untuk profil. Mahasiswa dapat melengkapi kampus dan program studi.'),
      const SizedBox(height: 20),
      Text(AppScope.of(context).stage == 1
          ? 'Tahap 1 merupakan pratinjau UI; formulir akun belum menyimpan data. Jangan gunakan password atau data sensitif sungguhan.'
          : 'Versi DEMO menyimpan data secara lokal pada perangkat. Jangan gunakan password atau data sensitif yang dipakai di layanan lain. Menghapus data aplikasi akan menghapus akun demo dan riwayat lokal.'),
      const SizedBox(height: 20),
      FilledButton.tonal(
        onPressed: () => Navigator.pushNamed(context, AppScope.of(context).isLoggedIn ? '/edit-profile' : '/login'),
        child: const Text('Edit profil'),
      ),
      TextButton(onPressed: () => Navigator.pushNamed(context, '/help'), child: const Text('Hubungi dukungan lewat Bantuan')),
    ]),
  );
}
