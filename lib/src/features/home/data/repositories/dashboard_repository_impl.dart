import 'package:dio/dio.dart'; // Usamos Dio directamente
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/exceptions.dart';
// Asegúrate de que este import apunte a donde tienes tu provider 'dioClientProvider'
import 'package:app_jv_staff/src/core/dio_client.dart'; 
import '../../domain/models/dashboard_models.dart';
import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_repository_impl.g.dart';

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  // Inyectamos la instancia de Dio configurada
  return DashboardRepositoryImpl(dio: ref.watch(dioClientProvider));
}

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<ServerException, DashboardResponse>> getDashboardData() async {
    try {
      // Petición a la API
      final response = await _dio.get('/staff/dashboard');
      
      // Si llegamos aquí, es un éxito (200 OK)
      return Right(DashboardResponse.fromJson(response.data));
    } on DioException catch (e) {
      // Manejo de errores de red o servidor
      return Left(ServerException(e.message ?? 'Error de conexión'));
    } catch (e) {
      // Otros errores
      return Left(ServerException(e.toString()));
    }
  }

  @override
  Future<Either<ServerException, void>> uploadEvidence(String filePath) async {
    try {
      // Simulamos subida por ahora
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(ServerException(e.toString()));
    }
  }
}