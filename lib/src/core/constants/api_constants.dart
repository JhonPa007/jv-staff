class ApiConstants {
  // ---------------------------------------------------------------------------
  // CONFIGURACIÓN DE RED (CAMBIAR SEGÚN EL ENTORNO)
  // ---------------------------------------------------------------------------

  // OPCIÓN A: Para EMULADOR ANDROID (Usa esta ahora)
  // 10.0.2.2 es la IP especial que usa el emulador para ver tu PC.
  // Nota: Usamos 'http' (no https) y quitamos '/api/v1' porque localmente no lo tienes configurado así.
  //static const String baseUrl = 'http://10.0.2.2:8000';

 // OPCIÓN B: Para CHROME / WEB
 // static const String baseUrl = 'http://localhost:8000';

  // ✅ BIEN (Apunta al Backend Python)
static const String baseUrl = 'https://jv-staff-production.up.railway.app'; 
// (Asegúrate de pegar TU URL del servicio 'jv-staff', sin la barra al final si es posible)

  // ---------------------------------------------------------------------------
  // ENDPOINTS
  // ---------------------------------------------------------------------------

  // Auth
  static const String login = '/auth/login';

  // Dashboard
  static const String dashboard = '/staff/dashboard'; // Asegúrate de que en Python sea igual

  // Appointments
  static const String appointments = '/staff/appointments';
  
  // Media (Fotos)
  static const String uploadMedia = '/media/upload'; 
}