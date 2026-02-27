import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';
import '../local/customer_database.dart';
import '../../../../core/utils/logger_setup.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource _remote;
  final AppDatabase _db;

  CustomerRepositoryImpl(this._remote, this._db);

  @override
  Future<List<Customer>> getCustomers() async {
    // Local DB is the single source of truth
    final rows = await _db.customerDao.getAllCustomers();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Customer> addCustomer(Customer customer) async {
    // POST to API first, then persist locally
    // final created = await _remote.create(customer);
    await _db.customerDao.insertCustomer(customer.toCompanion());
    appLogger.i('[Repo] Customer added: ${customer.name}');
    return customer;
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    // PUT to API, then update local row using toData() mapper
    // final updated = await _remote.update(customer);
    await _db.customerDao.updateCustomer(customer.toData());
    appLogger.i('[Repo] Customer updated: ${customer.name}');
    return customer;
  }

  @override
  Future<void> deleteCustomer(int id) async {
    // await _remote.delete(id);
    await _db.customerDao.deleteCustomerById(id);
    appLogger.i('[Repo] Customer deleted: $id');
  }

  @override
  Future<void> syncFromRemote() async {
    final remoteList = await _remote.fetchAll();
    final companions = remoteList.map((c) => c.toCompanion()).toList();
    await _db.customerDao.upsertAll(companions);
    appLogger.i('[Repo] Synced ${remoteList.length} customers from API');
  }
}
