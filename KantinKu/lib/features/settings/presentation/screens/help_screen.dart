import 'package:flutter/material.dart';

import '../../../../core/widgets/app_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key, this.topic});
  final String? topic;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bantuan')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      if (topic == null) ...[
        Text('Apa yang bisa kami bantu?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        for (final title in const ['Cara memesan dan mengambil', 'Pembayaran belum terkonfirmasi', 'Pesanan belum siap']) ...[
          AppCard(padding: EdgeInsets.zero, child: ListTile(
            leading: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.primary),
            title: Text(title, style: const TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/help', arguments: title),
          )),
          const SizedBox(height: 12),
        ],
        const InfoBox('Untuk kendala pesanan, temui petugas kantin dengan membawa kode pesanan.', icon: Icons.shield_outlined),
      ] else if (topic == 'Cara memesan dan mengambil') ...[
        Text('Cara pesan dan ambil', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        for (final (index, item) in const [
          ('Pilih satu kantin', 'Buka kantin yang ingin kamu pesan. Semua menu dalam satu pesanan berasal dari kantin yang sama.'),
          ('Pilih menu dan catatan', 'Tambahkan menu, atur jumlah, dan tulis catatan bila diperlukan.'),
          ('Periksa keranjang', 'Pastikan menu, jumlah, catatan, dan total sudah sesuai.'),
          ('Pilih slot pengambilan', 'Pilih waktu pengambilan yang tersedia sebelum melanjutkan pembayaran.'),
          ('Pilih QRIS atau e-wallet, lalu bayar', 'Pada aplikasi DEMO ini, gunakan tombol simulasi pembayaran. Tidak ada uang sungguhan yang dipindahkan.'),
          ('Tunggu “Siap diambil”', 'Pantau status di Order. Untuk latihan, lanjutkan status melalui kontrol simulasi di detail pesanan.'),
          ('Tunjukkan kode di kantin', 'Dalam layanan sungguhan, tunjukkan kode pengambilan kepada petugas. Kode DEMO bukan bukti transaksi nyata.'),
        ].indexed)
          Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 14, backgroundColor: Theme.of(context).colorScheme.secondaryContainer, child: Text('${index + 1}', style: const TextStyle(fontSize: 12))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text(item.$2, style: Theme.of(context).textTheme.bodySmall),
            ])),
          ])),
        const InfoBox('Pesanan diambil langsung di kantin. Tidak tersedia pengantaran atau pembayaran COD.'),
      ] else ...[
        Text(topic!, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        Text(topic == 'Pembayaran belum terkonfirmasi'
            ? 'Buka detail pesanan dan periksa status pembayaran. Pembayaran dalam aplikasi ini menggunakan layanan DEMO lokal. Gunakan tombol simulasi berhasil atau gagal; jangan melakukan transfer uang sungguhan.'
            : 'Buka tab Order untuk memeriksa status. Pesanan dapat diambil setelah berstatus Siap diambil. Dalam DEMO, kontrol simulasi pada detail pesanan membantu mencoba urutan Diproses hingga Selesai.'),
        const SizedBox(height: 20),
        const InfoBox('Saat layanan produksi tersedia, sampaikan kode pesanan kepada petugas kantin untuk meminta bantuan. Aplikasi demo ini belum memiliki dukungan daring.'),
      ],
    ]),
  );
}
