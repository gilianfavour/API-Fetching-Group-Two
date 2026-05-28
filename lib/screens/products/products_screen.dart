import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../product_detail/product_detail_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// APP COLOR CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF000435);
  static const Color accent = Color(0xFF0EA5E9);
  static const Color darkNeutral = Color(0xFF1E293B);
  static const Color mediumNeutral = Color(0xFF64748B);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color limitedRed = Color(0xFFEF4444);
  static const Color starAmber = Color(0xFFF59E0B);
  static const Color divider = Color(0xFFE2E8F0);
}

// ═══════════════════════════════════════════════════════════════════════════════
// BEAUTIFUL PAGE ROUTE
// ═══════════════════════════════════════════════════════════════════════════════
class _ZoomFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  _ZoomFadeRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            final fadeOut = Tween<double>(
              begin: 1.0,
              end: 0.88,
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeIn,
              ),
            );

            final fadeIn = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
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
  final ProductService _productService = ProductService();

  final List<Product> _products = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;

  String? _error;

  int _currentPage = 1;
  int _lastPage = 1;
  int _totalCount = 0;

  final TextEditingController _searchCtrl = TextEditingController();

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // LOAD PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadPage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _productService.fetchProducts(
        page: _currentPage,
      );

      if (!mounted) return;

      setState(() {
        _products
          ..clear()
          ..addAll(result.products);

        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _totalCount = result.total;

        _isLoading = false;
        _isLoadingMore = false;
      });

      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGINATION
  // ═══════════════════════════════════════════════════════════════════════════
  void _loadNext() {
    if (_currentPage >= _lastPage) return;

    _currentPage++;

    _loadPage();
  }

  void _jumpToPage(int page) {
    if (page == _currentPage) return;

    _currentPage = page;

    _loadPage();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH FILTER
  // ═══════════════════════════════════════════════════════════════════════════
  List<Product> get _visibleProducts {
    final q = _searchCtrl.text.trim().toLowerCase();

    if (q.isEmpty) return _products;

    return _products.where((p) {
      return p.name.toLowerCase().contains(q);
    }).toList();
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
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Products',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    _totalCount > 0
                        ? '$_totalCount items available'
                        : 'Products collection',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              _HeaderIconBtn(
                icon: Icons.tune_rounded,
                onTap: () {},
              ),

              const SizedBox(width: 8),

              _HeaderIconBtn(
                icon: Icons.shopping_bag_outlined,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.09),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.white.withOpacity(0.14),
              ),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.white.withOpacity(0.4),
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.white.withOpacity(0.4),
                        ),
                      )
                    : null,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BODY
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBody() {
    if (_isLoading) {
      return const _FullPageSpinner();
    }

    if (_error != null) {
      return _FullPageError(
        message: _error!,
        onRetry: () {
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
              Text(
                '${products.length} products',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.mediumNeutral,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              Text(
                'Page $_currentPage of $_lastPage',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.mediumNeutral,
                ),
              ),
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
              itemBuilder: (context, index) {
                return _ProductCard(
                  product: products[index],
                  index: index,
                  onTap: () => _openDetail(products[index]),
                );
              },
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
        MediaQuery.of(context).padding.bottom + 16,
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
          children: [
            if (iconLeft) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 4),
            ],

            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            if (!iconLeft) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 18),
            ],
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
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isLastPage ? 'All Products Loaded' : 'Load More',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRODUCT CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _ProductCard extends StatelessWidget {
  final Product product;
  final int index;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
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
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: _ProductImage(
                  imageUrl: product.image,
                  name: product.name,
                ),
              ),
            ),

            Expanded(
              flex: 42,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNeutral,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      product.price,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
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
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.mediumNeutral,
        ),
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
class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 19,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOADING
// ═══════════════════════════════════════════════════════════════════════════════
class _FullPageSpinner extends StatelessWidget {
  const _FullPageSpinner();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
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
            Text(
              message,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
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
      child: Text(
        query.isEmpty
            ? 'No products found'
            : 'No results for "$query"',
      ),
    );
  }
}