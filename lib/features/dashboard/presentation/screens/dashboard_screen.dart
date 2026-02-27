import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../customer/presentation/viewmodels/customer_viewmodel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerState = ref.watch(customerViewModelProvider);

    // Load customers if needed
    if (customerState.status == CustomerStatus.initial) {
      Future.microtask(
        () => ref.read(customerViewModelProvider.notifier).loadCustomers(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: () async {
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async =>
            ref.read(customerViewModelProvider.notifier).loadCustomers(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.sm),

              // ── Welcome banner ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF025C3D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back 👋',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: AppColors.textOnPrimary
                                        .withOpacity(0.85)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.dashboard,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.dashboard_rounded,
                        color: AppColors.textOnPrimary, size: 40),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // ── Summary Cards ──────────────────────────────────────
              Text('Overview',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: AppStrings.totalCustomers,
                      value: '${customerState.totalCount}',
                      icon: Icons.people_alt_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _SummaryCard(
                      title: AppStrings.activeCustomers,
                      value: '${customerState.activeCount}',
                      icon: Icons.check_circle_outline,
                      color: AppColors.activeGreen,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _SummaryCard(
                      title: AppStrings.inactiveCustomers,
                      value: '${customerState.inactiveCount}',
                      icon: Icons.cancel_outlined,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // ── Quick Actions ──────────────────────────────────────
              Text('Quick Actions',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.sm),
              _QuickActionTile(
                icon: Icons.list_alt_rounded,
                title: AppStrings.viewAll,
                subtitle: 'Browse, search and manage customers',
                color: AppColors.primary,
                onTap: () => context.push(AppRoutes.customers),
              ),
              const SizedBox(height: AppSizes.sm),
              _QuickActionTile(
                icon: Icons.person_add_alt_1_rounded,
                title: AppStrings.addNew,
                subtitle: 'Create a new customer profile',
                color: AppColors.secondary,
                onTap: () => context.push(AppRoutes.addCustomer),
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Action Tile ────────────────────────────────────────────────────────
class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios,
            color: color, size: AppSizes.iconSm),
      ),
    );
  }
}
