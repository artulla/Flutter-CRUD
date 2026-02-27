import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/customer.dart';
import '../viewmodels/customer_viewmodel.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() =>
      _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load customers on first build
    Future.microtask(
      () => ref.read(customerViewModelProvider.notifier).loadCustomers(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final vm = ref.read(customerViewModelProvider.notifier);
        final currentFilter = ref.read(customerViewModelProvider).filterStatus;
        return Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.filterByStatus,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSizes.md),
              _FilterChipRow(
                current: currentFilter,
                onSelect: (val) {
                  vm.setFilter(val);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    // Sync from remote then reload local DB
    try {
      await ref
          .read(customerRepositoryProvider)
          .syncFromRemote();
    } catch (_) {}
    await ref.read(customerViewModelProvider.notifier).loadCustomers();
  }

  void _onDelete(Customer customer) async {
    await ref
        .read(customerViewModelProvider.notifier)
        .deleteCustomer(customer.id!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.deleteConfirm),
        action: SnackBarAction(
          label: AppStrings.undoLabel,
          onPressed: () {
            // Re-add the deleted customer
            ref
                .read(customerViewModelProvider.notifier)
                .addCustomer(customer.copyWith(id: null));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerViewModelProvider);
    final customers = state.filteredCustomers;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.customers),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (state.filterStatus != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.md, 0, AppSizes.md, AppSizes.sm),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) =>
                  ref.read(customerViewModelProvider.notifier).setSearchQuery(val),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: AppStrings.search,
                hintStyle:
                    const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref
                              .read(customerViewModelProvider.notifier)
                              .setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(state, customers),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addCustomer),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addNew),
      ),
    );
  }

  Widget _buildBody(CustomerState state, List<Customer> customers) {
    if (state.status == CustomerStatus.loading && customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CustomerStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSizes.sm),
            Text(state.error ?? AppStrings.unknownError),
            const SizedBox(height: AppSizes.sm),
            ElevatedButton(
              onPressed: () =>
                  ref.read(customerViewModelProvider.notifier).loadCustomers(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline,
                size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: AppSizes.sm),
            Text(AppStrings.noCustomers,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.md, AppSizes.sm, AppSizes.md, 100),
        itemCount: customers.length,
        itemBuilder: (ctx, i) {
          final customer = customers[i];
          return _CustomerCard(
            customer: customer,
            onDelete: () => _onDelete(customer),
            onEdit: () =>
                context.push(AppRoutes.editCustomer, extra: customer),
          );
        },
      ),
    );
  }
}

// ─── Customer Card ────────────────────────────────────────────────────────────
class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _CustomerCard({
    required this.customer,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('customer_${customer.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: AppSizes.xs),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              customer.name[0].toUpperCase(),
              style: const TextStyle(
                  color: AppColors.textOnPrimary, fontWeight: FontWeight.w600),
            ),
          ),
          title: Text(customer.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.email,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              Text(customer.phone,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatusBadge(isActive: customer.isActive),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 20),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.activeGreen.withOpacity(0.15)
            : AppColors.inactiveGrey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? AppStrings.active : AppStrings.inactive,
        style: TextStyle(
          color: isActive ? AppColors.activeGreen : AppColors.inactiveGrey,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Filter Chip Row ──────────────────────────────────────────────────────────
class _FilterChipRow extends StatelessWidget {
  final String? current;
  final void Function(String?) onSelect;

  const _FilterChipRow({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = [
      (label: AppStrings.all, value: null as String?),
      (label: AppStrings.active, value: 'active'),
      (label: AppStrings.inactive, value: 'inactive'),
    ];

    return Wrap(
      spacing: AppSizes.sm,
      children: options
          .map(
            (o) => ChoiceChip(
              label: Text(o.label),
              selected: current == o.value,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: current == o.value
                    ? AppColors.textOnPrimary
                    : AppColors.textPrimary,
              ),
              onSelected: (_) => onSelect(o.value),
            ),
          )
          .toList(),
    );
  }
}
