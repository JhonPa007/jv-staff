class ApiConstants {
  // ---------------------------------------------------------------------------
  // CONFIGURACIÓN DE RED
  // ---------------------------------------------------------------------------
  
  // URL del Backend en Railway (Producción)
  // NOTA: No lleva barra '/' al final.
  static const String baseUrl = 'https://jv-staff-production.up.railway.app';

  // ---------------------------------------------------------------------------
  // ENDPOINTS
  // ---------------------------------------------------------------------------

  // Auth
  static const String login = '/auth/login';

  // Dashboard
  static const String dashboard = '/staff/dashboard'; 

  // Appointments
  static const String appointments = '/staff/appointments';
  
  // Media (Fotos)
  static const String uploadMedia = '/media/upload'; 
}