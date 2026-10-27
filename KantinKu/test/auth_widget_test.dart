import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kantinku/app/app.dart';
import 'package:kantinku/app/app_shell.dart';
import 'package:kantinku/core/services/app_store.dart';
import 'package:kantinku/core/services/local_store.dart';
import 'package:kantinku/features/auth/data/auth_repository.dart';
import 'package:kantinku/features/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('invalid login shows field validation and password visibility toggles', (tester) async {
    final store = AppStore(persistence: MemoryLocalStore(), authRepository: AuthRepository(iterations: 1000));
    await store.initialize();
    addTearDown(store.dispose);
    AppShell.selectedTab.value = 0;
    await tester.pumpWidget(KantinKuApp(store: store));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(HomeScreen))).pushNamed('/login');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('field-Email')), 'bukan-email');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
    expect(store.isLoggedIn, isFalse);
    await tester.tap(find.byTooltip('Tampilkan password'));
    await tester.pump();
    final password = tester.widget<TextFormField>(find.byKey(const ValueKey('field-Password')));
    // The editable child reflects the visibility control, not just its icon.
    final editable = tester.widget<EditableText>(find.descendant(
      of: find.byWidget(password), matching: find.byType(EditableText)));
    expect(editable.obscureText, isFalse);
  });
}
