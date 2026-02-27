import 'package:dio/dio.dart';
import '../../domain/entities/customer.dart';

class CustomerRemoteDataSource {
  final Dio _dio;
  CustomerRemoteDataSource(this._dio);

  Future<List<Customer>> fetchAll() async {
    final response = await _dio.get('/customers');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Customer> create(Customer customer) async {
    final response = await _dio.post('/customers', data: customer.toJson());
    return Customer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Customer> update(Customer customer) async {
    final response = await _dio.put(
      '/customers/${customer.id}',
      data: customer.toJson(),
    );
    return Customer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/customers/$id');
  }
}
