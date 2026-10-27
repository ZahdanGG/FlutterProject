import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kantinku/app/app.dart';
import 'package:kantinku/app/app_shell.dart';
import 'package:kantinku/core/services/app_store.dart';
import 'package:kantinku/core/services/local_store.dart';
import 'package:kantinku/features/home/presentation/screens/home_screen.dart';

void main() {
  for (final size in const [Size(320, 640), Size(412, 917), Size(480, 960)]) {
    testWidgets('main tabs and home scroll fit ${size.width}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = AppStore(persistence: MemoryLocalStore());
      await store.initialize();
      addTearDown(store.dispose);
      AppShell.selectedTab.value = 0;
      await tester.pumpWidget(KantinKuApp(store: store));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.drag(find.byKey(const PageStorageKey('home_scroll')), const Offset(0, -450));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final label in ['Order', 'Browse', 'Me', 'Home']) {
        await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text(label)).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Overflow or exception on $label');
      }
    });
  }

  testWidgets('guest ordering opens login gate and dismissal preserves detail', (tester) async {
    final store = AppStore(persistence: MemoryLocalStore());
    await store.initialize();
    addTearDown(store.dispose);
    AppShell.selectedTab.value = 0;
    await tester.pumpWidget(KantinKuApp(store: store));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(HomeScreen));
    Navigator.of(context).pushNamed('/menu', arguments: store.foodById('geprek'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah ke keranjang'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk dulu untuk memesan'), findsOneWidget);
    await tester.tap(find.text('Lanjut melihat'));
    await tester.pumpAndSettle();
    expect(store.cartCount, 0);
    expect(find.text('Tambah ke keranjang'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
