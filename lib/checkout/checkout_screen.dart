import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/checkout_service.dart';
import '../widgets/loading/shimmer.dart';
import '../screens/checkout/order_confirmation_screen.dart';
import '../widgets/notification_helper.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _checkoutService = CheckoutService();
  final _addressCtrl = TextEditingController();
  final _referenceContactCtrl = TextEditingController();
  final _mobileMoneyNumberCtrl = TextEditingController();

  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _towns = [];

  int? _selectedRegionId;
  int? _selectedTownId;
  String _selectedMethod = 'Standard Delivery'; // default for API

  String _selectedPaymentMethod = 'cash'; // 'cash' or 'mobile_money'
  String _selectedMno = 'MTN'; // 'MTN' or 'Airtel'

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
    _referenceContactCtrl.dispose();
    _mobileMoneyNumberCtrl.dispose();
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

    final addressWithRef = "${_addressCtrl.text.trim()} (Ref: ${_referenceContactCtrl.text.trim()})";

    try {
      final orderResult = await _checkoutService.placeOrder(
        token: authProvider.token!,
        items: itemsPayload,
        deliveryMethod: _selectedMethod,
        deliveryRegionId: _selectedRegionId!,
        deliveryTownId: _selectedTownId!,
        deliveryAddress: addressWithRef,
        referenceContact: _referenceContactCtrl.text.trim(),
        paymentMethod: _selectedPaymentMethod,
      );

      // Local Order Persistence
      try {
        final prefs = await SharedPreferences.getInstance();
        final localList = prefs.getStringList('local_placed_orders') ?? <String>[];
        final newOrder = {
          'id': orderResult['id']?.toString() ?? orderResult['order_number']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'order_number': orderResult['order_number']?.toString() ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}',
          'status': 'pending',
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'delivery_address': addressWithRef,
          'total_amount': cartProvider.totalAmount,
          'items': cartProvider.items.map((item) => {
            'product': {
              'id': item.product.id,
              'name': item.product.name,
              'formatted_price': item.product.price,
              'main_image': item.product.image,
            },
            'quantity': item.quantity,
          }).toList(),
        };
        localList.add(jsonEncode(newOrder));
        await prefs.setStringList('local_placed_orders', localList);
      } catch (e) {
        debugPrint("Error persisting order locally: $e");
      }

      // Save attributes for confirmation screen before clearing cart
      final deliveryAddress = addressWithRef;
      final deliveryMethod = _selectedMethod;
      final totalAmount = cartProvider.totalAmount;
      final totalItems = cartProvider.totalQuantity;

      // Clear the cart on successful order
      cartProvider.clearCart();

      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      // Show top right green success notification
      showTopNotification(context, "Order placed successfully!", isSuccess: true);

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
    showTopNotification(context, msg, isSuccess: false);
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
              // Reference Contact Card
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
                        "Reference Contact",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _referenceContactCtrl,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: _inputDecoration(
                          hintText: "Enter contact number (e.g. 07XXXXXXXX)",
                          icon: Icons.phone_android_rounded,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Reference contact is required";
                          }
                          if (val.trim().length < 10) {
                            return "Please enter a valid phone number";
                          }
                          return null;
                        },
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

              // Payment Method Card
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
                        "Payment Method",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPaymentMethod = 'mobile_money'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == 'mobile_money'
                                      ? const Color(0xFFE0F2FE)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedPaymentMethod == 'mobile_money'
                                        ? const Color(0xFF000435)
                                        : Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.phone_android_rounded,
                                      color: _selectedPaymentMethod == 'mobile_money'
                                          ? const Color(0xFF000435)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Mobile Money",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedPaymentMethod == 'mobile_money'
                                            ? const Color(0xFF000435)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPaymentMethod = 'cash'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == 'cash'
                                      ? const Color(0xFFE0F2FE)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedPaymentMethod == 'cash'
                                        ? const Color(0xFF000435)
                                        : Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.payments_outlined,
                                      color: _selectedPaymentMethod == 'cash'
                                          ? const Color(0xFF000435)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Cash on Delivery",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedPaymentMethod == 'cash'
                                            ? const Color(0xFF000435)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Conditionally show Mobile Money options
                      if (_selectedPaymentMethod == 'mobile_money') ...[
                        const SizedBox(height: 16),
                        Text(
                          "Network Operator",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedMno,
                          decoration: _inputDecoration(
                            hintText: "Select operator",
                            icon: Icons.wifi_tethering_rounded,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'MTN', child: Text('MTN Mobile Money')),
                            DropdownMenuItem(value: 'Airtel', child: Text('Airtel Money')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedMno = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Mobile Money Number",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _mobileMoneyNumberCtrl,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.inter(fontSize: 14),
                          decoration: _inputDecoration(
                            hintText: "Enter MM number (e.g. 07XXXXXXXX)",
                            icon: Icons.phone_iphone_rounded,
                          ),
                          validator: (val) {
                            if (_selectedPaymentMethod == 'mobile_money') {
                              if (val == null || val.trim().isEmpty) {
                                return "Mobile money number is required";
                              }
                              if (val.trim().length < 10) {
                                return "Please enter a valid phone number";
                              }
                            }
                            return null;
                          },
                        ),
                      ],
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