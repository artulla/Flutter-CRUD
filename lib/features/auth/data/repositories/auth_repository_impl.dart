import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _remote.login(email: email, password: password);
    // Save JWT securely
    await _storage.write(key: kTokenKey, value: response.token);
    return response.token;
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: kTokenKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: kTokenKey);
    return token != null && token.isNotEmpty;
  }
}
