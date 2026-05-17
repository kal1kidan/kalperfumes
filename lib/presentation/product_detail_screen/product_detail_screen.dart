import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/fragrance_notes_widget.dart';
import './widgets/product_cta_widget.dart';
import './widgets/product_hero_image_widget.dart';
import './widgets/product_info_header_widget.dart';
import './widgets/size_selector_widget.dart';
import './widgets/thumbnail_strip_widget.dart';

// TODO: Replace with Riverpod/Bloc for production

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  String _selectedSize = '50ml';
  bool _isWishlisted = false;
  int _cartCount = 0;

  final List<Map<String, dynamic>> _productImageMaps = [
    {
      'url':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1ed71a95d-1772385746267.png',
      'semanticLabel':
          'Noir de Kal perfume bottle front view on dark marble with dramatic lighting',
    },
    {
      'url':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1ccd022d9-1772614920339.png',
      'semanticLabel':
          'Noir de Kal perfume bottle side angle showcasing crystal facets',
    },
    {
      'url':
          'https://images.unsplash.com/photo-1703681036028-b4dbb8811230',
      'semanticLabel':
          'Noir de Kal perfume bottle with cap removed showing golden spray nozzle',
    },
    {
      'url':
          'https://images.unsplash.com/photo-1630512873199-6b2d23e7d99a',
      'semanticLabel':
          'Noir de Kal perfume bottle on white marble with silk fabric background',
    },
  ];

  late List<ProductImage> _productImages;

  final Map<String, dynamic> _productData = {
    'id': 'noir-de-kal',
    'name': 'Noir de Kal',
    'subtitle': 'Woody Oriental Eau de Parfum',
    'price': 285.0,
    'originalPrice': 340.0,
    'rating': 4.8,
    'reviewCount': 312,
    'stockCount': 3,
    'description':
        'A masterful composition that opens with the cool freshness of black pepper and bergamot, evolving into a rich heart of leather and oud wood, finally settling into a mesmerizing base of vetiver, amber, and musk. Noir de Kal is an ode to the mysterious night.',
    'sizes': ['30ml', '50ml', '100ml'],
    'topNotes': ['Black Pepper', 'Bergamot', 'Cardamom'],
    'heartNotes': ['Leather', 'Oud Wood', 'Iris'],
    'baseNotes': ['Vetiver', 'Amber', 'White Musk', 'Sandalwood'],
    'ingredients': 'Alcohol Denat., Parfum (Fragrance), Aqua (Water)',
    'gender': 'Men',
  };

  @override
  void initState() {
    super.initState();
    _productImages = _productImageMaps.map(ProductImage.fromMap).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(
          bottom: false,
          child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return Stack(
      children: [
        // Scrollable content
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom AppBar
            SliverToBoxAdapter(child: _buildDetailAppBar()),

            // Hero image
            SliverToBoxAdapter(
              child: ProductHeroImageWidget(
                images: _productImages,
                selectedIndex: _selectedImageIndex,
                onImageChanged: (index) =>
                    setState(() => _selectedImageIndex = index),
              ),
            ),

            // Thumbnail strip
            SliverToBoxAdapter(
              child: ThumbnailStripWidget(
                images: _productImages,
                selectedIndex: _selectedImageIndex,
                onThumbnailTap: (index) =>
                    setState(() => _selectedImageIndex = index),
              ),
            ),

            // Product info header
            SliverToBoxAdapter(
              child: ProductInfoHeaderWidget(
                name: _productData['name'] as String,
                subtitle: _productData['subtitle'] as String,
                price: _productData['price'] as double,
                originalPrice: _productData['originalPrice'] as double,
                rating: _productData['rating'] as double,
                reviewCount: _productData['reviewCount'] as int,
                stockCount: _productData['stockCount'] as int,
                isWishlisted: _isWishlisted,
                onWishlistToggle: () =>
                    setState(() => _isWishlisted = !_isWishlisted),
              ),
            ),

            // Size selector
            SliverToBoxAdapter(
              child: SizeSelectorWidget(
                sizes: (_productData['sizes'] as List).cast<String>(),
                selectedSize: _selectedSize,
                onSizeSelected: (size) => setState(() => _selectedSize = size),
              ),
            ),

            // Description
            SliverToBoxAdapter(child: _buildDescription()),

            // Fragrance notes
            SliverToBoxAdapter(
              child: FragranceNotesWidget(
                topNotes: (_productData['topNotes'] as List).cast<String>(),
                heartNotes: (_productData['heartNotes'] as List).cast<String>(),
                baseNotes: (_productData['baseNotes'] as List).cast<String>(),
              ),
            ),

            // Space for sticky CTA
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),

        // Sticky CTA at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ProductCtaWidget(
            onAddToCart: _handleAddToCart,
            onBuyNow: _handleBuyNow,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Left — images
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildDetailAppBar(),
                ProductHeroImageWidget(
                  images: _productImages,
                  selectedIndex: _selectedImageIndex,
                  onImageChanged: (index) =>
                      setState(() => _selectedImageIndex = index),
                ),
                ThumbnailStripWidget(
                  images: _productImages,
                  selectedIndex: _selectedImageIndex,
                  onThumbnailTap: (index) =>
                      setState(() => _selectedImageIndex = index),
                ),
              ],
            ),
          ),
        ),
        // Right — info
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductInfoHeaderWidget(
                      name: _productData['name'] as String,
                      subtitle: _productData['subtitle'] as String,
                      price: _productData['price'] as double,
                      originalPrice: _productData['originalPrice'] as double,
                      rating: _productData['rating'] as double,
                      reviewCount: _productData['reviewCount'] as int,
                      stockCount: _productData['stockCount'] as int,
                      isWishlisted: _isWishlisted,
                      onWishlistToggle: () =>
                          setState(() => _isWishlisted = !_isWishlisted),
                    ),
                    SizeSelectorWidget(
                      sizes: (_productData['sizes'] as List).cast<String>(),
                      selectedSize: _selectedSize,
                      onSizeSelected: (size) =>
                          setState(() => _selectedSize = size),
                    ),
                    _buildDescription(),
                    FragranceNotesWidget(
                      topNotes: (_productData['topNotes'] as List)
                          .cast<String>(),
                      heartNotes: (_productData['heartNotes'] as List)
                          .cast<String>(),
                      baseNotes: (_productData['baseNotes'] as List)
                          .cast<String>(),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ProductCtaWidget(
                  onAddToCart: _handleAddToCart,
                  onBuyNow: _handleBuyNow,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.espresso,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Product details',
            style: GoogleFonts.playfairDisplay(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.espresso,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'more_vert',
                color: AppTheme.espresso,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The Story',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.espresso,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _productData['description'] as String,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.muted,
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart() {
    // TODO: Replace with Riverpod/Bloc for production
    setState(() => _cartCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Added to cart — $_selectedSize',
              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppTheme.accentLight,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cartScreen),
        ),
      ),
    );
  }

  void _handleBuyNow() {
    Navigator.pushNamed(context, AppRoutes.cartScreen);
  }
}

// ── Data Model ────────────────────────────────────────────────

class ProductImage {
  final String url;
  final String semanticLabel;

  ProductImage({required this.url, required this.semanticLabel});

  factory ProductImage.fromMap(Map<String, dynamic> map) => ProductImage(
    url: map['url'] as String,
    semanticLabel: map['semanticLabel'] as String,
  );

  Map<String, dynamic> toMap() => {'url': url, 'semanticLabel': semanticLabel};
}
