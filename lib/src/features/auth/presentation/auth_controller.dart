import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_jv_staff/src/features/auth/domain/repositories/auth_repository.dart';
// Importamos la implementación para tener acceso al provider
import 'package:app_jv_staff/src/features/auth/data/repositories/auth_repository_impl.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Estado inicial vacío (null)
  }

  Future<void> login(String email, String password) async {
    // 1. Ponemos estado de carga
    state = const AsyncLoading();
    
    // 2. Obtenemos el repositorio
    final repository = ref.read(authRepositoryProvider);
    
    // 3. Ejecutamos login
    final result = await repository.login(email, password);
    
    // 4. Manejamos el resultado
    result.fold(
      (error) {
        // ERROR: Convertimos la excepción a texto para evitar error de tipos
        state = AsyncError(error.toString(), StackTrace.current);
      },
      (response) {
        // ÉXITO: Guardamos estado data
        state = const AsyncData(null);
      },
    );
  }
}
