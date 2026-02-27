import 'package:dio/dio.dart';
import '../models/login_response_model.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSource(this._dio);

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
