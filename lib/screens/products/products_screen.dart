import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutriblend_group2/screens/product_detail/product_detail_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// APP COLOR CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════
class AppColors {
  AppColors._();

  static const Color primary       = Color(0xFF000435);
  static const Color accent        = Color(0xFF0EA5E9);
  static const Color darkNeutral   = Color(0xFF1E293B);
  static const Color mediumNeutral = Color(0xFF64748B);
  static const Color lightBg       = Color(0xFFF8FAFC);
  static const Color white         = Color(0xFFFFFFFF);
  static const Color limitedRed    = Color(0xFFEF4444);
  static const Color starAmber     = Color(0xFFF59E0B);
  static const Color divider       = Color(0xFFE2E8F0);
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRODUCT MODEL
// ═══════════════════════════════════════════════════════════════════════════════
class Product {
  final int     id;
  final String  name;
  final String  formattedPrice;
  final String? imageUrl;
  final String? brand;
  final double  rating;
  final int     reviewCount;
  final int     stockQuantity;
  final String? sku;
  final String? description;

  const Product({
    required this.id,
    required this.name,
    required this.formattedPrice,
    this.imageUrl,
    this.brand,
    this.rating        = 0.0,
    this.reviewCount   = 0,
    this.stockQuantity = 99,
    this.sku,
    this.description,
  });

  bool get isLimited => stockQuantity <= 3;

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id:             j['id']              ?? 0,
    name:           j['name']            ?? '',
    formattedPrice: j['formatted_price'] ?? j['price']?.toString() ?? '',
    imageUrl:       j['image_url']       ?? j['image'],
    brand:          j['brand']           ?? (j['category'] as Map?)?['name'],
    rating:         ((j['rating']        ?? 0) as num).toDouble(),
    reviewCount:    j['review_count']    ?? j['reviews_count'] ?? 0,
    stockQuantity:  j['stock_quantity']  ?? 99,
    sku:            j['sku'],
    description:    j['description'],
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK API SERVICE
// ═══════════════════════════════════════════════════════════════════════════════
class ProductApiService {
  static Future<({List<Product> products, int total, int lastPage, int currentPage})>
      fetchProducts(int page) async {

    await Future.delayed(const Duration(milliseconds: 800));

    final allProducts = [
      Product(id: 1,  name: 'Yara Moi',                   formattedPrice: 'UGX 180,000', brand: 'LATTAFA', stockQuantity: 1,  imageUrl: 'https://picsum.photos/seed/prod1/400/400'),
      Product(id: 2,  name: 'Yara EDP',                   formattedPrice: 'UGX 180,000', brand: 'LATTAFA', stockQuantity: 1,  imageUrl: 'https://picsum.photos/seed/prod2/400/400'),
      Product(id: 3,  name: 'Yara Candy',                 formattedPrice: 'UGX 180,000', brand: 'LATTAFA', stockQuantity: 1,  imageUrl: 'https://picsum.photos/seed/prod3/400/400'),
      Product(id: 4,  name: 'Ana Abiyedh Iam White EDP',  formattedPrice: 'UGX 150,000', brand: 'LATTAFA', stockQuantity: 10, imageUrl: 'https://picsum.photos/seed/prod4/400/400'),
      Product(id: 5,  name: 'Asad EDP 100ml',             formattedPrice: 'UGX 200,000', brand: 'LATTAFA', stockQuantity: 5,  imageUrl: 'https://picsum.photos/seed/prod5/400/400'),
      Product(id: 6,  name: 'Oud Mood Elixir',            formattedPrice: 'UGX 220,000', brand: 'LATTAFA', stockQuantity: 3,  imageUrl: 'https://picsum.photos/seed/prod6/400/400'),
      Product(id: 7,  name: 'Raghba Wood Intense',        formattedPrice: 'UGX 170,000', brand: 'LATTAFA', stockQuantity: 8,  imageUrl: 'https://picsum.photos/seed/prod7/400/400'),
      Product(id: 8,  name: "Bade'e Al Oud Amethyst",     formattedPrice: 'UGX 195,000', brand: 'LATTAFA', stockQuantity: 2,  imageUrl: 'https://picsum.photos/seed/prod8/400/400'),
      Product(id: 9,  name: 'Khamrah Qahwa',              formattedPrice: 'UGX 210,000', brand: 'LATTAFA', stockQuantity: 6,  imageUrl: 'https://picsum.photos/seed/prod9/400/400'),
      Product(id: 10, name: 'Oud For Glory',              formattedPrice: 'UGX 250,000', brand: 'LATTAFA', stockQuantity: 4,  imageUrl: 'https://picsum.photos/seed/prod10/400/400'),
      Product(id: 11, name: 'Velvet Rose & Oud',          formattedPrice: 'UGX 185,000', brand: 'LATTAFA', stockQuantity: 7,  imageUrl: 'https://picsum.photos/seed/prod11/400/400'),
      Product(id: 12, name: 'Fakhar Man EDP',             formattedPrice: 'UGX 160,000', brand: 'LATTAFA', stockQuantity: 1,  imageUrl: 'https://picsum.photos/seed/prod12/400/400'),
    ];

    const perPage  = 6;
    final lastPage = (allProducts.length / perPage).ceil();
    final safePage = page.clamp(1, lastPage);
    final start    = (safePage - 1) * perPage;
    final end      = (start + perPage).clamp(0, allProducts.length);
    final pageData = allProducts.sublist(start, end);

    debugPrint('── Products (page $safePage) ────────');
    debugPrint('Total products: ${allProducts.length}');
    for (final p in pageData) {
      debugPrint('  • ${p.name}  →  ${p.formattedPrice}');
    }

    return (
      products:    pageData,
      total:       allProducts.length,
      lastPage:    lastPage,
      currentPage: safePage,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BEAUTIFUL PAGE ROUTE  — scale + fade zoom transition when tapping a card
// ═══════════════════════════════════════════════════════════════════════════════
class _ZoomFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  _ZoomFadeRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Outgoing page fades + scales down slightly
            final fadeOut = Tween<double>(begin: 1.0, end: 0.88).animate(
              CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
            );

            // Incoming page: fade in + scale from 0.88 → 1.0
            final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            final scaleIn = Tween<double>(begin: 0.88, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

            return FadeTransition(
              opacity: fadeOut,
              child: FadeTransition(
                opacity: fadeIn,
                child: ScaleTransition(scale: scaleIn, child: child),
              ),
            );
          },
        );
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRODUCT PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> with TickerProviderStateMixin {
  final List<Product> _products  = [];
  bool   _isLoading     = false;
  bool   _isLoadingMore = false;
  String? _error;

  int _currentPage = 1;
  int _lastPage    = 6;
  int _totalCount  = 0;

  // Tracks which page index each currently-displayed product came from,
  // so dot-navigation can jump back to any page.
  final TextEditingController _searchCtrl = TextEditingController();

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _fadeAnim =
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────
  Future<void> _loadPage({bool loadMore = false}) async {
    if (!mounted) return;

    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() { _isLoading = true; _error = null; });
    }

    try {
      final result = await ProductApiService.fetchProducts(_currentPage);

      if (!mounted) return;
      setState(() {
        if (loadMore) {
          _products.addAll(result.products);
        } else {
          // REPLACE products (not append) so we only ever show current page
          _products
            ..clear()
            ..addAll(result.products);
        }
        _totalCount    = result.total;
        _lastPage      = result.lastPage;
        _isLoading     = false;
        _isLoadingMore = false;
      });
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error         = 'Could not load products.\nCheck your connection and try again.';
        _isLoading     = false;
        _isLoadingMore = false;
      });
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  /// Go to  page — replaces current products with next page
  void _loadNext() {
    if (_isLoadingMore || _isLoading || _currentPage >= _lastPage) return;
    _currentPage++;
    _loadPage(); // NOT loadMore:true → replaces list
  }

  /// Jump to a specific page via dot tap (also handles going back to page 1)
  void _jumpToPage(int page) {
    if (page == _currentPage || _isLoading) return;
    _currentPage = page;
    _loadPage();
  }

  List<Product> get _visibleProducts {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _products;
    return _products.where((p) =>
        p.name.toLowerCase().contains(q) ||
        (p.brand?.toLowerCase().contains(q) ?? false)).toList();
  }

  void _openDetail(Product product) {
    Navigator.push(
      context,
      _ZoomFadeRoute(page: ProductDetailPage(product: product)),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── Header  (straight corners, no bottom radius) ──────────────────────────
  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Our Products',
                    style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.w700,
                      color: AppColors.white, letterSpacing: -0.4,
                    )),
                  Text(
                    _totalCount > 0
                        ? '$_totalCount items available'
                        : 'Products collection',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _HeaderIconBtn(icon: Icons.tune_rounded,          onTap: () {}),
              const SizedBox(width: 8),
              _HeaderIconBtn(icon: Icons.shopping_bag_outlined, onTap: () {}),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.white.withValues(alpha: 0.14)),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.inter(color: AppColors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search products or brands…',
                hintStyle: GoogleFonts.inter(
                    color: AppColors.white.withValues(alpha: 0.38), fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    color: AppColors.white.withValues(alpha: 0.45), size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () { _searchCtrl.clear(); setState(() {}); },
                        child: Icon(Icons.close_rounded,
                            color: AppColors.white.withValues(alpha: 0.45), size: 18),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) return const _FullPageSpinner();

    if (_error != null) {
      return _FullPageError(
        message: _error!,
        onRetry: () { _currentPage = 1; _loadPage(); },
      );
    }

    final products = _visibleProducts;

    if (products.isEmpty) {
      return _EmptyState(
        query: _searchCtrl.text,
        onClear: () { _searchCtrl.clear(); setState(() {}); },
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Row(
            children: [
              Text('${products.length} products',
                style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.mediumNeutral,
                  fontWeight: FontWeight.w500,
                )),
              const Spacer(),
              Text('Page $_currentPage of $_lastPage',
                style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.mediumNeutral,
                )),
            ],
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                // ✅ FIX: increased ratio to give cards more vertical space
                childAspectRatio: 0.58,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) => _ProductCard(
                product:  products[index],
                index:    index,
                onTap:    () => _openDetail(products[index]),
              ),
            ),
          ),
        ),
        _buildPaginationSection(),
      ],
    );
  }

  // ── Pagination bar ─────────────────────────────────────────────────────────
  Widget _buildPaginationSection() {
    return Container(
      color: AppColors.lightBg,
      padding: EdgeInsets.fromLTRB(
        20, 12, 20, MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        children: [
          // ── Tappable page dots ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_lastPage, (i) {
              final pageNum = i + 1;
              final active  = pageNum == _currentPage;
              return GestureDetector(
                onTap: () => _jumpToPage(pageNum),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width:  active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // ── Prev / Load More / Next row ───────────────────────────────────
          Row(
            children: [
              // Previous button — only visible when not on page 1
              if (_currentPage > 1)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _PrevNextButton(
                      label: 'Prev',
                      icon: Icons.keyboard_arrow_up_rounded,
                      iconLeft: true,
                      onTap: () => _jumpToPage(_currentPage - 1),
                    ),
                  ),
                ),

              // Load Next button
              Expanded(
                flex: 3,
                child: _LoadMoreButton(
                  isLoading:   _isLoadingMore,
                  isLastPage:  _currentPage >= _lastPage,
                  onTap:       _loadNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREV / NEXT BUTTON
// ═══════════════════════════════════════════════════════════════════════════════
class _PrevNextButton extends StatelessWidget {
  final String    label;
  final IconData  icon;
  final bool      iconLeft;
  final VoidCallback onTap;

  const _PrevNextButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: iconLeft
              ? [
                  Icon(icon, size: 18),
                  const SizedBox(width: 4),
                  Text(label,
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                    )),
                ]
              : [
                  Text(label,
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                    )),
                  const SizedBox(width: 4),
                  Icon(icon, size: 18),
                ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOAD MORE BUTTON  (animated)
// ═══════════════════════════════════════════════════════════════════════════════
class _LoadMoreButton extends StatefulWidget {
  final bool isLoading;
  final bool isLastPage;
  final VoidCallback onTap;

  const _LoadMoreButton({
    required this.isLoading,
    required this.isLastPage,
    required this.onTap,
  });

  @override
  State<_LoadMoreButton> createState() => _LoadMoreButtonState();
}

class _LoadMoreButtonState extends State<_LoadMoreButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.97,
    upperBound: 1.03,
  );

  @override
  void initState() {
    super.initState();
    if (!widget.isLastPage) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_LoadMoreButton old) {
    super.didUpdateWidget(old);
    if (widget.isLastPage) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(
        scale: (widget.isLastPage || widget.isLoading) ? 1.0 : _pulse.value,
        child: child,
      ),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: (widget.isLastPage || widget.isLoading) ? null : widget.onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
            disabledForegroundColor: AppColors.white.withValues(alpha: 0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.white,
                  ),
                )
              : widget.isLastPage
                  ? Text('All products loaded',
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500,
                      ))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Load More',
                          style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600,
                          )),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                      ],
                    ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRODUCT CARD  — with press-shrink + staggered fade-in animation
// ═══════════════════════════════════════════════════════════════════════════════
class _ProductCard extends StatefulWidget {
  final Product      product;
  final int          index;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  // Controls the press-shrink animation
  late final AnimationController _pressCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 220),
    lowerBound: 0.93,
    upperBound: 1.00,
    value: 1.0,
  );


  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressCtrl.animateTo(0.93,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeIn,
    );
  }

  void _onTapUp(TapUpDetails _) => _relax();
  void _onTapCancel() => _relax();

  void _relax() {
    _pressCtrl.animateTo(1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.elasticOut,  // bouncy spring-back
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pressCtrl,
      builder: (_, child) => Transform.scale(
        scale: _pressCtrl.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown:   _onTapDown,
        onTapUp:     _onTapUp,
        onTapCancel: _onTapCancel,
        onTap:       widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          // ✅ FIX: use a fixed-height Column instead of Expanded/flex
          // so text never overflows
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image — takes up ~58% of the card
              Expanded(
                flex: 58,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: _ProductImage(
                          imageUrl: widget.product.imageUrl,
                          name:     widget.product.name,
                        ),
                      ),
                    ),
                    // Favourite button
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.88),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6, offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.favorite_border_rounded,
                            size: 15, color: AppColors.mediumNeutral),
                      ),
                    ),
                    // Limited stock badge
                    if (widget.product.isLimited)
                      Positioned(
                        top: 10, left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.limitedRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5, height: 5,
                                decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text('Only ${widget.product.stockQuantity} left',
                                style: GoogleFonts.inter(
                                  fontSize: 9, color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                )),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Info section — takes up ~42% ─────────────────────────────
              Expanded(
                flex: 42,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand + name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.product.brand != null)
                            Text(
                              widget.product.brand!.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9, color: AppColors.accent,
                                fontWeight: FontWeight.w700, letterSpacing: 0.7,
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 2),
                          Text(
                            widget.product.name,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5, fontWeight: FontWeight.w600,
                              color: AppColors.darkNeutral, height: 1.25,
                            ),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Stars
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                            i < widget.product.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 11, color: AppColors.starAmber,
                          )),
                          const SizedBox(width: 4),
                          Text('(${widget.product.reviewCount})',
                            style: GoogleFonts.inter(
                              fontSize: 10, color: AppColors.mediumNeutral,
                            )),
                        ],
                      ),

                      // Price + add button
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.formattedPrice,
                              style: GoogleFonts.inter(
                                fontSize: 12.5, fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRODUCT IMAGE
// ═══════════════════════════════════════════════════════════════════════════════
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String  name;

  const _ProductImage({this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return _shimmer();
        },
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFEFF6F0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa_outlined,
              color: AppColors.primary.withValues(alpha: 0.22), size: 40),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.mediumNeutral.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer() => Container(color: const Color(0xFFEFF6F0));
}

// ═══════════════════════════════════════════════════════════════════════════════
// SMALL REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════
class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: AppColors.white, size: 19),
      ),
    );
  }
}

class _FullPageSpinner extends StatelessWidget {
  const _FullPageSpinner();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 38, height: 38,
            child: CircularProgressIndicator(
              strokeWidth: 2.5, color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text('Fetching products…',
            style: GoogleFonts.inter(
              fontSize: 14, color: AppColors.mediumNeutral,
            )),
        ],
      ),
    );
  }
}

class _FullPageError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _FullPageError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppColors.limitedRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded,
                  color: AppColors.limitedRed.withValues(alpha: 0.7), size: 30),
            ),
            const SizedBox(height: 16),
            Text('Connection Error',
              style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.darkNeutral,
              )),
            const SizedBox(height: 8),
            Text(message,
              style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.mediumNeutral, height: 1.55,
              ),
              textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Try Again',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  final VoidCallback onClear;
  const _EmptyState({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 48, color: AppColors.mediumNeutral.withValues(alpha: 0.35)),
          const SizedBox(height: 14),
          Text(
            query.isEmpty ? 'No products available' : 'No results for "$query"',
            style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w500,
              color: AppColors.darkNeutral,
            )),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClear,
              child: Text('Clear search',
                style: GoogleFonts.inter(
                    color: AppColors.accent, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}