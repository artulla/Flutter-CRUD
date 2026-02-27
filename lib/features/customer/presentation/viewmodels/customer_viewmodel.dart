import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../../../core/utils/logger_setup.dart';

// ─── State ───────────────────────────────────────────────────────────────────
enum CustomerStatus { initial, loading, success, error }

class CustomerState {
  final CustomerStatus status;
  final List<Customer> customers;
  final String? error;

  /// Filter params
  final String searchQuery;
  final String? filterStatus; // 'active' | 'inactive' | null = all

  const CustomerState({
    this.status = CustomerStatus.initial,
    this.customers = const [],
    this.error,
    this.searchQuery = '',
    this.filterStatus,
  });

  /// Derived filtered list — computed property
  List<Customer> get filteredCustomers {
    var list = customers;

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.email.toLowerCase().contains(q))
          .toList();
    }

    if (filterStatus == 'active') {
      list = list.where((c) => c.isActive).toList();
    } else if (filterStatus == 'inactive') {
      list = list.where((c) => !c.isActive).toList();
    }

    return list;
  }

  int get totalCount    => customers.length;
  int get activeCount   => customers.where((c) => c.isActive).length;
  int get inactiveCount => customers.where((c) => !c.isActive).length;

  CustomerState copyWith({
    CustomerStatus? status,
    List<Customer>? customers,
    String? error,
    String? searchQuery,
    String? filterStatus,
    bool clearFilter = false,
    bool clearError = false,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      error: clearError ? null : error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: clearFilter ? null : filterStatus ?? this.filterStatus,
    );
  }
}

// ─── ViewModel ───────────────────────────────────────────────────────────────
class CustomerViewModel extends StateNotifier<CustomerState> {
  final GetCustomersUseCase _getCustomers;
  final AddCustomerUseCase _addCustomer;
  final UpdateCustomerUseCase _updateCustomer;
  final DeleteCustomerUseCase _deleteCustomer;

  CustomerViewModel(
    this._getCustomers,
    this._addCustomer,
    this._updateCustomer,
    this._deleteCustomer,
  ) : super(const CustomerState());

  Future<void> loadCustomers() async {
    state = state.copyWith(status: CustomerStatus.loading, clearError: true);
    try {
      final list = await _getCustomers();
      state = state.copyWith(status: CustomerStatus.success, customers: list);
    } catch (e) {
      state = state.copyWith(
          status: CustomerStatus.error, error: e.toString());
      appLogger.e('[Customer] Load failed: $e');
    }
  }

  Future<bool> addCustomer(Customer customer) async {
    try {
      state = state.copyWith(status: CustomerStatus.loading);
      final created = await _addCustomer(customer);
      state = state.copyWith(
        status: CustomerStatus.success,
        customers: [...state.customers, created],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
          status: CustomerStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      state = state.copyWith(status: CustomerStatus.loading);
      final updated = await _updateCustomer(customer);
      final list = state.customers
          .map((c) => c.id == updated.id ? updated : c)
          .toList();
      state = state.copyWith(
          status: CustomerStatus.success, customers: list);
      return true;
    } catch (e) {
      state = state.copyWith(
          status: CustomerStatus.error, error: e.toString());
      return false;
    }
  }

  Future<void> deleteCustomer(int id) async {
    await _deleteCustomer(id);
    final list = state.customers.where((c) => c.id != id).toList();
    state = state.copyWith(customers: list);
  }

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void setFilter(String? status) =>
      state = state.copyWith(filterStatus: status);

  void clearFilter() => state = state.copyWith(clearFilter: true);
}
