import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/checkout_service.dart';
import '../widgets/loading/shimmer.dart';
import '../screens/checkout/order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _checkoutService = CheckoutService();
  final _addressCtrl = TextEditingController();

  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _towns = [];

  int? _selectedRegionId;
  int? _selectedTownId;
  String _selectedMethod = 'standard'; // default

  bool _regionsLoading = true;
  bool _townsLoading = false;
  bool _submitting = false;

  String? _regionsError;
  String? _townsError;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  // =========================================
  // LOAD REGIONS
  // =========================================
  Future<void> _loadRegions() async {
    setState(() {
      _regionsLoading = true;
      _regionsError = null;
    });

    try {
      final regions = await _checkoutService.fetchRegions();
      setState(() {
        _regions = regions;
        _regionsLoading = false;
      });
    } catch (e) {
      setState(() {
        _regionsError = e.toString().replaceFirst('Exception: ', '');
        _regionsLoading = false;
      });
    }
  }

  // =========================================
  // LOAD TOWNS FOR REGION
  // =========================================
  Future<void> _loadTowns(int regionId) async {
    setState(() {
      _townsLoading = true;
      _townsError = null;
      _towns = [];
      _selectedTownId = null;
    });

    try {
      final towns = await _checkoutService.fetchTowns(regionId);
      setState(() {
        _towns = towns;
        _townsLoading = false;
      });
    } catch (e) {
      setState(() {
        _townsError = e.toString().replaceFirst('Exception: ', '');
        _townsLoading = false;
      });
    }
  }

  // =========================================
  // PLACE ORDER
  // =========================================
  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegionId == null) {
      _showErrorSnackBar("Please select a Region");
      return;
    }
    if (_selectedTownId == null) {
      _showErrorSnackBar("Please select a Town");
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (cartProvider.items.isEmpty) {
      _showErrorSnackBar("Your cart is empty");
      return;
    }

    if (!authProvider.isLoggedIn || authProvider.token == null) {
      _showErrorSnackBar("Session expired. Please log in again.");
      return;
    }

    setState(() {
      _submitting = true;
    });

    // Format items as required: items (array of product_id and quantity)
    final itemsPayload = cartProvider.items.map((item) {
      return {
        'product_id': item.product.id,
        'quantity': item.quantity,
      };
    }).toList();

    try {
      final orderResult = await _checkoutService.placeOrder(
        token: authProvider.token!,
        items: itemsPayload,
        deliveryMethod: _selectedMethod,
        deliveryRegionId: _selectedRegionId!,
        deliveryTownId: _selectedTownId!,
        deliveryAddress: _addressCtrl.text.trim(),
      );

      // Save attributes for confirmation screen before clearing cart
      final deliveryAddress = _addressCtrl.text.trim();
      final deliveryMethod = _selectedMethod;
      final totalAmount = cartProvider.totalAmount;
      final totalItems = cartProvider.totalQuantity;

      // Clear the cart on successful order
      cartProvider.clearCart();

      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      // Navigate to order confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(
            orderResponse: orderResult,
            deliveryAddress: deliveryAddress,
            deliveryMethod: deliveryMethod,
            totalAmount: totalAmount,
            totalItems: totalItems,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
      });
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    Theme.of(context);

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
          "Checkout Details",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF000435),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Delivery Method Card
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Delivery Method",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Standard Delivery'),
                              selected: _selectedMethod == 'standard',
                              selectedColor: const Color(0xFFE0F2FE),
                              labelStyle: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _selectedMethod == 'standard'
                                    ? const Color(0xFF000435)
                                    : const Color(0xFF64748B),
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: BorderSide(
                                color: _selectedMethod == 'standard'
                                    ? const Color(0xFF000435)
                                    : Colors.grey.shade200,
                              ),
                              onSelected: (bool selected) {
                                if (selected) setState(() => _selectedMethod = 'standard');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Express Delivery'),
                              selected: _selectedMethod == 'express',
                              selectedColor: const Color(0xFFE0F2FE),
                              labelStyle: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _selectedMethod == 'express'
                                    ? const Color(0xFF000435)
                                    : const Color(0xFF64748B),
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: BorderSide(
                                color: _selectedMethod == 'express'
                                    ? const Color(0xFF000435)
                                    : Colors.grey.shade200,
                              ),
                              onSelected: (bool selected) {
                                if (selected) setState(() => _selectedMethod = 'express');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Shipping Form
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Shipping Location",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Region Dropdown (with skeleton loader)
                      Text(
                        "Region",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _regionsLoading
                          ? _buildShimmerField(height: 52)
                          : _regionsError != null
                              ? _buildErrorField(_regionsError!, _loadRegions)
                              : DropdownButtonFormField<int>(
                                  value: _selectedRegionId,
                                  decoration: _inputDecoration(
                                    hintText: "Select region",
                                    icon: Icons.map_outlined,
                                  ),
                                  items: _regions.map((reg) {
                                    return DropdownMenuItem<int>(
                                      value: reg['id'],
                                      child: Text(reg['name'] ?? ''),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedRegionId = val;
                                      });
                                      _loadTowns(val);
                                    }
                                  },
                                  validator: (val) => val == null ? "Region is required" : null,
                                ),
                      const SizedBox(height: 16),

                      // Town Dropdown (with skeleton loader)
                      Text(
                        "Town",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _townsLoading
                          ? _buildShimmerField(height: 52)
                          : _townsError != null
                              ? _buildErrorField(_townsError!, () => _loadTowns(_selectedRegionId!))
                              : DropdownButtonFormField<int>(
                                  value: _selectedTownId,
                                  disabledHint: const Text("Select region first"),
                                  decoration: _inputDecoration(
                                    hintText: _selectedRegionId == null ? "Select region first" : "Select town",
                                    icon: Icons.location_city_outlined,
                                  ),
                                  items: _towns.map((town) {
                                    return DropdownMenuItem<int>(
                                      value: town['id'],
                                      child: Text(town['name'] ?? ''),
                                    );
                                  }).toList(),
                                  onChanged: _selectedRegionId == null
                                      ? null
                                      : (val) {
                                          setState(() => _selectedTownId = val);
                                        },
                                  validator: (val) => val == null ? "Town is required" : null,
                                ),
                      const SizedBox(height: 16),

                      // Address Field
                      Text(
                        "Delivery Address",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: _inputDecoration(
                          hintText: "Street name, Apartment/House No, Plot info",
                          icon: Icons.home_work_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Delivery address is required";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Summary
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Items", style: GoogleFonts.inter(color: const Color(0xFF64748B))),
                          Text("${cartProvider.totalQuantity}", style: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Amount", style: GoogleFonts.poppins(color: const Color(0xFF000435), fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("UGX ${_formatPrice(cartProvider.totalAmount)}", style: GoogleFonts.inter(color: const Color(0xFF000435), fontWeight: FontWeight.w800, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Place Order Button (Standard loading indicator & disabled during submit)
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitting || _regionsLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000435),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF000435).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Place Order",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // SKELETON LOADER FOR SELECT FIELDS (GET requests)
  Widget _buildShimmerField({required double height}) {
    return AppShimmer(
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  // ERROR FIELD (Displays fallback/retry)
  Widget _buildErrorField(String error, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF991B1B)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF991B1B), size: 18),
            onPressed: onRetry,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF94A3B8),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF000435), width: 1.5),
      ),
    );
  }

  String _formatPrice(double amount) {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) matchFunc = (Match match) => '${match[1]},';
    return amount.toStringAsFixed(0).replaceAllMapped(reg, matchFunc);
  }
}