class DashboardResponse {
  final String period;
  // ✅ ESTA ES LA VARIABLE QUE FALTABA:
  final String userName; 
  final double totalProduction;
  final double totalCommissionPending;
  final double totalCommissionPaid;
  final double averageRating;
  final int appointmentsCompleted;
  final NextAppointment? nextAppointment;

  DashboardResponse({
    required this.period,
    required this.userName, // Requerido
    required this.totalProduction,
    required this.totalCommissionPending,
    required this.totalCommissionPaid,
    required this.averageRating,
    required this.appointmentsCompleted,
    this.nextAppointment,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] ?? {};

    return DashboardResponse(
      period: json['period'] ?? '',
      // ✅ MAPEAMOS EL NOMBRE AQUÍ:
      userName: json['user_name'] ?? 'Usuario', 
      
      totalProduction: (metrics['total_production'] ?? 0).toDouble(),
      totalCommissionPending: (metrics['total_commission_pending'] ?? 0).toDouble(),
      totalCommissionPaid: (metrics['total_commission_paid'] ?? 0).toDouble(),
      averageRating: (metrics['rating'] ?? 0).toDouble(),
      appointmentsCompleted: (metrics['completed_services'] ?? 0).toInt(),
      
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
      clientName: json['client'] ?? 'Cliente',
      service: json['service'] ?? 'Servicio',
      time: json['time'] ?? '--:--',
    );
  }
}