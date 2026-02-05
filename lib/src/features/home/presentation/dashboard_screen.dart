import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Asegúrate de que tus imports de tema y otros archivos sigan aquí
import 'package:app_jv_staff/src/features/home/presentation/dashboard_controller.dart';
// Ajusta estos imports según la ubicación real en tu proyecto
import 'package:app_jv_staff/src/features/appointments/presentation/appointment_detail_screen.dart';
import 'package:app_jv_staff/src/features/appointments/domain/models/appointment_model.dart';
import 'package:app_jv_staff/src/features/media/presentation/upload_evidence_screen.dart';
import 'package:app_jv_staff/src/features/reports/presentation/reports_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  
  void _navigateToAppointmentDetail() {
    // Simulamos cita por ahora (puedes conectarlo a data.nextAppointment después)
    final appointment = AppointmentModel(
      id: 1,
      clientName: "Cliente Actual",
      serviceName: "Servicio",
      startTime: DateTime.now(),
      status: "confirmed",
      isVip: false,
      evidenceUrl: null,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(appointment: appointment),
      ),
    );
  }

  void _handleUploadDirect() async {
      await Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => const UploadEvidenceScreen())
      );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Aquí podrías agregar lógica de logout real
              Navigator.of(context).pop(); 
            },
          )
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SALUDO CORREGIDO (Sin la barra invertida)
              Text(
                "Hola, ${data.userName}", 
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Bienvenido de nuevo",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),

              // 2. TÍTULO MÉTRICAS CORREGIDO
              Text("Mis Métricas (${data.period})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              // 3. TARJETAS DE DINERO CORREGIDAS
              Row(
                children: [
                  Expanded(child: _buildMetricCard("Producción", "\$${data.totalProduction}", true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildMetricCard("Comisión Pendiente", "\$${data.totalCommissionPending}", false)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportsScreen()),
                    );
                  },
                  icon: const Icon(Icons.bar_chart, color: Color(0xFFD4AF37)),
                  label: const Text('VER REPORTES DETALLADOS',
                      style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // PRÓXIMA CITA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Próxima Cita", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {}, 
                    child: const Text("Ver Todo", style: TextStyle(color: Color(0xFFD4AF37)))
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (data.nextAppointment != null)
                GestureDetector(
                  onTap: _navigateToAppointmentDetail, 
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 4. DATOS CITA CORREGIDOS
                              Text(
                                data.nextAppointment!.time,
                                style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.nextAppointment!.clientName,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                data.nextAppointment!.service,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(20),
                   decoration: BoxDecoration(
                     color: const Color(0xFF1E1E1E),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: Colors.white10),
                   ),
                  child: const Center(
                    child: Text("No tienes citas próximas", style: TextStyle(color: Colors.grey)),
                  )
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleUploadDirect,
        backgroundColor: const Color(0xFFD4AF37),
        icon: const Icon(Icons.camera_alt, color: Colors.black),
        label: const Text("Subir Evidencia", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.attach_money, color: isPrimary ? const Color(0xFFD4AF37) : Colors.grey),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: isPrimary ? const Color(0xFFD4AF37) : Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}