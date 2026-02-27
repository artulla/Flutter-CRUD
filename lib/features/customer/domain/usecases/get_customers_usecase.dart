import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository _repo;
  GetCustomersUseCase(this._repo);
  Future<List<Customer>> call() => _repo.getCustomers();
}

class AddCustomerUseCase {
  final CustomerRepository _repo;
  AddCustomerUseCase(this._repo);
  Future<Customer> call(Customer customer) => _repo.addCustomer(customer);
}

class UpdateCustomerUseCase {
  final CustomerRepository _repo;
  UpdateCustomerUseCase(this._repo);
  Future<Customer> call(Customer customer) => _repo.updateCustomer(customer);
}

class DeleteCustomerUseCase {
  final CustomerRepository _repo;
  DeleteCustomerUseCase(this._repo);
  Future<void> call(int id) => _repo.deleteCustomer(id);
}

class SyncCustomersUseCase {
  final CustomerRepository _repo;
  SyncCustomersUseCase(this._repo);
  Future<void> call() => _repo.syncFromRemote();
}
