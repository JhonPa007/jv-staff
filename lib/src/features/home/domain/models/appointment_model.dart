class AppointmentModel {
  final int id;
  final String clientName;
  final String serviceName; // Simplificado para el ejemplo
  final DateTime time;
  final bool isVip;
  final String? evidenceUrl;

  AppointmentModel({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.time,
    required this.isVip,
    this.evidenceUrl,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? 0,
      clientName: json['client_name'] ?? 'Cliente',
      serviceName: (json['service_list'] as List?)?.first ?? 'Servicio',
      time: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      isVip: json['is_vip'] ?? false,
      evidenceUrl: json['evidence_url'], // Nullable
    );
  }
}