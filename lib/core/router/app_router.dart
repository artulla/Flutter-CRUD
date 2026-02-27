import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/dio_client.dart';
import '../utils/logger_setup.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/customer/presentation/screens/customer_list_screen.dart';
import '../../features/customer/presentation/screens/customer_add_edit_screen.dart';
import '../../features/customer/domain/entities/customer.dart';

// Route path constants
class AppRoutes {
  static const String login        = '/login';
  static const String dashboard    = '/dashboard';
  static const String customers    = '/customers';
  static const String addCustomer  = '/customers/add';
  static const String editCustomer = '/customers/edit';
}

/// GoRouter provider — watches auth token for redirects
final routerProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(
    Provider((_) => const FlutterSecureStorage()),
  );

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final token = await storage.read(key: kTokenKey);
      final isLoggedIn = token != null && token.isNotEmpty;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;

      appLogger.d('[Router] path=${state.matchedLocation} loggedIn=$isLoggedIn');

      /* // todo Original code
      if (!isLoggedIn && !isLoginRoute) return AppRoutes.login;
      if (isLoggedIn && isLoginRoute) return AppRoutes.dashboard;*/

      // todo test code
     /* if (isLoggedIn && isLoginRoute) return AppRoutes.login;
      if (!isLoggedIn && !isLoginRoute) return AppRoutes.dashboard;*/
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (ctx, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (ctx, _) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.customers,
        name: 'customers',
        builder: (ctx, _) => const CustomerListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCustomer,
        name: 'addCustomer',
        builder: (ctx, _) => const CustomerAddEditScreen(),
      ),
      GoRoute(
        path: AppRoutes.editCustomer,
        name: 'editCustomer',
        builder: (ctx, state) {
          // Pass Customer object via extra
          final customer = state.extra as Customer;
          return CustomerAddEditScreen(customer: customer);
        },
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.error}')),
    ),
  );
});
