import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jv_staff/src/core/theme/app_theme.dart';
import 'package:app_jv_staff/src/features/home/presentation/dashboard_controller.dart';
// IMPORTS DE NAVEGACIÓN
import 'package:app_jv_staff/src/features/appointments/presentation/appointment_detail_screen.dart';
import 'package:app_jv_staff/src/features/appointments/domain/models/appointment_model.dart';
// IMPORT PARA SUBIR EVIDENCIA (Si lo usas directo aquí también)
import 'package:app_jv_staff/src/features/media/presentation/upload_evidence_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  
  void _navigateToAppointmentDetail() {
    // Simulamos el objeto de la cita (En el futuro esto vendrá del backend real)
    final appointment = AppointmentModel(
      id: 1,
      clientName: "Carlos Perez",
      serviceName: "Corte + Barba",
      startTime: DateTime.now().add(const Duration(hours: 1)),
      status: "confirmed",
      isVip: true,
      evidenceUrl: null, // Aún no tiene foto
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(appointment: appointment),
      ),
    );
  }

  void _handleUploadDirect() async {
     // Lógica para el botón flotante amarillo
     await Navigator.push(
       context, 
       MaterialPageRoute(builder: (_) => const UploadEvidenceScreen())
     );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el proveedor (aunque sea dummy por ahora para mantener la estructura)
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Quita la flecha de volver al login
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop(); // Salir (Volver al Login)
            },
          )
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        error: (err, stack) => Center(child: Text("Error: \$err", style: const TextStyle(color: Colors.red))),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo
              Text(
                "Hola, \${data.userName}",
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Bienvenido de nuevo",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),
  
              // Métricas
              Text("Mis Métricas (\${data.period})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildMetricCard("Producción", "\$\${data.totalProduction}", true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildMetricCard("Comisión Pendiente", "\$\${data.totalCommissionPending}", false)),
                ],
              ),
              const SizedBox(height: 30),
  
              // Próxima Cita (SECCIÓN INTERACTIVA)
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
  
              // TARJETA CLICKEABLE
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
      // Botón Flotante
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
