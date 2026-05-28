import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../products/products_screen.dart' show AppColors, Product;

// ═══════════════════════════════════════════════════════════════════════════════
// EXTENDED PRODUCT MODEL  (detail-page fields)
// ═══════════════════════════════════════════════════════════════════════════════
class ProductDetailModel {
  final Product    base;
  final String     description;
  final List<String> highlights;
  final String?    sku;
  final int        stockQuantity;

  const ProductDetailModel({
    required this.base,
    required this.description,
    required this.highlights,
    this.sku,
    this.stockQuantity = 10,
  });

  bool get isLimited => stockQuantity <= 3;

  factory ProductDetailModel.fromJson(Map<String, dynamic> j) {
    final rawHighlights = j['highlights'];
    final highlights = rawHighlights is List
        ? rawHighlights.map((e) => e.toString()).toList()
        : <String>[
            'Authentic formula — direct sourced',
            'Long-lasting performance',
            'Premium packaging included',
          ];

    return ProductDetailModel(
      base:          Product.fromJson(j),
      description:   j['description'] as String? ??
          'Pure, potent and effective ${j['name'] ?? 'product'} '
          'designed for maximum results. '
          'Crafted with premium-grade ingredients for a lasting impression.',
      highlights:    highlights,
      sku:           j['sku']            as String?,
      stockQuantity: j['stock_quantity'] as int? ?? 10,
    );
  }

  /// Build from the minimal Product already in memory when the API call fails.
  factory ProductDetailModel.fromProduct(Product p) => ProductDetailModel(
    base:       p,
    description:
        'Pure, potent and effective ${p.name} designed for maximum results. '
        'Crafted with premium-grade ingredients for a lasting impression.',
    highlights: [
      'Authentic formula — direct sourced',
      'Long-lasting performance',
      'Premium packaging included',
    ],
    sku:           p.sku,
    stockQuantity: p.stockQuantity,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRODUCT DETAIL PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  ProductDetailModel? _detail;
  bool   _isLoading   = true;
  int    _quantity    = 1;
  bool   _wishlisted  = false;
  bool   _addingCart  = false;

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _fadeAnim =
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

  late final AnimationController _slideCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 480),
  );
  late final Animation<Offset> _slideAnim = Tween<Offset>(
    begin: const Offset(0, 0.12), end: Offset.zero,
  ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

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

  // ── API call ──────────────────────────────────────────────────────────────
  Future<void> _fetchDetail() async {
    try {
      final uri = Uri.parse(
          'https://api.goldenglowug.com/api/v1/products/${widget.product.id}');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 12));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        setState(() {
          _detail    = ProductDetailModel.fromJson(data as Map<String, dynamic>);
          _isLoading = false;
        });
      } else {
        _useFallback();
      }
    } catch (_) {
      _useFallback();
    }

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  void _useFallback() {
    if (!mounted) return;
    setState(() {
      _detail    = ProductDetailModel.fromProduct(widget.product);
      _isLoading = false;
    });
  }

  // ── Cart actions ──────────────────────────────────────────────────────────
  void _adjustQty(int delta) {
    final maxQty = _detail?.stockQuantity ?? 10;
    setState(() { _quantity = (_quantity + delta).clamp(1, maxQty); });
    HapticFeedback.selectionClick();
  }

  Future<void> _addToCart() async {
    if (_addingCart) return;
    setState(() => _addingCart = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _addingCart = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.product.name} added to cart',
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        body: _isLoading ? _buildSkeleton() : _buildDetail(),
      ),
    );
  }

  // ── Skeleton loader ───────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return const _SkeletonScreen();
  }

  // ── Full detail layout ────────────────────────────────────────────────────
  Widget _buildDetail() {
    final detail  = _detail!;
    final product = detail.base;

    return Stack(
      children: [
        // Scrollable content
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHero(product),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIdentityCard(product, detail),
                      const SizedBox(height: 10),
                      _buildPriceQtyRow(product, detail),
                      const SizedBox(height: 10),
                      _buildStatusChips(detail),
                      const SizedBox(height: 10),
                      _buildHighlightsCard(detail),
                      const SizedBox(height: 10),
                      _buildDescriptionCard(detail),
                      const SizedBox(height: 10),
                      _buildTrustBadges(),
                      const SizedBox(height: 10),
                      _buildShareRow(),
                      // bottom space for sticky CTA
                      SizedBox(
                        height: 90 + MediaQuery.of(context).padding.bottom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Sticky Add-to-Cart bar
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _buildStickyCart(product),
        ),
      ],
    );
  }

  // ── Sliver hero image ─────────────────────────────────────────────────────
  Widget _buildSliverHero(Product product) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.90),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.darkNeutral, size: 17),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () {
              setState(() => _wishlisted = !_wishlisted);
              HapticFeedback.lightImpact();
            },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.90),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  _wishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(_wishlisted),
                  color: _wishlisted
                      ? const Color(0xFFEF4444)
                      : AppColors.mediumNeutral,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background tint
            Container(color: const Color(0xFFEFF6F0)),
            // Product image
            product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        _HeroPlaceholder(name: product.name),
                  )
                : _HeroPlaceholder(name: product.name),
            // Bottom gradient fade
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.lightBg.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
            // Limited badge
            if (product.isLimited)
              Positioned(
                bottom: 16, left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.limitedRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Limited: Only 1 Left',
                        style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.white,
                          fontWeight: FontWeight.w600,
                        )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Identity card: brand + name + rating ──────────────────────────────────
  Widget _buildIdentityCard(Product product, ProductDetailModel detail) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand + SKU row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (product.brand != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    product.brand!.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10, color: AppColors.accent,
                      fontWeight: FontWeight.w700, letterSpacing: 0.7,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (detail.sku != null)
                Expanded(
                  child: Text(
                    'SKU: ${detail.sku}',
                    style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.mediumNeutral,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Product name
          Text(
            product.name,
            style: GoogleFonts.poppins(
              fontSize: 22, fontWeight: FontWeight.w700,
              color: AppColors.darkNeutral, height: 1.25, letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),

          // Rating row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.starAmber.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: AppColors.starAmber.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(5, (i) => Icon(
                      i < product.rating.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14, color: AppColors.starAmber,
                    )),
                    const SizedBox(width: 6),
                    Text(
                      product.rating > 0
                          ? product.rating.toStringAsFixed(1)
                          : '0',
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: AppColors.darkNeutral,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${product.reviewCount} Verified Reviews',
                style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.mediumNeutral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Price + quantity stepper ───────────────────────────────────────────────
  Widget _buildPriceQtyRow(Product product, ProductDetailModel detail) {
    return _SectionCard(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PRICE',
                style: GoogleFonts.inter(
                  fontSize: 10, color: AppColors.mediumNeutral,
                  fontWeight: FontWeight.w600, letterSpacing: 0.8,
                )),
              const SizedBox(height: 4),
              Text(
                product.formattedPrice,
                style: GoogleFonts.inter(
                  fontSize: 24, fontWeight: FontWeight.w800,
                  color: AppColors.primary, letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Quantity stepper
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightBg,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.primary.withOpacity(0.14)),
            ),
            child: Row(
              children: [
                _QtyBtn(icon: Icons.remove_rounded,
                    onTap: () => _adjustQty(-1),
                    enabled: _quantity > 1),
                SizedBox(
                  width: 44,
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: AppColors.darkNeutral,
                    ),
                  ),
                ),
                _QtyBtn(icon: Icons.add_rounded,
                    onTap: () => _adjustQty(1),
                    enabled: _quantity < (detail.stockQuantity)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Status chips ──────────────────────────────────────────────────────────
  Widget _buildStatusChips(ProductDetailModel detail) {
    final chips = [
      if (detail.isLimited)
        _ChipData(Icons.hourglass_top_rounded,
            'Limited: Only 1 Left', AppColors.limitedRed),
      _ChipData(Icons.verified_outlined,
          'Direct Sourcing', const Color(0xFF10B981)),
      _ChipData(Icons.rocket_launch_outlined,
          'Fast Dispatch', AppColors.accent),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: chips.map((c) => _StatusChip(data: c)).toList(),
      ),
    );
  }

  // ── Highlights card ───────────────────────────────────────────────────────
  Widget _buildHighlightsCard(ProductDetailModel detail) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PRODUCT HIGHLIGHTS',
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.mediumNeutral, letterSpacing: 0.8,
            )),
          const SizedBox(height: 12),
          ...detail.highlights.map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(h,
                    style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.darkNeutral,
                      height: 1.55,
                    )),
                ),
              ],
            ),
          )),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Read Full Technical Details →',
              style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Description card ──────────────────────────────────────────────────────
  Widget _buildDescriptionCard(ProductDetailModel detail) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ABOUT THIS PRODUCT',
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.mediumNeutral, letterSpacing: 0.8,
            )),
          const SizedBox(height: 10),
          Text(detail.description,
            style: GoogleFonts.inter(
              fontSize: 13.5, color: AppColors.mediumNeutral,
              height: 1.65,
            )),
        ],
      ),
    );
  }

  // ── Trust badges ──────────────────────────────────────────────────────────
  Widget _buildTrustBadges() {
    const badges = [
      (Icons.verified_rounded, '100% Original'),
      (Icons.replay_rounded,   'Easy Returns'),
      (Icons.lock_outline_rounded, 'Secure Payment'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: badges.asMap().entries.map((entry) {
          final i    = entry.key;
          final badge = entry.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < badges.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Icon(badge.$1,
                    size: 22, color: AppColors.primary.withOpacity(0.65)),
                  const SizedBox(height: 6),
                  Text(badge.$2,
                    style: GoogleFonts.inter(
                      fontSize: 10, color: AppColors.darkNeutral,
                      fontWeight: FontWeight.w600, height: 1.3,
                    ),
                    textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Share row ─────────────────────────────────────────────────────────────
  Widget _buildShareRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SHARE THIS PRODUCT',
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.mediumNeutral, letterSpacing: 0.8,
            )),
          const SizedBox(height: 12),
          Row(
            children: [
              _ShareBtn(
                icon: Icons.facebook_rounded,
                color: const Color(0xFF1877F2),
                label: 'Facebook',
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _ShareBtn(
                icon: Icons.share_rounded,
                color: AppColors.darkNeutral,
                label: 'Share',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sticky cart bar ───────────────────────────────────────────────────────
  Widget _buildStickyCart(Product product) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 12, 16, MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20, offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // WhatsApp button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF25D366).withValues(alpha: 0.35)),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF25D366), size: 21),
            ),
          ),
          const SizedBox(width: 12),

          // Add to Cart button
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _addingCart ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.55),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _addingCart
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white,
                          ),
                        )
                      : Row(
                          key: const ValueKey('label'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, size: 19),
                            const SizedBox(width: 8),
                            Text('ADD TO CART',
                              style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              )),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REUSABLE SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider),
    ),
    child: child,
  );
}

class _QtyBtn extends StatelessWidget {
  final IconData    icon;
  final VoidCallback onTap;
  final bool        enabled;
  const _QtyBtn({required this.icon, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 42, height: 44,
      alignment: Alignment.center,
      child: Icon(icon,
        size: 18,
        color: enabled ? AppColors.primary : AppColors.mediumNeutral.withValues(alpha: 0.35)),
    ),
  );
}

class _ChipData {
  final IconData icon;
  final String   label;
  final Color    color;
  const _ChipData(this.icon, this.label, this.color);
}

class _StatusChip extends StatelessWidget {
  final _ChipData data;
  const _StatusChip({required this.data});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: data.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: data.color.withValues(alpha: 0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(data.icon, size: 13, color: data.color),
        const SizedBox(width: 5),
        Text(data.label,
          style: GoogleFonts.inter(
            fontSize: 11, color: data.color,
            fontWeight: FontWeight.w600,
          )),
      ],
    ),
  );
}

class _ShareBtn extends StatelessWidget {
  final IconData    icon;
  final Color       color;
  final String      label;
  final VoidCallback onTap;
  const _ShareBtn({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 7),
          Text(label,
            style: GoogleFonts.inter(
              fontSize: 12, color: color,
              fontWeight: FontWeight.w600,
            )),
        ],
      ),
    ),
  );
}

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
class _SkeletonScreen extends StatefulWidget {
  const _SkeletonScreen();

  @override
  State<_SkeletonScreen> createState() => _SkeletonScreenState();
}

class _SkeletonScreenState extends State<_SkeletonScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  late final Animation<Color?> _color = ColorTween(
    begin: const Color(0xFFE8EEF6),
    end:   const Color(0xFFF4F7FC),
  ).animate(_ctrl);

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (_, __) {
        final c = _color.value!;
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(height: 320, color: c),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(c, 80, 16),  const SizedBox(height: 10),
                    _bar(c, double.infinity, 26), const SizedBox(height: 8),
                    _bar(c, 220, 26), const SizedBox(height: 18),
                    _bar(c, 140, 16), const SizedBox(height: 20),
                    _bar(c, double.infinity, 80), const SizedBox(height: 14),
                    _bar(c, double.infinity, 60),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bar(Color c, double w, double h) => Container(
    width: w, height: h,
    margin: const EdgeInsets.only(bottom: 0),
    decoration: BoxDecoration(
      color: c, borderRadius: BorderRadius.circular(10),
    ),
  );
}