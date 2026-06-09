import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/notification_helper.dart';
import '../../models/product_model.dart';
import '../cart/cart_screen.dart';
import '../products/products_screen.dart';
import '../product_detail/product_detail_screen.dart';
import '../../widgets/loading/shimmer_skeleton.dart';
import '../../widgets/loading/shimmer.dart';
import '../../profile/profile.dart';
import '../../widgets/common/navigation_bar.dart';
import '../../screens/wishlist/wishlist_screen.dart';

// ══════════════════════════════════════════════
// CONSTANTS
// ══════════════════════════════════════════════
const _kNavy = Color(0xFF000435);
const _kBlue = Color(0xFF1A56DB);
const _kLightBlue = Color(0xFFEEF3FF);
const _kAccent = Color(0xFF3B82F6);

// ══════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════
class HeroBannerItem {
  final String tag, title, shortDesc, fullDesc, stat, statSub, imageUrl;
  final Color accentColor;
  const HeroBannerItem({
    required this.tag,
    required this.title,
    required this.shortDesc,
    required this.fullDesc,
    required this.stat,
    required this.statSub,
    required this.imageUrl,
    this.accentColor = _kAccent,
  });
}

class _Category {
  final String name;
  final IconData icon;
  final Color bg, fg;
  const _Category(this.name, this.icon, this.bg, this.fg);
}

class _PromoCard {
  final String label, title, sub, cta;
  final Color bg, fg;
  final IconData icon;
  const _PromoCard(
      this.label, this.title, this.sub, this.cta, this.bg, this.fg, this.icon);
}

// ══════════════════════════════════════════════
// DATA
// ══════════════════════════════════════════════
const List<HeroBannerItem> _banners = [
  HeroBannerItem(
    tag: 'New Arrivals',
    title: 'Vitamin C\nGlow Collection',
    shortDesc: 'Clinically proven to reduce dark spots by 40% in 4 weeks.',
    fullDesc:
        'Our Vitamin C Glow Collection harnesses pharmaceutical-grade ascorbic acid '
        'blended with hyaluronic acid and niacinamide. Clinically proven to reduce '
        'dark spots by 40% in 4 weeks. Over 12 new SKUs just launched.',
    stat: '12 New Products',
    statSub: 'Launched this week',
    imageUrl:
        'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=900&fit=crop',
    accentColor: Color(0xFF6366F1),
  ),
  HeroBannerItem(
    tag: 'Best Sellers',
    title: "Editor's Picks\nby NutriBlend",
    shortDesc: "Pharmacist-recommended formulas, 4.8★ average.",
    fullDesc: 'Hand-selected by our in-house pharmacists and dermatologists. '
        'Every product carries 4.8+ stars and thousands of verified reviews.',
    stat: '4.9★ Avg Rating',
    statSub: 'Across 3,800+ reviews',
    imageUrl:
        'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=900&fit=crop',
    accentColor: Color(0xFF059669),
  ),
  HeroBannerItem(
    tag: 'Flash Sale',
    title: 'Up to 50% Off\nSupplements',
    shortDesc: 'Limited-time deals. Discount applied automatically.',
    fullDesc:
        'Stock up on daily essentials — multivitamins, omega-3s, probiotics '
        'and collagen boosters at up to 50% off. Sale ends midnight.',
    stat: 'Up to 50% Off',
    statSub: 'Ends midnight tonight',
    imageUrl:
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=900&fit=crop',
    accentColor: Color(0xFFDC2626),
  ),
];

const List<_Category> _categories = [
  _Category('Skin Care', Icons.face_retouching_natural, Color(0xFFEDE9FE),
      Color(0xFF7C3AED)),
  _Category('Supplements', Icons.medication_outlined, Color(0xFFD1FAE5),
      Color(0xFF059669)),
  _Category('Pharma', Icons.local_pharmacy_outlined, Color(0xFFDBEAFE),
      Color(0xFF1D4ED8)),
  _Category('Hair Care', Icons.dry_cleaning_outlined, Color(0xFFFEF3C7),
      Color(0xFFB45309)),
  _Category(
      'Vitamins', Icons.spa_outlined, Color(0xFFFFE4E6), Color(0xFFBE123C)),
  _Category('Personal Care', Icons.self_improvement_outlined, Color(0xFFE0F2FE),
      Color(0xFF0369A1)),
];

const List<_PromoCard> _promos = [
  _PromoCard(
    'Free Delivery',
    'On Orders\nOver \$50',
    'No coupon needed',
    'Shop Now',
    Color(0xFFEEF3FF),
    _kNavy,
    Icons.local_shipping_outlined,
  ),
  _PromoCard(
    'Loyalty Points',
    'Earn & Redeem\nRewards',
    '1 point per \$1 spent',
    'Learn More',
    Color(0xFFFFF7ED),
    Color(0xFF92400E),
    Icons.card_giftcard_outlined,
  ),
];

// ══════════════════════════════════════════════
// HOME PAGE
// ══════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _slide = 0;
  bool _isLoading = true;
  Timer? _timer;
  final PageController _pageCtrl = PageController();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final next = (_slide + 1) % _banners.length;
      _pageCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshHome() async {
    setState(() => _isLoading = true);
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  void _toast(String msg, {bool success = true}) =>
      showTopNotification(context, msg, isSuccess: success);

  void _openProduct(Product p) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)));

  void _navigateToCart() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const CartScreen()));

  void _navigateToProducts({String? category}) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const ProductPage()));

  void _onNavBarTap(int index) {
    switch (index) {
      case 0:
        break; // Already on Home
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ProductPage()));
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    const WishlistScreen())); // ← your wishlist screen
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
  }

  // ── Shimmer skeleton
  Widget _buildShimmer() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(cartCount: 0, isShimmer: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // search shimmer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AppShimmer(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppShimmer(
            child: Container(
              height: 260,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                children: List.generate(
                    3,
                    (i) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                            child: AppShimmer(
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ))),
          ),
          const SizedBox(height: 24),
          const HorizontalProductShimmer(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      {required int cartCount, bool isShimmer = false}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kNavy,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.local_pharmacy, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'NutriBlend',
              style: TextStyle(
                color: _kNavy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Health & Pharmacy',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ]),
      ),
      actions: [
        if (!isShimmer)
          IconButton(
            onPressed: () {},
            icon: Stack(children: [
              Icon(Icons.notifications_outlined, color: _kNavy, size: 24),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ]),
          ),
        if (!isShimmer)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: _navigateToCart,
                icon:
                    Icon(Icons.shopping_cart_checkout_outlined, color: _kNavy, size: 24),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 219, 49, 26),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cartCount > 9 ? '9+' : '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.grey.withOpacity(0.1), height: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalQuantity;

    if (_isLoading) return _buildShimmer();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(cartCount: cartCount),
      body: RefreshIndicator(
        onRefresh: _refreshHome,
        color: _kNavy,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // ── Search Bar
            SliverToBoxAdapter(
                child: _SearchBar(
                    ctrl: _searchCtrl,
                    onSearch: (q) => _toast('Searching: $q'))),

            // ── Hero Carousel
            SliverToBoxAdapter(
              child: _HeroCarousel(
                banners: _banners,
                ctrl: _pageCtrl,
                slide: _slide,
                onPageChanged: (i) => setState(() => _slide = i),
                onShop: _navigateToProducts,
              ),
            ),

            // ── Promo Cards
            SliverToBoxAdapter(
              child: _PromoRow(
                  promos: _promos, onTap: (_) => _navigateToProducts()),
            ),

            // ── Category Grid
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Shop by Category',
                onAction: _navigateToProducts,
              ),
            ),
            SliverToBoxAdapter(
              child: _CategoryGrid(
                categories: _categories,
                onTap: (name) => _navigateToProducts(category: name),
              ),
            ),

            // ── Featured Products
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Featured Products',
                actionLabel: 'View all',
                onAction: _navigateToProducts,
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer2<ProductProvider, WishlistProvider>(
                builder: (context, productProd, wishlistProd, _) {
                  if (productProd.isLoading && productProd.products.isEmpty) {
                    return const HorizontalProductShimmer();
                  }
                  return _FeaturedProductsRow(
                    products: productProd.products,
                    wishlistProvider: wishlistProd,
                    onTap: _openProduct,
                    onFav: (p) {
                      final isFav = wishlistProd.contains(p.id);
                      wishlistProd.toggleWishlist(p);
                      _toast(
                        isFav
                            ? '${p.name} removed from wishlist'
                            : '${p.name} added to wishlist',
                        success: !isFav,
                      );
                    },
                  );
                },
              ),
            ),

            // ── Best Sellers (second row — filtered/sorted if needed)
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Best Sellers',
                actionLabel: 'See all',
                onAction: _navigateToProducts,
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer2<ProductProvider, WishlistProvider>(
                builder: (context, productProd, wishlistProd, _) {
                  if (productProd.isLoading && productProd.products.isEmpty) {
                    return const HorizontalProductShimmer();
                  }
                  // Reverse list as a "different" set — replace with actual bestsellers query
                  final best = productProd.products.reversed.toList();
                  return _FeaturedProductsRow(
                    products: best,
                    wishlistProvider: wishlistProd,
                    onTap: _openProduct,
                    onFav: (p) {
                      final isFav = wishlistProd.contains(p.id);
                      wishlistProd.toggleWishlist(p);
                      _toast(
                        isFav
                            ? '${p.name} removed from wishlist'
                            : '${p.name} added to wishlist',
                        success: !isFav,
                      );
                    },
                  );
                },
              ),
            ),

            // ── Trust Banner
            const SliverToBoxAdapter(child: _TrustBanner()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: _onNavBarTap,
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SEARCH BAR
// ══════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final ValueChanged<String> onSearch;
  const _SearchBar({required this.ctrl, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: ctrl,
          onSubmitted: onSearch,
          style: const TextStyle(fontSize: 14, color: _kNavy),
          decoration: InputDecoration(
            hintText: 'Search medicines, vitamins, supplements…',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon:
                Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// HERO CAROUSEL
// ══════════════════════════════════════════════
class _HeroCarousel extends StatelessWidget {
  final List<HeroBannerItem> banners;
  final PageController ctrl;
  final int slide;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onShop;

  const _HeroCarousel({
    required this.banners,
    required this.ctrl,
    required this.slide,
    required this.onPageChanged,
    required this.onShop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: ctrl,
            onPageChanged: onPageChanged,
            itemCount: banners.length,
            itemBuilder: (_, i) =>
                _HeroSlide(banner: banners[i], onShop: onShop),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final active = i == slide;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? _kNavy : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final HeroBannerItem banner;
  final VoidCallback onShop;
  const _HeroSlide({required this.banner, required this.onShop});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(fit: StackFit.expand, children: [
        Image.network(
          banner.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, p) =>
              p == null ? child : Container(color: _kNavy),
          errorBuilder: (_, __, ___) => Container(color: _kNavy),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                _kNavy.withOpacity(0.93),
                _kNavy.withOpacity(0.55),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          top: 14,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: banner.accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              banner.tag.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                banner.stat,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                banner.statSub,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 9,
                ),
              ),
            ]),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              banner.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              banner.shortDesc,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onShop,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    'Shop Now',
                    style: TextStyle(
                      color: _kNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: _kNavy),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final String value, label;
  const _StatTile({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: fg, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// PROMO CARDS
// ══════════════════════════════════════════════
class _PromoRow extends StatelessWidget {
  final List<_PromoCard> promos;
  final ValueChanged<_PromoCard> onTap;
  const _PromoRow({required this.promos, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: promos.asMap().entries.map((e) {
          final promo = e.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(promo),
              child: Container(
                margin:
                    EdgeInsets.only(right: e.key < promos.length - 1 ? 10 : 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: promo.bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: promo.fg.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(promo.icon, size: 18, color: promo.fg),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo.label,
                            style: TextStyle(
                              color: promo.fg.withOpacity(0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          Text(
                            promo.title,
                            style: TextStyle(
                              color: promo.fg,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                        ]),
                  ),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SECTION HEADER
// ══════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _kNavy,
              letterSpacing: -0.3,
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _kLightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _kBlue,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 13, color: _kBlue),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// CATEGORY GRID (2-column scrolling chips)
// ══════════════════════════════════════════════
class _CategoryGrid extends StatelessWidget {
  final List<_Category> categories;
  final ValueChanged<String> onTap;
  const _CategoryGrid({required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final c = categories[i];
          return GestureDetector(
            onTap: () => onTap(c.name),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: c.fg.withOpacity(0.15)),
              ),
              child: Row(children: [
                Icon(c.icon, size: 15, color: c.fg),
                const SizedBox(width: 7),
                Text(
                  c.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.fg,
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════
// FEATURED PRODUCTS ROW
// ══════════════════════════════════════════════
class _FeaturedProductsRow extends StatelessWidget {
  final List<Product> products;
  final WishlistProvider wishlistProvider;
  final ValueChanged<Product> onTap;
  final ValueChanged<Product> onFav;

  const _FeaturedProductsRow({
    required this.products,
    required this.wishlistProvider,
    required this.onTap,
    required this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const HorizontalProductShimmer();
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return _ProductCard(
            product: p,
            isFav: wishlistProvider.contains(p.id),
            onTap: () => onTap(p),
            onFav: () => onFav(p),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════
// PRODUCT CARD
// ══════════════════════════════════════════════
class _ProductCard extends StatefulWidget {
  final Product product;
  final bool isFav;
  final VoidCallback onTap, onFav;
  const _ProductCard({
    required this.product,
    required this.isFav,
    required this.onTap,
    required this.onFav,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.96)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 155,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Image
            Stack(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  p.image,
                  width: 155,
                  height: 118,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 155,
                    height: 118,
                    color: const Color(0xFFF5F7FA),
                    child: const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                ),
              ),
              if (p.isLimited)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'LIMITED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: widget.onFav,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: widget.isFav
                          ? const Color(0xFFFFE4E6)
                          : Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 15,
                      color: widget.isFav
                          ? const Color(0xFFBE123C)
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ]),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.brand != null)
                      Text(
                        p.brand!.toUpperCase(),
                        style: const TextStyle(
                          color: _kBlue,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          p.price,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _kNavy,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _kNavy,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// TRUST BANNER
// ══════════════════════════════════════════════
class _TrustBanner extends StatelessWidget {
  const _TrustBanner();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.verified_outlined, 'Genuine Products', '100% Authentic'),
      (Icons.support_agent_outlined, '24/7 Support', 'Always here'),
      (Icons.lock_outline_rounded, 'Secure Checkout', 'SSL Encrypted'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: _kNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Expanded(
            child: Row(children: [
              Expanded(
                child: Column(children: [
                  Icon(item.$1, color: Colors.white70, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.$3,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 9,
                    ),
                  ),
                ]),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.15),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                ),
            ]),
          );
        }).toList(),
      ),
    );
  }
}
