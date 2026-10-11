import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../navigation/routes.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// Figma frame "Checkout" (6:11347).
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageHeader(
              title: 'Checkout',
              leading: RoundIconButton(
                icon: AppIcons.chevronLeft,
                iconSize: 18,
                onTap: () => Nav.back(context, fallback: AppScreen.order),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AddressCard(),
                    const SizedBox(height: 15),
                    _orderList(s),
                    const SizedBox(height: 15),
                    _note(context, s),
                    const SizedBox(height: 15),
                    _paymentMethods(s),
                    const SizedBox(height: 15),
                    _summary(s),
                  ],
                ),
              ),
            ),
            TotalActionBar(
              total: s.total,
              buttonLabel: 'Bayar Sekarang',
              safeBottom: true,
              onTap: () => Nav.push(context, AppScreen.payment),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderList(AppState s) => CardBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pesanan Kamu', style: inter(15, w700, AppColors.ink)),
            for (final l in s.cart) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l.item.name, style: inter(13, w600, AppColors.ink)),
                          const SizedBox(height: 2),
                          Text('${l.item.warung ?? ''} · ${l.qty}×',
                              style: inter(12, w400, AppColors.muted)),
                        ],
                      ),
                    ),
                    Text(rupiah(l.total), style: inter(13, w600, AppColors.ink)),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Widget _note(BuildContext context, AppState s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Catatan untuk warung', style: inter(13, w700, AppColors.ink)),
          const SizedBox(height: 7),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(AppIcons.messageSquareText, size: 18, color: AppColors.muted),
                const SizedBox(width: 9),
                Expanded(
                  child: _NoteField(
                    initial: s.note,
                    onChanged: context.read<AppState>().setNote,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _paymentMethods(AppState s) {
    const icons = {
      PaymentMethod.qris: AppIcons.qrCode,
      PaymentMethod.saldo: AppIcons.walletCards,
      PaymentMethod.cod: AppIcons.banknote,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metode Pembayaran', style: inter(15, w700, AppColors.ink)),
        for (final m in PaymentMethod.values) ...[
          const SizedBox(height: 9),
          _MethodTile(method: m, icon: icons[m]!, selected: s.payment == m),
        ],
      ],
    );
  }

  Widget _summary(AppState s) => CardBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan Pembayaran', style: inter(15, w700, AppColors.ink)),
            const SizedBox(height: 12),
            DetailRow('Subtotal', rupiah(s.subtotal)),
            const SizedBox(height: 12),
            DetailRow('Biaya Pengiriman', rupiah(s.delivery)),
            const SizedBox(height: 12),
            DetailRow('Biaya Layanan', rupiah(s.service)),
            const SizedBox(height: 12),
            DetailRow('Diskon', rupiah(-s.discount), valueColor: AppColors.green),
            const SizedBox(height: 12),
            const Divider1(),
            const SizedBox(height: 12),
            TotalRow(rupiah(s.total)),
          ],
        ),
      );
}

class _NoteField extends StatefulWidget {
  const _NoteField({required this.initial, required this.onChanged});
  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<_NoteField> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _c,
        onChanged: widget.onChanged,
        style: inter(13, w400, AppColors.ink),
        decoration: const InputDecoration.collapsed(hintText: ''),
      );
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.method, required this.icon, required this.selected});
  final PaymentMethod method;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) => Tappable(
        onTap: () => context.read<AppState>().selectPayment(method),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.skyTint : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.navy : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: AppColors.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.title, style: inter(13, w700, AppColors.ink)),
                    const SizedBox(height: 2),
                    Text(method.subtitle, style: inter(12, w400, AppColors.muted)),
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.navy,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(AppIcons.check, size: 14, color: Colors.white),
                )
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                ),
            ],
          ),
        ),
      );
}
