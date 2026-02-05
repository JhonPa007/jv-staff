import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  
  // Listas de Datos
  List<dynamic> _sales = [];
  List<dynamic> _commissions = [];
  List<dynamic> _tips = [];

  // Totales
  double _totalSales = 0.0;
  double _totalCommissions = 0.0;
  double _totalTips = 0.0;

  // URL del Backend
  final String baseUrl = "https://celebrated-analysis-production.up.railway.app"; 

  // Colores del Tema
  final Color kGold = const Color(0xFFD4AF37);
  final Color kDarkBg = Colors.black;
  final Color kCardBg = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Configurar fecha inicial: Mes Actual (del 1 al último día)
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0) // El día 0 del mes siguiente es el último del actual
    );
    
    _loadAllData();
  }

  // Carga todos los datos del Backend
  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final fmt = DateFormat('yyyy-MM-dd');
    final start = fmt.format(_selectedDateRange!.start);
    final end = fmt.format(_selectedDateRange!.end);
    
    // Query params comunes
    final dateQuery = "start_date=$start&end_date=$end";
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    try {
      // 1. VENTAS
      // Endpoint: /staff/reports/sales?start_date=...&end_date=...
      final resSales = await http.get(Uri.parse('$baseUrl/staff/reports/sales?$dateQuery'), headers: headers);
      if (resSales.statusCode == 200) {
        final List<dynamic> data = json.decode(resSales.body);
        setState(() {
          _sales = data;
          // Asumimos que la respuesta trae un campo 'price' o 'total'
          _totalSales = data.fold(0.0, (sum, item) => sum + (double.tryParse(item['price'].toString()) ?? 0.0));
        });
      } else {
        print("Ventas Error: ${resSales.statusCode} - ${resSales.body}");
      }

      // 2. COMISIONES
      // Endpoint: /staff/reports/financial?type=commissions&start_date=...&end_date=...
      final resComm = await http.get(Uri.parse('$baseUrl/staff/reports/financial?type=commissions&$dateQuery'), headers: headers);
      if (resComm.statusCode == 200) {
        final List<dynamic> data = json.decode(resComm.body);
        setState(() {
          _commissions = data;
          _totalCommissions = data.fold(0.0, (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0.0));
        });
      }

      // 3. PROPINAS
      // Endpoint: /staff/reports/financial?type=tips&start_date=...&end_date=...
      final resTips = await http.get(Uri.parse('$baseUrl/staff/reports/financial?type=tips&$dateQuery'), headers: headers);
      if (resTips.statusCode == 200) {
        final List<dynamic> data = json.decode(resTips.body);
        setState(() {
          _tips = data;
          _totalTips = data.fold(0.0, (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0.0));
        });
      }

    } catch (e) {
      print("Error cargando reportes: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Selector de Fechas
  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: kGold, 
              onPrimary: Colors.black, 
              surface: kCardBg
            ),
            scaffoldBackgroundColor: kDarkBg,
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: kCardBg,
              backgroundColor: kDarkBg,
              headerForegroundColor: Colors.white,
              dayForegroundColor: MaterialStateProperty.all(Colors.white),
            )
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _loadAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(
        title: const Text("Reportes Detallados", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kDarkBg,
        iconTheme: IconThemeData(color: kGold),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            color: kGold,
            onPressed: _pickDateRange,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kGold,
          labelColor: kGold,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Ventas"),
            Tab(text: "Comisiones"),
            Tab(text: "Propinas"),
          ],
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: kGold))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildList(_sales, _totalSales, isSale: true),
              _buildList(_commissions, _totalCommissions, isSale: false),
              _buildList(_tips, _totalTips, isSale: false),
            ],
          ),
    );
  }

  // Constructor de Listas
  Widget _buildList(List<dynamic> data, double total, {required bool isSale}) {
    // Si no hay datos
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off, color: Colors.grey.withOpacity(0.5), size: 60),
            const SizedBox(height: 10),
            const Text("Sin movimientos en este periodo", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Cabecera de Totales
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          color: kCardBg,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TOTAL PERIODO (${DateFormat('MMM').format(_selectedDateRange!.start).toUpperCase()})", 
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)
              ),
              Text(
                "\$${total.toStringAsFixed(2)}", 
                style: TextStyle(color: kGold, fontSize: 22, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),
        
        // Lista de Items
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.1)),
            itemBuilder: (ctx, i) {
              final item = data[i];
              return isSale ? _saleTile(item) : _financeTile(item);
            },
          ),
        ),
      ],
    );
  }

  // Diseño de Fila para VENTAS
  Widget _saleTile(dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              (item['type'] == 'Product' || item['type'] == 'producto') ? Icons.shopping_bag : Icons.content_cut, 
              color: Colors.white, size: 20
            ),
          ),
          const SizedBox(width: 12),
          // Info Central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['item'] ?? item['service_name'] ?? item['product_name'] ?? 'Ítem',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  "${item['date'] ?? ''} • ${item['client_name'] ?? 'Cliente'}",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                if (item['receipt_number'] != null)
                Text(
                  "Ticket: ${item['receipt_number']}",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          // Precio
          Text(
            "\$${item['price'] ?? 0.0}",
            style: TextStyle(color: kGold, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Diseño de Fila para COMISIONES y PROPINAS
  Widget _financeTile(dynamic item) {
    // Normalizar estado
    final status = (item['status'] ?? 'pending').toString().toLowerCase();
    final isPaid = status == 'paid' || status == 'approved' || status == 'delivered' || status == 'pagado';
    
    // Normalizar fecha
    final dateStr = item['created_at'] ?? item['date'] ?? ''; 
    String formattedDate = "";
    try {
       formattedDate = DateFormat('dd MMM').format(DateTime.parse(dateStr));
    } catch (_) { formattedDate = dateStr; }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icono Estado
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isPaid ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3))
            ),
            child: Icon(
              isPaid ? Icons.check_circle_outline : Icons.watch_later_outlined,
              color: isPaid ? Colors.green : Colors.orange, size: 20
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['concept'] ?? item['description'] ?? 'Concepto',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Monto
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${item['amount'] ?? 0.0}",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: isPaid ? Colors.green : Colors.orange, 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
