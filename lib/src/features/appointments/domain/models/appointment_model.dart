class AppointmentModel {
  final int id;
  final String clientName;
  final String serviceName;
  final DateTime startTime;
  final String status;
  final bool isVip;
  final String? evidenceUrl;

  AppointmentModel({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.startTime,
    required this.status,
    required this.isVip,
    this.evidenceUrl,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? 0,
      clientName: json['client_name'] ?? 'Cliente',
      serviceName: (json['service_list'] as List?)?.first ?? 'Servicio',
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'pending',
      isVip: json['is_vip'] ?? false,
      evidenceUrl: json['evidence_url'],
    );
  }
}
