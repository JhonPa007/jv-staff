import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_jv_staff/src/core/errors/exceptions.dart';
import 'package:app_jv_staff/src/core/network/dio_client.dart';
import 'package:app_jv_staff/src/features/home/domain/models/dashboard_models.dart';
import 'package:app_jv_staff/src/features/home/domain/repositories/dashboard_repository.dart';

part 'dashboard_repository_impl.g.dart';

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  return DashboardRepositoryImpl(dio: ref.read(dioClientProvider));
}

class DashboardRepositoryImpl implements DashboardRepository {
  final DioClient _dio;

  DashboardRepositoryImpl({required DioClient dio}) : _dio = dio;

  @override
  Future<Either<ServerException, DashboardResponse>> getDashboardData() async {
    try {
      final response = await _dio.get('/staff/dashboard');
      return Right(DashboardResponse.fromJson(response.data));
    } catch (e) {
      // CORRECCIÓN: Usamos el constructor posicional (sin 'message:')
      return Left(ServerException(e.toString()));
    }
  }

  @override
  Future<Either<ServerException, void>> uploadEvidence(String filePath) async {
    try {
      // TODO: Implement actual upload logic or use MediaRepository
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(ServerException(e.toString()));
    }
  }
}
