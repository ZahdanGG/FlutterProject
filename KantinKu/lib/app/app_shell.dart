import 'package:flutter/material.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/order/presentation/screens/order_screen.dart';
import '../features/profile/presentation/screens/me_screen.dart';
import 'foundation_screens.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  static final selectedTab = ValueNotifier<int>(0);
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _pages = const [HomeScreen(), OrderScreen(), FoundationBrowseScreen(), MeScreen()];
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: AppShell.selectedTab,
    builder: (context, index, child) => PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) AppShell.selectedTab.value = 0;
      },
      child: Scaffold(
        body: SafeArea(bottom: false, child: IndexedStack(index: index, children: _pages)),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (value) => AppShell.selectedTab.value = value,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Order'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
          ],
        ),
      ),
    ),
  );
}
