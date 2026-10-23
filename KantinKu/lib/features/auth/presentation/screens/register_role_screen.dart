import 'package:flutter/material.dart';

class RegisterRoleScreen extends StatelessWidget {
  const RegisterRoleScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Daftar akun')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Langkah 1 dari 2', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 24),
        Text('Kamu menggunakan KantinKu sebagai...', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Text('Pilihan ini menyesuaikan profilmu. Semua peran bisa memesan dengan cara yang sama.'),
        const SizedBox(height: 24),
        for (final role in const ['Mahasiswa', 'Pekerja', 'Dosen/Staf', 'Lainnya'])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FilledButton.tonal(
              onPressed: () => Navigator.pushNamed(context, '/register', arguments: role),
              child: Text(role),
            ),
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text('Sudah punya akun? Masuk'),
        ),
        TextButton(
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          child: const Text('Lanjut melihat'),
        ),
      ],
    ),
  );
}
