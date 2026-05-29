import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../products/products_screen.dart' show AppColors;
import '../../models/product_model.dart';
// import '../../widgets/loading/shimmer_skeleton.dart';
// import '../../widgets/loading/loader.dart';
import '../../widgets/loading/shimmer.dart'; 


// ═══════════════════════════════════════════════════════════════════════════════
// EXTENDED PRODUCT MODEL
// ═══════════════════════════════════════════════════════════════════════════════

class ProductDetailModel {
  final Product base;
  final String description;
  final List<String> highlights;
  final String? sku;
  final int stockQuantity;

  const ProductDetailModel({
    required this.base,
    required this.description,
    required this.highlights,
    this.sku,
    this.stockQuantity = 10,
  });

  bool get isLimited => stockQuantity <= 3;

  factory ProductDetailModel.fromJson(
    Map<String, dynamic> j,
  ) {
    final rawHighlights = j['highlights'];

    final highlights = rawHighlights is List
        ? rawHighlights.map((e) => e.toString()).toList()
        : <String>[
            'Authentic formula — direct sourced',
            'Long-lasting performance',
            'Premium packaging included',
          ];

    return ProductDetailModel(
      base: Product.fromJson(j),

      description:
          (j['description']?.toString() ??
              'Pure, potent and effective ${j['name'] ?? 'product'} '
                  'designed for maximum results.').replaceAll(RegExp(r'<[^>]*>'), ''),

      highlights: highlights,

      sku: j['sku']?.toString(),

      stockQuantity:
          int.tryParse(
                j['stock_quantity']?.toString() ?? '',
              ) ??
              10,
    );
  }

  factory ProductDetailModel.fromProduct(
    Product p,
  ) {
    return ProductDetailModel(
      base: p,

      description:
          p.description,

      highlights: [
        'Authentic formula — direct sourced',
        'Long-lasting performance',
        'Premium packaging included',
      ],

      sku: null,

      stockQuantity: 10,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRODUCT DETAIL PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}

class _ProductDetailPageState
    extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  ProductDetailModel? _detail;

  bool _isLoading = true;
  bool _wishlisted = false;
  bool _addingCart = false;


  late final AnimationController _fadeCtrl =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final Animation<double> _fadeAnim =
      CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
  );

  late final AnimationController _slideCtrl =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );

  late final Animation<Offset> _slideAnim =
      Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _slideCtrl,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FETCH PRODUCT DETAILS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _fetchDetail() async {
    try {
      final uri = Uri.parse(
        'https://admin.rasmuspharmaceuticals.com/api/v1/products/${widget.product.id}',
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body =
            jsonDecode(response.body)
                as Map<String, dynamic>;

        final data = body['data'] ?? body;

        setState(() {
          _detail =
              ProductDetailModel.fromJson(
            data,
          );

          _isLoading = false;
        });
      } else {
        _useFallback();
      }
    } catch (e) {
      _useFallback();
    }

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  void _useFallback() {
    if (!mounted) return;

    setState(() {
      _detail =
          ProductDetailModel.fromProduct(
        widget.product,
      );

      _isLoading = false;
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUANTITY
  // ═══════════════════════════════════════════════════════════════════════════


  // ═══════════════════════════════════════════════════════════════════════════
  // ADD TO CART
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _addToCart() async {
    if (_addingCart) return;

    setState(() {
      _addingCart = true;
    });

    HapticFeedback.mediumImpact();

    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    if (!mounted) return;

    setState(() {
      _addingCart = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '${widget.product.name} added to cart',
          style: GoogleFonts.inter(),
        ),

        backgroundColor:
            AppColors.primary,

        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<
        SystemUiOverlayStyle>(
      value:
          SystemUiOverlayStyle.dark,

      child: Scaffold(
        backgroundColor:
            AppColors.lightBg,

        body: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _buildDetail(),
      ),
    );
  }

  Widget _buildDetail() {
    final detail = _detail!;
    final product = detail.base;

    return Stack(
      children: [
        CustomScrollView(
          physics:
              const BouncingScrollPhysics(),

          slivers: [
            _buildSliverHero(product),

            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,

                child: SlideTransition(
                  position: _slideAnim,

                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          product.name,

                          style:
                              GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          '${product.price}',

                          style:
                              GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight:
                                FontWeight
                                    .w800,

                            color:
                                AppColors
                                    .primary,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Text(
                          detail.description,

                          style:
                              GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.7,
                            color:
                                AppColors
                                    .mediumNeutral,
                          ),
                        ),

                        const SizedBox(
                          height: 120,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        Positioned(
          left: 16,
          right: 16,
          bottom: 20,

          child: SizedBox(
            height: 55,

            child: ElevatedButton(
              onPressed:
                  _addingCart
                      ? null
                      : _addToCart,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
              ),

              child: _addingCart
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      'ADD TO CART',
                      style:
                          GoogleFonts.poppins(
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSliverHero(
    Product product,
  ) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,

      backgroundColor:
          AppColors.white,

      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
        ),

        onPressed: () {
          Navigator.pop(context);
        },
      ),

      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _wishlisted =
                  !_wishlisted;
            });
          },

          icon: Icon(
            _wishlisted
                ? Icons.favorite
                : Icons.favorite_border,
          ),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: product.image
                    .isNotEmpty
            ? Image.network(
                product.image,

                fit: BoxFit.contain,

                errorBuilder:
                    (_, __, ___) {
                  return _HeroPlaceholder(
                    name:
                        product.name,
                  );
                },
              )
            : _HeroPlaceholder(
                name: product.name,
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PLACEHOLDER
// ═══════════════════════════════════════════════════════════════════════════════

class _HeroPlaceholder extends StatelessWidget {
  final String name;
  const _HeroPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.spa_outlined,
            color: AppColors.primary.withValues(alpha: 0.18), size: 68),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(name,
            style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w500,
              color: AppColors.mediumNeutral.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SKELETON LOADER
// ═══════════════════════════════════════════════════════════════════════════════
// ignore: unused_element
class _SkeletonScreen extends StatelessWidget {
  const _SkeletonScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          AppShimmer(
            child: Container(
              height: 320,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBar(
                  width: 90,
                  height: 16,
                ),

                const SizedBox(height: 14),

                _shimmerBar(
                  width: double.infinity,
                  height: 24,
                ),

                const SizedBox(height: 8),

                _shimmerBar(
                  width: 240,
                  height: 24,
                ),

                const SizedBox(height: 24),

                _shimmerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBar(
                        width: 70,
                        height: 14,
                      ),

                      const SizedBox(height: 12),

                      _shimmerBar(
                        width: 120,
                        height: 28,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _shimmerCard(
                  child: Column(
                    children: List.generate(
                      3,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _shimmerBar(
                          width: double.infinity,
                          height: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _shimmerCard(
                  child: Column(
                    children: List.generate(
                      4,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _shimmerBar(
                          width: double.infinity,
                          height: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _shimmerBar({
    required double width,
    required double height,
  }) {
    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static Widget _shimmerCard({
    required Widget child,
  }) {
    return AppShimmer(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      ),
    );
  }
}