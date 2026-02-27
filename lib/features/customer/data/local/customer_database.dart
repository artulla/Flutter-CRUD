import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/customer.dart' as domain;

part 'customer_database.g.dart';


// dart run build_runner build // todo: run in cmd for code generation

// ─── Table Definition ────────────────────────────────────────────────────────
// @DataClassName renames Drift's auto-generated row class from 'Customer'
// to 'CustomerData', preventing the name clash with domain/entities/customer.dart
@DataClassName('CustomerData')
class Customers extends Table {
  IntColumn get id        => integer().autoIncrement()();
  TextColumn get name     => text().withLength(min: 1, max: 100)();
  TextColumn get email    => text().withLength(min: 1, max: 200)();
  TextColumn get phone    => text().withLength(min: 1, max: 20)();
  TextColumn get address  => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

// ─── DAO ─────────────────────────────────────────────────────────────────────
@DriftAccessor(tables: [Customers])
class CustomerDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerDaoMixin {
  CustomerDao(super.db);

  /// Get all customers ordered by name — returns Drift's CustomerData rows
  Future<List<CustomerData>> getAllCustomers() =>
      (select(customers)..orderBy([(c) => OrderingTerm.asc(c.name)])).get();

  /// Insert a new customer, returns the inserted row
  Future<CustomerData> insertCustomer(CustomersCompanion entry) async {
    final rowId = await into(customers).insert(entry);
    return (select(customers)..where((c) => c.id.equals(rowId))).getSingle();
  }

  /// Update a customer row
  Future<bool> updateCustomer(CustomerData customer) =>
      update(customers).replace(customer);

  /// Delete by id
  Future<int> deleteCustomerById(int id) =>
      (delete(customers)..where((c) => c.id.equals(id))).go();

  /// Bulk upsert — used for remote sync
  Future<void> upsertAll(List<CustomersCompanion> entries) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(customers, entries);
    });
  }
}

// ─── Database ────────────────────────────────────────────────────────────────
@DriftDatabase(tables: [Customers], daos: [CustomerDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'customer_app.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// ─── Mappers: CustomerData (Drift) ↔ domain.Customer ─────────────────────────

extension CustomerDataMapper on CustomerData {
  /// Drift row  →  domain entity
  domain.Customer toDomain() => domain.Customer(
        id: id,
        name: name,
        email: email,
        phone: phone,
        address: address,
        isActive: isActive,
        createdAt: createdAt,
      );
}

extension DomainCustomerMapper on domain.Customer {
  /// Domain entity  →  Drift companion (for insert / upsert)
  CustomersCompanion toCompanion() => CustomersCompanion(
        id: id != null ? Value(id!) : const Value.absent(),
        name: Value(name),
        email: Value(email),
        phone: Value(phone),
        address: Value(address),
        isActive: Value(isActive),
      );

  /// Domain entity  →  Drift data class (for update/replace)
  CustomerData toData() => CustomerData(
        id: id!,
        name: name,
        email: email,
        phone: phone,
        address: address,
        isActive: isActive,
        createdAt: createdAt ?? DateTime.now(),
      );
}
