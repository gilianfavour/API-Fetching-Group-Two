import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutriblend_group2/checkout/checkout_screen.dart';
import 'package:nutriblend_group2/screens/product_detail/product_detail_screen.dart';
import '../../../widgets/common/app_bar.dart';
import '../../../widgets/common/navigation_bar.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// APP COLOR CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF000435);
  static const Color accent = Color(0xFF000435);
  static const Color darkNeutral = Color(0xFF1E293B);
  static const Color mediumNeutral = Color(0xFF64748B);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color limitedRed = Color(0xFFEF4444);
  static const Color starAmber = Color(0xFFF59E0B);
  static const Color divider = Color(0xFFE2E8F0);
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
            final fadeOut = Tween<double>(begin: 1.0, end: 0.88).animate(
              CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
            );

            final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

            final scaleIn = Tween<double>(
              begin: 0.88,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            return FadeTransition(
              opacity: fadeOut,
              child: FadeTransition(
                opacity: fadeIn,
                child: ScaleTransition(
                  scale: scaleIn,
                  child: child,
                ),
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

class _ProductPageState extends State<ProductPage>
    with TickerProviderStateMixin {
  final List<Product> _products = [];
  final ProductService _productService = ProductService();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  int _currentPage = 1;
  int _lastPage = 6;

  final TextEditingController _searchCtrl = TextEditingController();

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeIn,
  );

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

  Future<void> _loadPage({bool loadMore = false}) async {
    if (!mounted) return;

    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _productService.fetchProducts(
        page: _currentPage,
      );

      if (!mounted) return;

      setState(() {
        if (loadMore) {
          _products.addAll(result.products);
        } else {
          _products
            ..clear()
            ..addAll(result.products);
        }
        _lastPage = result.lastPage;
        _isLoading = false;
        _isLoadingMore = false;
      });

      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'Could not load products.\nCheck your connection and try again.';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }
  // PAGINATION
  // ═══════════════════════════════════════════════════════════════════════════
  void _loadNext() {
    if (_isLoadingMore || _isLoading || _currentPage >= _lastPage) return;
    _currentPage++;
    _loadPage(loadMore: true);
  }

  void _jumpToPage(int page) {
    if (page == _currentPage || _isLoading) return;
    _currentPage = page;
    _loadPage();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH FILTER
  // ═══════════════════════════════════════════════════════════════════════════
  List<Product> get _visibleProducts {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _products;
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            (p.brand?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OPEN DETAILS
  // ═══════════════════════════════════════════════════════════════════════════
  void _openDetail(Product product) {
    Navigator.push(
      context,
      _ZoomFadeRoute(
        page: ProductDetailPage(product: product),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutPage()),
    );
  }

  void _onNavBarTap(int index) {
    switch (index) {
      case 0:
        Navigator.pop(context);
        break;
      case 1:
        // Already on Products
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile page coming soon')),
        );
        break;
    }
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
            CustomTopBar(
              onCartTap: _navigateToCart,
              cartCount: 0,
            ),
            Expanded(
              child: _buildBody(),
            ),
            CustomBottomNavBar(
              currentIndex: 1,
              onTap: _onNavBarTap,
            ),
          ],
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const _FullPageSpinner();
    }

    if (_error != null) {
      return _FullPageError(
        message: _error!,
        onRetry: () {
          _currentPage = 1;
          _loadPage();
        },
      );
    }

    final products = _visibleProducts;

    if (products.isEmpty) {
      return _EmptyState(
        query: _searchCtrl.text,
        onClear: () {
          _searchCtrl.clear();
          setState(() {});
        },
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
                    fontSize: 12,
                    color: AppColors.mediumNeutral,
                    fontWeight: FontWeight.w500,
                  )),
              const Spacer(),
              Text('Page $_currentPage of $_lastPage',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.mediumNeutral,
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
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.58,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) => _ProductCard(
                product: products[index],
                index: index,
                onTap: () => _openDetail(products[index]),
              ),
            ),
          ),
        ),

        _buildPaginationSection(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGINATION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPaginationSection() {
    return Container(
      color: AppColors.lightBg,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        16,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_lastPage, (i) {
              final pageNum = i + 1;
              final active = pageNum == _currentPage;
              return GestureDetector(
                onTap: () => _jumpToPage(pageNum),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 14),
          Row(
            children: [
              if (_currentPage > 1)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _PrevNextButton(
                      label: 'Prev',
                      icon: Icons.keyboard_arrow_left_rounded,
                      iconLeft: true,
                      onTap: () {
                        _jumpToPage(_currentPage - 1);
                      },
                    ),
                  ),
                ),
              Expanded(
                flex: 3,
                child: _LoadMoreButton(
                  isLoading: _isLoadingMore,
                  isLastPage: _currentPage >= _lastPage,
                  onTap: _loadNext,
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
// PREV BUTTON
// ═══════════════════════════════════════════════════════════════════════════════
class _PrevNextButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool iconLeft;
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
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.4),
          ),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      )),
                ]
              : [
                  Text(label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
// LOAD MORE BUTTON
// ═══════════════════════════════════════════════════════════════════════════════
class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final bool isLastPage;
  final VoidCallback onTap;

  const _LoadMoreButton({
    required this.isLoading,
    required this.isLastPage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: (isLastPage || isLoading) ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : isLastPage
                ? Text('All products loaded',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Load More',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    ],
                  ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRODUCT CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _ProductCard extends StatefulWidget {
  final Product product;
  final int index;
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
    _pressCtrl.animateTo(
      0.93,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeIn,
    );
  }

  void _onTapUp(TapUpDetails _) => _relax();
  void _onTapCancel() => _relax();

  void _relax() {
    _pressCtrl.animateTo(
      1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.elasticOut,
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
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          imageUrl: widget.product.image,
                          name: widget.product.name,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.88),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.favorite_border_rounded,
                            size: 15, color: AppColors.mediumNeutral),
                      ),
                    ),
                    if (widget.product.isLimited)
                      Positioned(
                        top: 10,
                        left: 10,
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
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text('Only ${widget.product.stockQuantity} left',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 42,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.product.brand != null)
                            Text(
                              widget.product.brand!.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 2),
                          Text(
                            widget.product.name,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkNeutral,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ...List.generate(
                              5,
                              (i) => Icon(
                                    i < widget.product.rating.round()
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 11,
                                    color: AppColors.starAmber,
                                  )),
                          const SizedBox(width: 4),
                          Text('(${widget.product.reviewCount})',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.mediumNeutral,
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.price,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
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
  final String name;

  const _ProductImage({
    this.imageUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,

        errorBuilder: (context, error, stackTrace) {
          return _placeholder();
        },

        loadingBuilder: (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer() {
    return Container(
      color: const Color(0xFFEFF6F0),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER BUTTON
// ═══════════════════════════════════════════════════════════════════════════════
class _FullPageSpinner extends StatelessWidget {
  const _FullPageSpinner();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 38,
            height: 38,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text('Fetching products…',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.mediumNeutral,
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERROR
// ═══════════════════════════════════════════════════════════════════════════════
class _FullPageError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FullPageError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
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
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkNeutral,
                )),
            const SizedBox(height: 8),
            Text(message,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.mediumNeutral,
                  height: 1.55,
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

// ═══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _EmptyState({
    required this.query,
    required this.onClear,
  });

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
              query.isEmpty
                  ? 'No products available'
                  : 'No results for "$query"',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.darkNeutral,
              )),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClear,
              child: Text('Clear search',
                  style:
                      GoogleFonts.inter(color: AppColors.accent, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}
