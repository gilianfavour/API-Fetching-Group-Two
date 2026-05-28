import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nutriblend_group2/screens/products/products_screen.dart'; 


class HeroBannerItem {
  final String tag;
  final String title;
  final String shortDesc;
  final String fullDesc;
  final String stat;
  final String statSub;
  final String imageUrl;

  const HeroBannerItem({
    required this.tag,
    required this.title,
    required this.shortDesc,
    required this.fullDesc,
    required this.stat,
    required this.statSub,
    required this.imageUrl,
  });
}

class NutriProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final String badge;
  final bool isSale;
  final String imageUrl;
  final String description;

  const NutriProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.badge = '',
    this.isSale = false,
    required this.imageUrl,
    required this.description,
  });
}


const List<HeroBannerItem> _banners = [
  HeroBannerItem(
    tag: 'New Arrivals',
    title: 'Vitamin C Glow\nCollection',
    shortDesc: 'Brighten your skin with our newest serums.',
    fullDesc:
        'Our Vitamin C Glow Collection harnesses pharmaceutical-grade '
        'ascorbic acid blended with hyaluronic acid and niacinamide. '
        'Clinically proven to reduce dark spots by 40 % in 4 weeks. '
        'Over 12 new SKUs just launched.',
    stat: '12 New Products',
    statSub: 'Launched this week',
    imageUrl:
        'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=900&fit=crop',
  ),
  HeroBannerItem(
    tag: 'Best Sellers',
    title: "Editor's Picks\nby NutriBlend",
    shortDesc: "Pharmacist-recommended formulas, 4.8 ★ average.",
    fullDesc:
        'Hand-selected by our in-house pharmacists and dermatologists. '
        'Every product on this list carries 4.8+ stars and thousands of '
        'verified reviews. Free same-day delivery available.',
    stat: '4.9 ★ Avg Rating',
    statSub: 'Across 3,800+ reviews',
    imageUrl:
        'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=900&fit=crop',
  ),
  HeroBannerItem(
    tag: 'Flash Sale',
    title: 'Up to 50 % Off\nSupplements',
    shortDesc: 'Limited-time deals. No coupon needed.',
    fullDesc:
        'Stock up on daily essentials — multivitamins, omega-3s, '
        'probiotics and collagen boosters at up to 50 % off. '
        'Sale ends midnight. Discount applied automatically at checkout.',
    stat: 'Up to 50 % Off',
    statSub: 'Ends midnight tonight',
    imageUrl:
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=900&fit=crop',
  ),
];

const List<NutriProduct> _featured = [
  NutriProduct(
    id: 'p1',
    name: 'Retinol Night Serum',
    category: 'Skin Care',
    price: 34.99,
    badge: 'Hot',
    imageUrl:
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400&fit=crop',
    description:
        '0.5 % retinol formula that visibly reduces fine lines, '
        'uneven texture and dark spots overnight.',
  ),
  NutriProduct(
    id: 'p2',
    name: 'SPF 50 Sunscreen',
    category: 'Skin Care',
    price: 22.00,
    badge: 'Sale',
    isSale: true,
    imageUrl:
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&fit=crop',
    description:
        'Broad-spectrum UVA/UVB protection. Lightweight, non-greasy '
        'finish suitable for all skin types.',
  ),
  NutriProduct(
    id: 'p3',
    name: 'Collagen Booster',
    category: 'Supplements',
    price: 49.99,
    badge: 'New',
    imageUrl:
        'https://images.unsplash.com/photo-1550572017-edd951b55104?w=400&fit=crop',
    description:
        'Marine collagen peptides with vitamin C for improved skin '
        'elasticity and joint support.',
  ),
  NutriProduct(
    id: 'p4',
    name: 'Hyaluronic Acid Gel',
    category: 'Skin Care',
    price: 27.50,
    imageUrl:
        'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400&fit=crop',
    description:
        'Multi-weight hyaluronic acid for deep-layer hydration. '
        'Fragrance-free, suitable for sensitive skin.',
  ),
  NutriProduct(
    id: 'p5',
    name: 'Omega-3 Fish Oil',
    category: 'Pharmaceuticals',
    price: 18.99,
    badge: 'Top',
    imageUrl:
        'https://images.unsplash.com/photo-1559181567-c3190bfbf369?w=400&fit=crop',
    description:
        '1 000 mg EPA/DHA per capsule. Molecularly distilled, '
        'odourless enteric-coated softgels.',
  ),
  NutriProduct(
    id: 'p6',
    name: 'Niacinamide 10 % Toner',
    category: 'Skin Care',
    price: 19.99,
    imageUrl:
        'https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?w=400&fit=crop',
    description:
        'Pore-minimising, oil-controlling daily toner. Pairs with '
        'any serum or moisturiser.',
  ),
  NutriProduct(
    id: 'p7',
    name: 'Probiotic Complex',
    category: 'Pharmaceuticals',
    price: 39.00,
    badge: 'Sale',
    isSale: true,
    imageUrl:
        'https://images.unsplash.com/photo-1576426863848-c21f53c60b19?w=400&fit=crop',
    description:
        '10 billion CFU, 8 clinically studied strains for gut health '
        'and daily immune support.',
  ),
];

// Category accent colours are purely decorative pill tints —
// intentionally NOT in the global ColorScheme.
const List<_Category> _categories = [
  _Category('Skin Care',       Icons.face_retouching_natural, Color(0xFFe0f2fe), Color(0xFF0369a1)),
  _Category('Supplements',     Icons.medication_outlined,      Color(0xFFdcfce7), Color(0xFF15803d)),
  _Category('Pharmaceuticals', Icons.local_pharmacy_outlined,  Color(0xFFfce7f3), Color(0xFFbe185d)),
  _Category('Hair Care',       Icons.dry_cleaning_outlined,    Color(0xFFfef3c7), Color(0xFFb45309)),
  _Category('Vitamins',        Icons.spa_outlined,             Color(0xFFf3e8ff), Color(0xFF7c3aed)),
];

class _Category {
  final String name;
  final IconData icon;
  final Color bg;
  final Color fg;
  const _Category(this.name, this.icon, this.bg, this.fg);
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _slide = 0;
  bool _detailOpen = false;
  Timer? _timer;
  final PageController _pageCtrl = PageController();
  final Set<String> _wishlist = {};

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final next = (_slide + 1) % _banners.length;
      _pageCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _toggleWishlist(NutriProduct p) {
    setState(() => _wishlist.contains(p.id)
        ? _wishlist.remove(p.id)
        : _wishlist.add(p.id));
    _toast(_wishlist.contains(p.id)
        ? '${p.name} added to wishlist'
        : 'Removed from wishlist');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: const StadiumBorder(),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    ));
  }

  void _openProduct(NutriProduct p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _QuickView(
        product: p,
        isFav: _wishlist.contains(p.id),
        onFav: () => _toggleWishlist(p),
      ),
    );
  }

  void _openCategory(String name) {
    // TODO: Navigator.pushNamed(context, '/products', arguments: {'category': name});
    _toast('Browsing $name');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroSection(
            banners: _banners,
            ctrl: _pageCtrl,
            slide: _slide,
            detailOpen: _detailOpen,
            onPageChanged: (i) => setState(() => _slide = i),
            onCta: () => setState(() => _detailOpen = !_detailOpen),
            onClose: () => setState(() => _detailOpen = false),
          ),
          _StatsStrip(),
          _SectionRow(
            title: 'Featured Products',
            linkLabel: 'View all',
            onLink: () {
              // TODO: Navigator.pushNamed(context, '/products');
            },
          ),
          _ProductRow(
            products: _featured,
            wishlist: _wishlist,
            onTap: _openProduct,
            onFav: _toggleWishlist,
          ),
          _SectionRow(title: 'Browse Categories'),
          _CategoryStrip(categories: _categories, onTap: _openCategory),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}


class _HeroSection extends StatelessWidget {
  final List<HeroBannerItem> banners;
  final PageController ctrl;
  final int slide;
  final bool detailOpen;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onCta;
  final VoidCallback onClose;

  const _HeroSection({
    required this.banners,
    required this.ctrl,
    required this.slide,
    required this.detailOpen,
    required this.onPageChanged,
    required this.onCta,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final banner = banners[slide];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Image strip
        SizedBox(
          height: 280,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft:  Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            child: Stack(fit: StackFit.expand, children: [
              // Paged images
              PageView.builder(
                controller: ctrl,
                onPageChanged: onPageChanged,
                itemCount: banners.length,
                itemBuilder: (_, i) => Image.network(
                  banners[i].imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, p) =>
                      p == null ? child : Container(color: cs.primary),
                  errorBuilder: (_, __, ___) =>
                      Container(color: cs.primary),
                ),
              ),

              // Left-to-right dark gradient (keeps left text readable)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      cs.primary.withOpacity(0.88),
                      cs.primary.withOpacity(0.40),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Top-right dark vignette — guarantees badge is always readable
              // regardless of how bright the image is in that corner.
              Positioned(
                top: 0, right: 0,
                child: Container(
                  width: 160, height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.0,
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Stat badge — top right
              Positioned(
                top: 18, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    // Solid dark background so text is always legible
                    color: Colors.black.withOpacity(0.52),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.18), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Featured" label — white so it shows on any image
                      const Text('Featured',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.4)),
                      const SizedBox(height: 3),
                      Text(banner.stat,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      // statSub also white — sky-blue was invisible on bright images
                      Text(banner.statSub,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
              ),

              // ── Text content — bottom left
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: cs.secondary,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          banner.tag.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.3),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        banner.title,
                        style: tt.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.2),
                      ),
                      const SizedBox(height: 5),

                      // Short desc
                      Text(
                        banner.shortDesc,
                        style: tt.bodyMedium
                            ?.copyWith(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 14),

                      // CTA
                      GestureDetector(
                        onTap: onCta,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: detailOpen
                                ? Colors.white24
                                : cs.secondary,
                            borderRadius: BorderRadius.circular(30),
                            border: detailOpen
                                ? Border.all(color: Colors.white38)
                                : null,
                          ),
                          child: Text(
                            detailOpen ? 'Close  ✕' : 'See More  →',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Slide dots — bottom right
              Positioned(
                bottom: 18, right: 16,
                child: Row(
                  children: List.generate(banners.length, (i) {
                    final active = i == slide;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(left: 5),
                      width: active ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? cs.secondary : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ]),
          ),
        ),

        // ── Expandable detail card
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: detailOpen
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  banner.imageUrl,
                  width: 88, height: 82,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 88, height: 82,
                      color: Theme.of(context).scaffoldBackgroundColor),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(banner.title.replaceAll('\n', ' '),
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text(banner.fullDesc,
                        style: tt.bodyMedium
                            ?.copyWith(fontSize: 11, height: 1.6)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: tt.bodyMedium?.color),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}


//  STATS STRIP

class _StatsStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Row(children: [
        _Stat(Icons.inventory_2_outlined,
            cs.secondary.withOpacity(0.12), cs.secondary,  '2 400+', 'Products'),
        const SizedBox(width: 10),
        _Stat(Icons.local_shipping_outlined,
            cs.primary.withOpacity(0.10),  cs.primary,     'Free',   'Ship \$50+'),
        const SizedBox(width: 10),
        _Stat(Icons.star_outline_rounded,
            const Color(0xFFdcfce7),        const Color(0xFF16a34a), '4.8★', 'Avg Rating'),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconFg;
  final String value, label;
  const _Stat(this.icon, this.iconBg, this.iconFg, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Column(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: iconFg, size: 17),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: tt.titleMedium
                  ?.copyWith(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: tt.bodyMedium?.copyWith(fontSize: 10)),
        ]),
      ),
    );
  }
}


class _SectionRow extends StatelessWidget {
  final String title;
  final String? linkLabel;
  final VoidCallback? onLink;
  const _SectionRow({required this.title, this.linkLabel, this.onLink});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: tt.titleMedium
                  ?.copyWith(fontSize: 16, fontWeight: FontWeight.w800)),
          if (linkLabel != null && onLink != null)
            GestureDetector(
              onTap: onLink,
              child: Text('$linkLabel →',
                  style: TextStyle(
                      fontSize: 13,
                      color: cs.secondary,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}


//  PRODUCT ROW  (horizontal scroll)

class _ProductRow extends StatelessWidget {
  final List<NutriProduct> products;
  final Set<String> wishlist;
  final ValueChanged<NutriProduct> onTap;
  final ValueChanged<NutriProduct> onFav;

  const _ProductRow({
    required this.products,
    required this.wishlist,
    required this.onTap,
    required this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 218,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (_, i) => _ProductCard(
          product: products[i],
          isFav: wishlist.contains(products[i].id),
          onTap: () => onTap(products[i]),
          onFav: () => onFav(products[i]),
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final NutriProduct product;
  final bool isFav;
  final VoidCallback onTap;
  final VoidCallback onFav;
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
      vsync: this, duration: const Duration(milliseconds: 110));
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p  = widget.product;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 148,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Image + badge
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18)),
              child: Stack(children: [
                Image.network(p.imageUrl,
                    width: 148, height: 112, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 148, height: 112,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Icon(Icons.image_outlined,
                            color: tt.bodyMedium?.color))),
                if (p.badge.isNotEmpty)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: p.isSale
                            ? const Color(0xFFE11D48)
                            : cs.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(p.badge,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ]),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleMedium?.copyWith(
                        fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(p.category,
                    style: tt.bodyMedium?.copyWith(fontSize: 10)),
                const SizedBox(height: 7),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  // Uses titleSmall (Inter bold + primary colour from main.dart)
                  Text('\$${p.price.toStringAsFixed(2)}',
                      style: tt.titleSmall?.copyWith(fontSize: 13)),
                  GestureDetector(
                    onTap: widget.onFav,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: widget.isFav
                            ? const Color(0xFFfce7f3)
                            : Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.black.withOpacity(0.08)),
                      ),
                      child: Icon(
                        widget.isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 14,
                        color: widget.isFav
                            ? Colors.pinkAccent
                            : tt.bodyMedium?.color,
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}


//  CATEGORY STRIP

class _CategoryStrip extends StatelessWidget {
  final List<_Category> categories;
  final ValueChanged<String> onTap;
  const _CategoryStrip({required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                  color: c.bg, borderRadius: BorderRadius.circular(30)),
              child: Row(children: [
                Icon(c.icon, size: 15, color: c.fg),
                const SizedBox(width: 6),
                Text(c.name,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c.fg)),
              ]),
            ),
          );
        },
      ),
    );
  }
}


//  PRODUCT QUICK-VIEW BOTTOM SHEET

class _QuickView extends StatelessWidget {
  final NutriProduct product;
  final bool isFav;
  final VoidCallback onFav;
  const _QuickView({
    required this.product,
    required this.isFav,
    required this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
          color: cs.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(26))),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Handle
        Center(
          child: Container(
              width: 38, height: 4,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 18),

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(product.imageUrl,
                width: 88, height: 88, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: 88, height: 88,
                    color: Theme.of(context).scaffoldBackgroundColor)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, style: tt.titleMedium),
              const SizedBox(height: 3),
              Text(product.category, style: tt.bodyMedium),
              const SizedBox(height: 8),
              // titleSmall = Inter bold + primary colour from main.dart
              Text('\$${product.price.toStringAsFixed(2)}',
                  style: tt.titleSmall?.copyWith(fontSize: 22)),
            ]),
          ),
        ]),

        const SizedBox(height: 14),
        Text(product.description,
            style: tt.bodyMedium?.copyWith(height: 1.65)),
        const SizedBox(height: 22),

        Row(children: [
          // Outline wishlist button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onFav,
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 16,
                color: isFav ? Colors.pinkAccent : cs.primary,
              ),
              label: Text(isFav ? 'Saved' : 'Wishlist'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isFav ? Colors.pinkAccent : cs.primary,
                side: BorderSide(
                    color: isFav ? Colors.pinkAccent : cs.primary),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filled CTA — inherits ElevatedButtonTheme from main.dart
          Expanded(
            flex: 2,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close the bottom sheet first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductsScreen(),
                    ),
                  );
                },
                child: const Text('View Products →'),
              ),
          ),
        ]),
      ]),
    );
  }
}