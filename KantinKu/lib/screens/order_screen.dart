import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../navigation/routes.dart';
import '../state/app_state.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';

/// Figma frame "Order — Pesanan" (6:11216).
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const PageHeader(title: 'Pesanan'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AddressCard(),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 27,
                            child: Text('Pesanan Kamu',
                                style: inter(18, w700, AppColors.ink)),
                          ),
                          const SizedBox(height: 16),
                          for (final e in s.cartByWarung.entries) ...[
                            _warungCard(context, e.key, e.value),
                            const SizedBox(height: 16),
                          ],
                          _voucherCard(),
                          const SizedBox(height: 16),
                          _summary(s),
                        ],
                      ),
                    ),
                  ),
                  TotalActionBar(
                    total: s.total,
                    buttonLabel: 'Checkout',
                    onTap: () => Nav.push(context, AppScreen.checkout),
                  ),
                ],
              ),
            ),
          ),
          const AppBottomNav(
            active: NavTab.orders,
            labels: NavLabels.english,
            shadowAlpha: 0.1,
          ),
        ],
      ),
    );
  }

  Widget _warungCard(BuildContext context, String warung, List<CartLine> lines) {
    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(8),
                ),
                // "WARUNG A" -> "A"
                child: Text(warung.isEmpty ? '' : warung.substring(warung.length - 1),
                    style: inter(12, w700, AppColors.navy)),
              ),
              const SizedBox(width: 8),
              Text(warung, style: inter(14, w700, AppColors.ink)),
            ],
          ),
          for (final l in lines) ...[
            const SizedBox(height: 12),
            _line(context, l),
          ],
        ],
      ),
    );
  }

  Widget _line(BuildContext context, CartLine l) {
    final state = context.read<AppState>();
    final fav = context.select<AppState, bool>((s) => s.isFavorite(l.item.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.item.name, style: inter(13, w600, AppColors.ink)),
                  const SizedBox(height: 3),
                  // Figma shows the line total here (qty x unit price).
                  Text(rupiah(l.total), style: inter(12, w400, AppColors.muted)),
                ],
              ),
            ),
            Tappable(
              onTap: () => state.toggleFavorite(l.item.id),
              child: Icon(AppIcons.heart,
                  size: 18, color: fav ? AppColors.navy : AppColors.muted),
            ),
            const SizedBox(width: 8),
            Tappable(
              onTap: () => state.remove(l.item.id),
              child: const Icon(AppIcons.trash2, size: 18, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _qtyButton('−', filled: false, onTap: () => state.changeQty(l.item.id, -1)),
              const SizedBox(width: 10),
              Text('${l.qty}', style: inter(14, w700, AppColors.ink)),
              const SizedBox(width: 10),
              _qtyButton('+', filled: true, onTap: () => state.changeQty(l.item.id, 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyButton(String symbol, {required bool filled, required VoidCallback onTap}) =>
      Tappable(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? AppColors.navy : AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(symbol,
              style: inter(16, w600, filled ? Colors.white : AppColors.navy)),
        ),
      );

  Widget _voucherCard() => CardBox(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.amberTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(AppIcons.ticketPercent, size: 20, color: AppColors.amberText),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gunakan voucher', style: inter(13, w700, AppColors.ink)),
                  const SizedBox(height: 2),
                  Text('Diskon hingga 100%', style: inter(12, w400, AppColors.muted)),
                ],
              ),
            ),
            const Icon(AppIcons.chevronRight, size: 17, color: AppColors.muted),
          ],
        ),
      );

  Widget _summary(AppState s) => CardBox(
        child: Column(
          children: [
            DetailRow('Subtotal', rupiah(s.subtotal)),
            const SizedBox(height: 10),
            DetailRow('Biaya Pengiriman', rupiah(s.delivery)),
            const SizedBox(height: 10),
            DetailRow('Biaya Layanan', rupiah(s.service)),
            const SizedBox(height: 10),
            DetailRow('Diskon', rupiah(-s.discount), valueColor: AppColors.green),
            const SizedBox(height: 10),
            const Divider1(),
            const SizedBox(height: 10),
            TotalRow(rupiah(s.total)),
          ],
        ),
      );
}
