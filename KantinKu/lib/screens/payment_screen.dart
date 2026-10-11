import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../navigation/routes.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// Figma frame "Payment — Pembayaran" (6:11441).
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'Pembayaran',
              leading: RoundIconButton(
                icon: AppIcons.chevronLeft,
                iconSize: 18,
                onTap: () => Nav.back(context, fallback: AppScreen.checkout),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      child: Column(
                        children: [
                          _summary(s),
                          const SizedBox(height: 18),
                          _qrisCard(context),
                          const SizedBox(height: 18),
                          _security(),
                          const Spacer(),
                          PrimaryButton(
                            label: 'Bayar dengan QRIS',
                            icon: AppIcons.qrCode,
                            onTap: () => Nav.push(context, AppScreen.qris),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(AppState s) => CardBox(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Pembayaran', style: inter(13, w400, AppColors.muted)),
            const SizedBox(height: 12),
            Text(rupiah(s.total), style: inter(26, w800, AppColors.ink)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Metode · ${s.payment.title}', style: inter(13, w600, AppColors.ink)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.amberTint,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('Menunggu Pembayaran',
                      style: inter(11, w700, AppColors.amberText)),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _qrisCard(BuildContext context) => CardBox(
        padding: const EdgeInsets.all(20),
        color: AppColors.skyTint,
        borderColor: AppColors.navy,
        borderWidth: 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(AppIcons.qrCode, size: 34, color: AppColors.navy),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QRIS', style: inter(20, w800, AppColors.navy)),
                    const SizedBox(height: 2),
                    Text('Pembayaran melalui QRIS', style: inter(12, w400, AppColors.muted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Pindai kode QR menggunakan aplikasi mobile banking atau dompet digital favoritmu.',
              style: inter(13, w400, AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Ganti Metode',
              outlined: true,
              onTap: () => Nav.push(context, AppScreen.metodePembayaran),
            ),
          ],
        ),
      );

  Widget _security() => CardBox(
        padding: const EdgeInsets.all(14),
        radius: 12,
        color: AppColors.mint,
        borderWidth: 0,
        child: Row(
          children: [
            const Icon(AppIcons.shieldCheck, size: 20, color: AppColors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pembayaran aman dan terverifikasi otomatis.',
                style: inter(12, w400, AppColors.green, height: 1.4),
              ),
            ),
          ],
        ),
      );
}
