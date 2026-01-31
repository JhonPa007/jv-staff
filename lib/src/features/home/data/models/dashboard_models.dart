import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_models.freezed.dart';
part 'dashboard_models.g.dart';

@freezed
class DashboardResponse {
  final String period;
  final String userName; // Agregado para el saludo "Hola, [Nombre]"
  final double totalProduction;
  final double totalCommissionPending;
  final double totalCommissionPaid;
  final double averageRating;
  final int appointmentsCompleted;
  final NextAppointment? nextAppointment;

  DashboardResponse({
    required this.period,
    required this.userName,
    required this.totalProduction,
    required this.totalCommissionPending,
    required this.totalCommissionPaid,
    required this.averageRating,
    required this.appointmentsCompleted,
    this.nextAppointment,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    // Extraemos el objeto 'metrics' para facilitar la lectura
    final metrics = json['metrics'] ?? {};

    return DashboardResponse(
      period: json['period'] ?? '',
      
      // 1. Mapeamos 'user_name' (Backend) a 'userName' (Flutter)
      userName: json['user_name'] ?? 'Usuario',

      // 2. Métricas Financieras
      totalProduction: (metrics['total_production'] ?? 0).toDouble(),
      totalCommissionPending: (metrics['total_commission_pending'] ?? 0).toDouble(),
      
      // Si el backend aún no envía pagadas, ponemos 0 para no romper la app
      totalCommissionPaid: (metrics['total_commission_paid'] ?? 0).toDouble(),

      // 3. CORRECCIÓN: El backend envía 'rating', no 'average_rating'
      averageRating: (metrics['rating'] ?? 0).toDouble(),

      // 4. CORRECCIÓN: El backend envía 'completed_services', no 'appointments_completed'
      appointmentsCompleted: (metrics['completed_services'] ?? 0).toInt(),

      // 5. Próxima Cita (puede ser null)
      nextAppointment: json['next_appointment'] != null
          ? NextAppointment.fromJson(json['next_appointment'])
          : null,
    );
  }
}

class NextAppointment {
  final String clientName;
  final String service;
  final String time;

  NextAppointment({
    required this.clientName,
    required this.service,
    required this.time,
  });

  factory NextAppointment.fromJson(Map<String, dynamic> json) {
    return NextAppointment(
      // 6. CORRECCIÓN: El backend envía 'client', no 'client_name'
      clientName: json['client'] ?? 'Cliente',
      service: json['service'] ?? 'Servicio',
      time: json['time'] ?? '--:--',
    );
  }
}
