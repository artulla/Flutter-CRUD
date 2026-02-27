import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/dio_client.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';

import '../../features/customer/data/local/customer_database.dart';
import '../../features/customer/data/datasources/customer_remote_datasource.dart';
import '../../features/customer/data/repositories/customer_repository_impl.dart';
import '../../features/customer/domain/repositories/customer_repository.dart';
import '../../features/customer/domain/usecases/get_customers_usecase.dart';
import '../../features/customer/domain/usecases/add_customer_usecase.dart';
import '../../features/customer/domain/usecases/update_customer_usecase.dart';
import '../../features/customer/domain/usecases/delete_customer_usecase.dart';
import '../../features/customer/presentation/viewmodels/customer_viewmodel.dart';

// ─── Core ────────────────────────────────────────────────────────────────────

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final dioClientProvider = Provider<DioClient>(
  (ref) => DioClient(ref.watch(secureStorageProvider)),
);

// ─── Auth ────────────────────────────────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioClientProvider).dio),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageProvider),
  ),
);

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(
    ref.watch(loginUseCaseProvider),
    ref.watch(authRepositoryProvider),
  ),
);

// ─── Customer ────────────────────────────────────────────────────────────────

final customerDatabaseProvider = Provider<AppDatabase>(
  (_) => AppDatabase(),
);

final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>(
  (ref) => CustomerRemoteDataSource(ref.watch(dioClientProvider).dio),
);

final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => CustomerRepositoryImpl(
    ref.watch(customerRemoteDataSourceProvider),
    ref.watch(customerDatabaseProvider),
  ),
);

final getCustomersUseCaseProvider = Provider<GetCustomersUseCase>(
  (ref) => GetCustomersUseCase(ref.watch(customerRepositoryProvider)),
);

final addCustomerUseCaseProvider = Provider<AddCustomerUseCase>(
  (ref) => AddCustomerUseCase(ref.watch(customerRepositoryProvider)),
);

final updateCustomerUseCaseProvider = Provider<UpdateCustomerUseCase>(
  (ref) => UpdateCustomerUseCase(ref.watch(customerRepositoryProvider)),
);

final deleteCustomerUseCaseProvider = Provider<DeleteCustomerUseCase>(
  (ref) => DeleteCustomerUseCase(ref.watch(customerRepositoryProvider)),
);

final customerViewModelProvider =
    StateNotifierProvider<CustomerViewModel, CustomerState>(
  (ref) => CustomerViewModel(
    ref.watch(getCustomersUseCaseProvider),
    ref.watch(addCustomerUseCaseProvider),
    ref.watch(updateCustomerUseCaseProvider),
    ref.watch(deleteCustomerUseCaseProvider),
  ),
);
