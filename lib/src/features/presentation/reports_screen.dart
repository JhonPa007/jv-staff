import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// --- CONTROLADOR SIMPLE ---
class ReportsController extends StatefulWidget {
  const ReportsController({super.key});
  @override
  State<ReportsController> createState() => _ReportsControllerState();
}

class _ReportsControllerState extends State<ReportsController> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  
  List<dynamic> _sales = [];
  List<dynamic> _commissions = [];
  List<dynamic> _tips = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData(); // Cargar mes actual por defecto
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    // Fechas por defecto (Mes actual) o Selección
    final now = DateTime.now();
    final start = _selectedDateRange?.start ?? DateTime(now.year, now.month, 1);
    final end = _selectedDateRange?.end ?? DateTime(now.year, now.month + 1, 0);
    
    final fmt = DateFormat('yyyy-MM-dd');
    final query = "?start_date=${fmt.format(start)}&end_date=${fmt.format(end)}";
    final baseUrl = "https://celebrated-analysis-production.up.railway.app"; // TU URL

    try {
      // 1. VENTAS
      final resSales = await http.get(Uri.parse('$baseUrl/staff/reports/sales$query'), headers: {'Authorization': 'Bearer $token'});
      if (resSales.statusCode == 200) _sales = json.decode(resSales.body);

      // 2. COMISIONES
      final resComm = await http.get(Uri.parse('$baseUrl/staff/reports/financial?type=commissions&start_date=${fmt.format(start)}&end_date=${fmt.format(end)}'), headers: {'Authorization': 'Bearer $token'});
      if (resComm.statusCode == 200) _commissions = json.decode(resComm.body);

      // 3. PROPINAS
      final resTips = await http.get(Uri.parse('$baseUrl/staff/reports/financial?type=tips&start_date=${fmt.format(start)}&end_date=${fmt.format(end)}'), headers: {'Authorization': 'Bearer $token'});
      if (resTips.statusCode == 200) _tips = json.decode(resTips.body);

    } catch (e) {
      print("Error cargando reportes: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Color(0xFFD4AF37), onPrimary: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Reportes y Finanzas", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Ventas"),
            Tab(text: "Comisiones"),
            Tab(text: "Propinas"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDateRange,
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildSalesList(),
              _buildFinancialList(_commissions, true),
              _buildFinancialList(_tips, false),
            ],
          ),
    );
  }

  Widget _buildSalesList() {
    if (_sales.isEmpty) return _emptyState();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _sales.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10),
      itemBuilder: (ctx, i) {
        final item = _sales[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(item['item'] ?? 'Venta', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${item['date']} • ${item['client']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text("Ticket: ${item['receipt']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          trailing: Text("\$${item['price']}", style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildFinancialList(List<dynamic> data, bool isCommission) {
    if (data.isEmpty) return _emptyState();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10),
      itemBuilder: (ctx, i) {
        final item = data[i];
        final status = item['status'] ?? 'Pendiente';
        final isPaid = status == 'Pagado' || status == 'Aprobado'; // Ajusta según tu BD
        
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            isCommission ? Icons.percent : Icons.savings, 
            color: isPaid ? Colors.green : Colors.orange
          ),
          title: Text(item['concept'] ?? '', style: const TextStyle(color: Colors.white)),
          subtitle: Text(item['date'] ?? '', style: const TextStyle(color: Colors.grey)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("\$${item['amount']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(status, style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState() => const Center(child: Text("No hay datos en este periodo", style: TextStyle(color: Colors.grey)));
}