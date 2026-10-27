import 'package:flutter/material.dart';
import '../core/services/app_store.dart';
import 'app_router.dart';
import 'app_scope.dart';
import 'app_theme.dart';

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key, required this.store});
  final AppStore store;
  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  late Future<void> _ready;
  @override
  void initState() {
    super.initState();
    _ready = widget.store.initialize();
  }
  @override
  void dispose() {
    widget.store.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _ready,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
        return KantinKuApp(store: widget.store);
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Scaffold(body: SafeArea(child: Center(child: Padding(
          padding: const EdgeInsets.all(28),
          child: snapshot.hasError ? Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning_amber_rounded, size: 44),
            const SizedBox(height: 16),
            const Text('Data belum dapat dibuka', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text('Penyimpanan perangkat belum siap. Coba lagi untuk memuat akun dan pesananmu.', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => setState(() => _ready = widget.store.initialize()), child: const Text('Coba lagi')),
          ]) : const CircularProgressIndicator(),
        )))),
      );
    },
  );
}

class KantinKuApp extends StatelessWidget {
  const KantinKuApp({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => AppScope(
    store: store,
    child: AnimatedBuilder(
      animation: store,
      builder: (context, child) => MaterialApp(
        title: 'KantinKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: store.themeMode,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: '/',
        builder: (context, child) => ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: Column(children: [
            if (store.persistenceError != null) SafeArea(bottom: false, child: Material(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 8, 8), child: Row(children: [
                Expanded(child: Text(store.persistenceError!, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onErrorContainer))),
                TextButton(onPressed: store.busy ? null : () async {
                  try {
                    if (store.initializationFailed) {
                      await store.retryInitialization();
                    } else {
                      await store.retryPendingWrites();
                    }
                  } catch (_) { /* The persistent banner reports the failure. */ }
                }, child: const Text('Coba lagi')),
              ])),
            )),
            Expanded(child: child!),
          ]))),
        ),
      ),
    ),
  );
}
