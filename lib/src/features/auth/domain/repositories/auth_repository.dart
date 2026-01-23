import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:app_jv_staff/src/features/auth/domain/models/login_response.dart';

abstract class AuthRepository {
  Future<Either<AuthException, LoginResponse>> login(String email, String password);
}
