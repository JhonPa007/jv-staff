import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORTA TU PANTALLA DE REPORTES AQUÍ
// Asegúrate de que la ruta sea correcta según donde guardaste el archivo anterior
import 'package:barber_staff/src/features/reports/presentation/reports_screen.dart';

import 'package:barber_staff/src/features/auth/presentation/login_screen.dart'; // Para el logout si es necesario

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  
  // Datos del Usuario
  String _userName = "Cargando...";
  String _period = "";
  
  // Métricas
  double _production = 0.0;
  double _commissionPending = 0.0;
  
  // Próxima Cita
  Map<String, dynamic>? _nextAppt;

  // URL de tu Backend (Railway)
  final String _baseUrl = "https://celebrated-analysis-production.up.railway.app";

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _logout();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/staff/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          _userName = data['user_name'] ?? "Colaborador";
          _period = data['period'] ?? "";
          
          final metrics = data['metrics'];
          _production = (metrics['total_production'] as num).toDouble();
          _commissionPending = (metrics['total_commission_pending'] as num).toDouble();
          
          _nextAppt = data['next_appointment'];
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        _logout();
      } else {
        setState(() => _isLoading = false);
        print("Error en dashboard: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error de conexión: $e");
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const LoginScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores del tema
    const  Color kGold = Color(0xFFD4AF37);
    const Color kDarkBg = Colors.black;
    const Color kCardBg = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        backgroundColor: kDarkBg,
        elevation: 0,
        title: const Text("Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: _logout,
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: kGold))
        : RefreshIndicator(
            color: kGold,
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SALUDO
                  Text(
                    "Hola, $_userName",
                    style: const TextStyle(color: kGold, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Bienvenido de nuevo",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  
                  const SizedBox(height: 25),

                  // 2. TÍTULO MÉTRICAS
                  Text(
                    "Mis Métricas ($_period)",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // 3. TARJETAS DE MÉTRICAS
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard("Producción", _production, kCardBg, kGold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard("Comisión Pendiente", _commissionPending, kCardBg, Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 4. NUEVO BOTÓN: VER REPORTES DETALLADOS
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => const ReportsScreen())
                        );
                      },
                      icon: const Icon(Icons.bar_chart, color: kGold),
                      label: const Text(
                        "VER REPORTES DETALLADOS",
                        style: TextStyle(color: kGold, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kGold, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 5. SECCIÓN PRÓXIMA CITA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Próxima Cita",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          // Aquí podrías llevar a una lista completa de citas
                        },
                        child: const Text("Ver Todo", style: TextStyle(color: kGold)),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 6. CARD DE CITA
                  _nextAppt == null 
                    ? _buildNoAppointment(kCardBg)
                    : _buildAppointmentCard(_nextAppt!, kCardBg, kGold),
                    
                  const SizedBox(height: 80), // Espacio para el FAB
                ],
              ),
            ),
          ),
      
      // BOTÓN FLOTANTE (SUBIR EVIDENCIA)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Acción para subir evidencia (cámara/galería)
          // Idealmente deberías pasar el ID de la cita seleccionada
        },
        backgroundColor: kGold,
        icon: const Icon(Icons.camera_alt, color: Colors.black),
        label: const Text("Subir Evidencia", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildMetricCard(String title, double amount, Color bg, Color amountColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.attach_money, color: Colors.grey, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            "\$${amount.toStringAsFixed(0)}", // Sin decimales para estética limpia
            style: TextStyle(color: amountColor, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAppointment(Color bg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          "No tienes citas próximas",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appt, Color bg, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Barra lateral de color
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          // Info Cita
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt['time'] ?? "--:--",
                  style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  appt['client'] ?? "Cliente",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  appt['service'] ?? "Servicio",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}