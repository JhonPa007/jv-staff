import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_jv_staff/src/features/appointments/presentation/appointment_controller.dart';
import 'package:app_jv_staff/src/features/appointments/domain/models/appointment_model.dart';
import 'package:app_jv_staff/src/core/theme/app_theme.dart';

class AppointmentScreen extends ConsumerWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentState = ref.watch(appointmentControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Citas')),
      body: appointmentState.when(
        data: (appointments) {
          if (appointments.isEmpty) {
            return const Center(child: Text('No tienes citas programadas.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                color: AppTheme.surface,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: appointment.isVip ? AppTheme.primary : Colors.grey,
                    child: Icon(Icons.calendar_today, color: appointment.isVip ? Colors.black : Colors.white),
                  ),
                  title: Text(appointment.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.serviceName),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, hh:mm a').format(appointment.startTime),
                        style: TextStyle(color: AppTheme.primary.withOpacity(0.8)),
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(appointment.status, style: const TextStyle(fontSize: 10)),
                    backgroundColor: _getStatusColor(appointment.status),
                  ),
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.withOpacity(0.2);
      case 'completed':
        return Colors.blue.withOpacity(0.2);
      case 'cancelled':
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}
