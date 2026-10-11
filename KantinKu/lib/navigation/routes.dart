import 'package:flutter/material.dart';

import '../core/tokens.dart';
import '../screens/beranda_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/order_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/semua_menu_screen.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';
import '../core/icons.dart';

/// One entry per frame in the Figma file (16 frames).
enum AppScreen {
  beranda('Beranda'),
  semuaMenu('Semua Menu'),
  detailPromo('Detail Promo'),
  riwayat('Riwayat'),
  rekomendasi('Rekomendasi'),
  order('Order — Pesanan'),
  checkout('Checkout'),
  payment('Payment — Pembayaran'),
  qris('QRIS Payment'),
  orderStatus('Order Status — Pesanan'),
  browse('Browse — Direktori Warung'),
  warungDetail('Warung Detail — Menu'),
  me('Me — Profil'),
  profilSaya('Profil Saya'),
  metodePembayaran('Metode Pembayaran'),
  voucherSaya('Voucher Saya');

  const AppScreen(this.frameName);
  final String frameName;

  Widget build() {
    switch (this) {
      case AppScreen.beranda:
        return const BerandaScreen();
      case AppScreen.semuaMenu:
        return const SemuaMenuScreen();
      case AppScreen.order:
        return const OrderScreen();
      case AppScreen.checkout:
        return const CheckoutScreen();
      case AppScreen.payment:
        return const PaymentScreen();
      default:
        return PendingScreen(frameName: frameName);
    }
  }
}

class Nav {
  static Route<void> _instant(Widget w) => PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => w,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );

  /// Forward navigation (prototype "navigate to").
  static void push(BuildContext context, AppScreen screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen.build()));
  }

  /// Bottom-navigation switch: replaces the whole stack with the tab's screen.
  static void tab(BuildContext context, NavTab tab) {
    final screen = switch (tab) {
      NavTab.home => AppScreen.beranda,
      NavTab.orders => AppScreen.order,
      NavTab.browse => AppScreen.browse,
      NavTab.me => AppScreen.me,
    };
    Navigator.of(context).pushAndRemoveUntil(_instant(screen.build()), (_) => false);
  }

  static void back(BuildContext context, {AppScreen fallback = AppScreen.beranda}) {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacement(_instant(fallback.build()));
    }
  }
}

/// Shown for Figma frames whose design data has not been read yet.
/// Deliberately blank apart from the frame name - nothing is invented.
class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key, required this.frameName});
  final String frameName;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              PageHeader(
                title: frameName,
                leading: RoundIconButton(
                  icon: AppIcons.chevronLeft,
                  iconSize: 18,
                  onTap: () => Nav.back(context),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Frame "$frameName" belum diimplementasikan.\nData Figma-nya belum terbaca.',
                      textAlign: TextAlign.center,
                      style: inter(13, w400, AppColors.muted, height: 1.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
