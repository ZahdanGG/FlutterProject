import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final user = store.user;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Me')),
      body: ListView(
        key: const PageStorageKey('me-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          if (user == null) ...[
            const LoginPanel(withBrand: true),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => store.setPreviewMode(true),
              child: const Text('Pratinjau profil masuk — Tahap 1'),
            ),
          ] else ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.secondaryContainer,
                      foregroundImage: user.id == 'preview' ? const AssetImage('assets/images/avatars/anjari.png') : null,
                      child: Text(user.name.trim().isEmpty ? 'K' : user.name.trim()[0].toUpperCase()),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(20)),
                        child: Text(user.role, style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ])),
                  ]),
                  const SizedBox(height: 12),
                  Text(user.email, style: TextStyle(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text(user.phone, style: TextStyle(color: colors.onSurfaceVariant)),
                  const Divider(height: 24),
                  Text(user.institution, style: TextStyle(color: colors.onSurfaceVariant)),
                  Text(user.department, style: TextStyle(color: colors.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Akunmu', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _AccountLink(Icons.edit_outlined, 'Edit profil', () => Navigator.pushNamed(context, '/edit-profile')),
                _AccountLink(Icons.receipt_long_outlined, 'Riwayat pesanan', () => AppRouter.goTab(context, 1)),
                _AccountLink(Icons.favorite_border, 'Menu favorit', () => foundationNotice(context)),
                _AccountLink(Icons.schedule, 'Preferensi waktu ambil', () => Navigator.pushNamed(context, '/preferences')),
                _AccountLink(Icons.shield_outlined, 'Keamanan akun', () => Navigator.pushNamed(context, '/security')),
              ]),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _AccountLink(Icons.help_outline, 'Bantuan', () => Navigator.pushNamed(context, '/help')),
                _AccountLink(Icons.lunch_dining_outlined, 'Tentang KantinKu', () => Navigator.pushNamed(context, '/about')),
              ]),
            ),
            const SizedBox(height: 14),
            FilledButton.tonal(
              style: FilledButton.styleFrom(backgroundColor: colors.errorContainer, foregroundColor: colors.onErrorContainer),
              onPressed: () async {
                final confirmed = await confirmAction(context, title: 'Keluar dari akun?', message: 'Kamu masih bisa melihat menu sebagai tamu. Masuk lagi untuk memesan dan melihat pesananmu.', confirmLabel: 'Keluar');
                if (confirmed) store.setPreviewMode(false);
              },
              child: const Text('Keluar'),
            ),
            const SizedBox(height: 12),
            const InfoBox('Pratinjau UI Tahap 1. Profil dan pesanan ini merupakan contoh, bukan session akun.'),
          ],
        ],
      ),
    );
  }
}

class _AccountLink extends StatelessWidget {
  const _AccountLink(this.icon, this.title, this.onTap);
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    minVerticalPadding: 11,
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
    title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    trailing: const Icon(Icons.chevron_right, size: 22),
    onTap: onTap,
  );
}
