import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      setState(() {
        _isLoading = false;
        _error = "Authentication required";
      });
      return;
    }

    // Load local orders first as base
    final localOrders = await _loadLocalOrders();

    try {
      final response = await http.get(
        Uri.parse('https://testing.rasmuspharmaceuticals.com/api/v1/orders'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> apiOrders = [];
        if (decoded is List) {
          apiOrders = decoded;
        } else if (decoded is Map) {
          final data = decoded['data'] ?? decoded['orders'];
          if (data is List) {
            apiOrders = data;
          }
        }

        // Merge API orders and local orders, prioritizing API order detail and deduplicating by ID
        final Map<String, dynamic> merged = {};
        
        // Add local ones first
        for (var o in localOrders) {
          final id = o['id']?.toString() ?? o['order_number']?.toString() ?? '';
          if (id.isNotEmpty) merged[id] = o;
        }

        // Add API ones (overwrites local if matches)
        for (var o in apiOrders) {
          final id = o['id']?.toString() ?? o['order_number']?.toString() ?? '';
          if (id.isNotEmpty) merged[id] = o;
        }

        setState(() {
          _orders = merged.values.toList()
            ..sort((a, b) {
              final dateA = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.now();
              final dateB = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.now();
              return dateB.compareTo(dateA); // newest first
            });
          _isLoading = false;
        });
      } else {
        // Fallback to local orders on error
        setState(() {
          _orders = localOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to local orders on network issues
      setState(() {
        _orders = localOrders;
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>> _loadLocalOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('local_placed_orders');
      if (saved != null) {
        return saved.map((s) => jsonDecode(s)).toList();
      }
    } catch (e) {
      debugPrint("Error loading local orders: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF000435)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Order History",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF000435),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF000435),
              ),
            )
          : _error != null
              ? Center(child: Text(_error!, style: GoogleFonts.inter(color: Colors.red)))
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000435).withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Color(0xFF000435),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "No Orders Yet",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "When you buy products, they will appear here.",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      color: const Color(0xFF000435),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          final id = order['id']?.toString() ?? order['order_number']?.toString() ?? 'Order #${index + 1}';
                          final status = order['status']?.toString() ?? 'pending';
                          final dateStr = order['created_at']?.toString() ?? '';
                          final itemsList = order['items'] as List? ?? [];
                          
                          DateTime? date = DateTime.tryParse(dateStr);
                          String formattedDate = date != null
                              ? "${date.day}/${date.month}/${date.year}"
                              : "Recently";

                          // Calculate total amount if not returned directly
                          double totalAmt = 0;
                          final rawTotal = order['total_amount'] ?? order['total'];
                          if (rawTotal != null) {
                            totalAmt = double.tryParse(rawTotal.toString()) ?? 0;
                          } else {
                            // Sum from items if available
                            for (var it in itemsList) {
                              final p = it['product'];
                              final q = int.tryParse(it['quantity']?.toString() ?? '1') ?? 1;
                              if (p != null) {
                                final priceStr = p['formatted_price'] ?? p['price']?.toString() ?? '0';
                                final cleanPrice = double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
                                totalAmt += cleanPrice * q;
                              }
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ExpansionTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Order #$id",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  _buildStatusBadge(status),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      "UGX ${_formatPrice(totalAmt)}",
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: const Color(0xFF000435),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              childrenPadding: const EdgeInsets.all(16),
                              expandedAlignment: Alignment.topLeft,
                              shape: const Border(),
                              children: [
                                const Divider(color: Color(0xFFF1F5F9), height: 1),
                                const SizedBox(height: 12),
                                Text(
                                  "Items Ordered:",
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 8),
                                ...itemsList.map((it) {
                                  final p = it['product'];
                                  final q = it['quantity'] ?? 1;
                                  final name = p != null ? (p['name']?.toString() ?? 'Product') : 'Product';
                                  final price = p != null ? (p['formatted_price'] ?? p['price']?.toString() ?? 'UGX 0') : 'UGX 0';
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "$name x$q",
                                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          price,
                                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B)),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 12),
                                if (order['delivery_address'] != null) ...[
                                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Delivery Address:",
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order['delivery_address'].toString(),
                                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFFD97706);
    if (status.toLowerCase() == 'completed' || status.toLowerCase() == 'delivered') {
      bg = const Color(0xFFD1FAE5);
      fg = const Color(0xFF059669);
    } else if (status.toLowerCase() == 'cancelled') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  String _formatPrice(double amount) {
    if (amount <= 0) return "0";
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) matchFunc = (Match match) => '${match[1]},';
    return amount.toStringAsFixed(0).replaceAllMapped(reg, matchFunc);
  }
}
