import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
class LoginResponse {
  final String accessToken;
  final String tokenType;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
  });

  // Constructor para crear el objeto desde el JSON del Backend
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      // ✅ AQUÍ ESTÁ LA CLAVE: 
      // Si el backend envía 'access_token', lo guardamos en 'accessToken'
      accessToken: json['access_token'] ?? json['token'] ?? '', 
      tokenType: json['token_type'] ?? 'bearer',
    );
  }
}
