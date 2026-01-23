import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_jv_staff/src/features/home/domain/repositories/dashboard_repository.dart';
import 'package:app_jv_staff/src/features/home/domain/models/dashboard_models.dart';
import 'package:app_jv_staff/src/features/home/data/repositories/dashboard_repository_impl.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  FutureOr<DashboardResponse> build() async {
    final repository = ref.read(dashboardRepositoryProvider);
    final result = await repository.getDashboardData();
    
    return result.fold(
      (error) => throw error, // Riverpod's AsyncValue handles exceptions
      (response) => response,
    );
  }

  Future<void> uploadEvidence(String filePath) async {
    final repository = ref.read(dashboardRepositoryProvider);
    // You might want to handle loading state here or in a separate controller
    // For simplicity, just calling the repository
    await repository.uploadEvidence(filePath);
  }
}
