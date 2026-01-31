import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// 1. IMPORTANTE: Agregamos esta librería para poder guardar datos en el celular
import 'package:shared_preferences/shared_preferences.dart'; 

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:app_jv_staff/src/core/dio_client.dart';
import 'package:app_jv_staff/src/features/auth/domain/models/login_response.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(ref.watch(dioClientProvider));
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<Either<AuthException, LoginResponse>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,    // Nota: FastAPI estándar suele pedir 'username', pero si te da 200 OK, déjalo así.
          'password': password,
        },
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // -----------------------------------------------------------------------
      // 2. EL ESLABÓN PERDIDO: GUARDAR EL TOKEN
      // -----------------------------------------------------------------------
      final prefs = await SharedPreferences.getInstance();
      
      // Usamos la misma llave 'auth_token' que configuraste en dio_client.dart
      // Asumo que tu modelo LoginResponse tiene una propiedad .accessToken
      // Si tu modelo la llama distinto (ej: .token), cambia .accessToken por ese nombre.
      await prefs.setString('auth_token', loginResponse.accessToken);

      print("💾 AUTH REPO: Token guardado exitosamente en SharedPreferences");
      // -----------------------------------------------------------------------

      return right(loginResponse);
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle specific server errors here
        return left(AuthException(e.response?.data['message'] ?? 'Login failed'));
      }
      return left(AuthException('Network error or server unreachable'));
    } catch (e) {
      return left(AuthException(e.toString()));
    }
  }
}