import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jv_staff/src/core/theme/app_theme.dart';
import 'package:app_jv_staff/src/features/appointments/domain/models/appointment_model.dart';
// Adjusted import: referencing the repository implementation where the provider is defined
import 'package:app_jv_staff/src/features/appointments/data/repositories/appointment_repository_impl.dart';
// Importamos la pantalla de subida de medios
import 'package:app_jv_staff/src/features/media/presentation/upload_evidence_screen.dart';

class AppointmentDetailScreen extends ConsumerStatefulWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  ConsumerState<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends ConsumerState<AppointmentDetailScreen> {
  String? evidenceUrl;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    // Si la cita ya traía evidencia, la cargamos
    evidenceUrl = widget.appointment.evidenceUrl;
  }

  Future<void> _handleFinalize() async {
    if (evidenceUrl == null) return;

    setState(() => isUploading = true);

    try {
      // Llamamos al repositorio a través del provider
      final repository = ref.read(appointmentRepositoryProvider);
      
      // Llamamos al método real del repositorio
      await repository.finalizeAppointment(widget.appointment.id, evidenceUrl!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cita finalizada con éxito! Comisión generada.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volver atrás
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Detalle de Cita'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta del Cliente
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Gris oscuro
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 30, child: Icon(Icons.person)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.appointment.clientName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.appointment.isVip)
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37), // Dorado
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CLIENTE VIP',
                              style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Sección de Evidencia
            const Text(
              "EVIDENCIA DEL TRABAJO",
              style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5),
            ),
            const SizedBox(height: 10),
            
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadEvidenceScreen()),
                );

                if (result != null && result is String) {
                  setState(() {
                    evidenceUrl = result;
                  });
                }
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: evidenceUrl != null ? const Color(0xFFD4AF37) : Colors.grey,
                    width: 2,
                  ),
                  image: evidenceUrl != null
                      ? DecorationImage(
                          image: NetworkImage(evidenceUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: evidenceUrl == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.grey, size: 40),
                          SizedBox(height: 10),
                          Text("Tocar para subir foto", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 40),

            // Botón de Acción
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (evidenceUrl != null && !isUploading) ? _handleFinalize : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37), // Dorado
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey[800],
                ),
                child: isUploading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "FINALIZAR SERVICIO",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
