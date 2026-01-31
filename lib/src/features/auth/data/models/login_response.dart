import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
class LoginResponse {
  // ✅ Definimos explícitamente la variable que el repositorio está buscando
  final String accessToken;
  final String tokenType;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      // Mapeamos lo que envía el backend ('access_token') a nuestra variable ('accessToken')
      // El '??' es un seguro: si viene null, pone una cadena vacía para que no explote
      accessToken: json['access_token'] ?? json['token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }
}
