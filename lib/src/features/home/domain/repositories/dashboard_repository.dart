import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:app_jv_staff/src/features/home/domain/models/dashboard_models.dart';

abstract class DashboardRepository {
  Future<Either<ServerException, DashboardResponse>> getDashboardData();
  Future<Either<ServerException, void>> uploadEvidence(String filePath);
}
