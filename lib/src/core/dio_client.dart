import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Asegúrate de que esta ruta sea correcta según tu proyecto:
import '../../core/constants/api_constants.dart'; 

part 'dio_client.g.dart';

@riverpod
Dio dioClient(DioClientRef ref) {
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
      onRequest: (options, handler) async {
        // Obtenemos la instancia de preferencias
        final prefs = await SharedPreferences.getInstance();
        
        // Intentamos leer el token
        final token = prefs.getString('auth_token');
        
        // --- LOGS DE DEPURACIÓN (Míralos en la consola) ---
        print("🔍 INTERCEPTOR: URL -> ${options.path}");
        print("🔍 INTERCEPTOR: Token encontrado -> $token");
        // --------------------------------------------------

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print("✅ INTERCEPTOR: Token adjuntado exitosamente");
        } else {
          print("⚠️ INTERCEPTOR: No hay token, se envía petición sin Auth");
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) {
        print("❌ ERROR DIO: ${e.response?.statusCode} - ${e.message}");
        return handler.next(e);
      },
    ),
  );

  return dio;
}