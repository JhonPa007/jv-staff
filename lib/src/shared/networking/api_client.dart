import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/api_constants.dart';

part 'api_client.g.dart';

@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // TODO: Add token to headers if available
        // final token = ref.read(authProvider).token;
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        // print('Request[${options.method}] => ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // print('Response[${response.statusCode}] => ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // print('Error[${e.response?.statusCode}] => ${e.message}');
        return handler.next(e);
      },
    ),
  );

  return dio;
}
