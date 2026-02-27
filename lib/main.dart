import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger_setup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  appLogger.i('🚀 CustomerPro app starting...');
  runApp(
    // ProviderScope is the root widget for Riverpod DI
    const ProviderScope(
      child: CustomerApp(),
    ),
  );
}

class CustomerApp extends ConsumerWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CustomerPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
