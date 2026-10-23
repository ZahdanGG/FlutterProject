import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_role_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/catalog/models/canteen.dart';
import '../features/catalog/models/food.dart';
import '../features/checkout/presentation/screens/checkout_screen.dart';
import '../features/checkout/presentation/screens/payment_method_screen.dart';
import '../features/checkout/presentation/screens/payment_screen.dart';
import '../features/checkout/presentation/screens/payment_status_screen.dart';
import '../features/checkout/presentation/screens/pickup_time_screen.dart';
import '../features/home/presentation/screens/menu_list_screen.dart';
import '../features/home/presentation/screens/menu_detail_screen.dart';
import '../features/order/models/kantin_order.dart';
import '../features/order/presentation/screens/order_screen.dart';
import '../features/order/presentation/screens/order_detail_screen.dart';
import '../features/order/presentation/screens/pickup_code_screen.dart';
import '../features/order/presentation/screens/receipt_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/settings/presentation/screens/preferences_screen.dart';
import '../features/settings/presentation/screens/security_screen.dart';
import '../features/settings/presentation/screens/help_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/privacy_screen.dart';
import 'app_shell.dart';
import 'foundation_screens.dart';

abstract final class AppRouter {
  static void goTab(BuildContext context, int index) {
    AppShell.selectedTab.value = index.clamp(0, 3).toInt();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final orderId = args is KantinOrder ? args.id : args is String ? args : '';
    final Widget page = switch (settings.name) {
      '/' => const AppShell(),
      '/menus' => MenuListScreen(initialQuery: args is String ? args : ''),
      '/menu' when args is Food => MenuDetailScreen(food: args),
      '/canteen' when args is Canteen => CanteenPreviewScreen(canteen: args),
      '/browse' => const FoundationBrowseScreen(),
      '/filter' => const FoundationFeatureScreen(title: 'Filter'),
      '/favorites' => const FoundationFeatureScreen(title: 'Favorit'),
      '/notifications' => const FoundationFeatureScreen(title: 'Notifikasi'),
      '/orders' => const OrderScreen(),
      '/order-detail' => OrderDetailScreen(orderId: orderId),
      '/receipt' => ReceiptScreen(orderId: orderId),
      '/pickup-code' => PickupCodeScreen(orderId: orderId),
      '/cart' => const CartScreen(),
      '/checkout' => const CheckoutScreen(),
      '/payment-method' => const PaymentMethodScreen(),
      '/wallet' => const WalletScreen(),
      '/pickup-time' => const PickupTimeScreen(),
      '/payment' => PaymentScreen(orderId: orderId),
      '/payment-status' => PaymentStatusScreen(orderId: orderId),
      '/login' => const LoginScreen(),
      '/register-role' => const RegisterRoleScreen(),
      '/register' => RegisterScreen(role: args is String ? args : 'Mahasiswa'),
      '/forgot-password' => const ForgotPasswordScreen(),
      '/edit-profile' => const EditProfileScreen(),
      '/security' => const SecurityScreen(),
      '/preferences' => const PreferencesScreen(),
      '/help' => HelpScreen(topic: args is String ? args : null),
      '/about' => const AboutScreen(),
      '/privacy' => const PrivacyScreen(),
      _ => const _MissingRouteScreen(),
    };
    return MaterialPageRoute<dynamic>(settings: settings, builder: (context) => page);
  }
}

class _MissingRouteScreen extends StatelessWidget {
  const _MissingRouteScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
    body: Center(child: FilledButton(onPressed: () => AppRouter.goTab(context, 0), child: const Text('Kembali ke Home'))),
  );
}
