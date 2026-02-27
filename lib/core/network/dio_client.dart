import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger_setup.dart';
import '../constants/app_strings.dart';

/// Storage key for JWT token
const String kTokenKey = 'auth_token';

/// Base URL — change to your actual API endpoint
const String kBaseUrl = 'https://your-api.example.com/api/v1';

class DioClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  DioClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },),
    );

    // Add interceptors in order
    dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }
}

// ─── Auth Interceptor ────────────────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  _AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: kTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// ─── Logging Interceptor ─────────────────────────────────────────────────────
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    appLogger.d('[DIO → ${options.method}] ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    appLogger.i('[DIO ← ${response.statusCode}] ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    appLogger.e('[DIO ERROR] ${err.message}', error: err);
    handler.next(err);
  }
}

// ─── Error Interceptor ───────────────────────────────────────────────────────
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Standardize error messages
    String message;
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = AppStrings.networkError;
    } else if (err.response?.statusCode == 401) {
      message = AppStrings.sessionExpired;
    } else {
      message = err.response?.data?['message'] ?? AppStrings.unknownError;
    }

    // Attach human-readable message to error
    handler.next(
      err.copyWith(
        message: message,
      ),
    );
  }
}
