import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/cart_item_widget.dart';
import './widgets/coupon_row_widget.dart';
import './widgets/order_summary_widget.dart';

// TODO: Replace with Riverpod/Bloc for production

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _cartItemMaps = [
    {
      'id': 'noir-de-kal',
      'name': 'Noir de Kal',
      'subtitle': 'Woody Oriental',
      'size': '50ml',
      'price': 285.0,
      'quantity': 1,
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1faeffcd2-1775695890884.png',
      'semanticLabel':
          'Noir de Kal dark luxury perfume bottle thumbnail for cart',
    },
    {
      'id': 'amber-silk',
      'name': 'Amber Silk',
      'subtitle': 'Floral Amber',
      'size': '100ml',
      'price': 195.0,
      'quantity': 1,
      'imageUrl':
          'https://images.unsplash.com/photo-1659006026407-af59b9046ce3',
      'semanticLabel':
          'Amber Silk warm golden perfume bottle thumbnail for cart',
    },
    {
      'id': 'midnight-orchid',
      'name': 'Midnight Orchid',
      'subtitle': 'Floral Oriental',
      'size': '30ml',
      'price': 360.0,
      'quantity': 1,
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_12b1414d4-1772472764991.png',
      'semanticLabel':
          'Midnight Orchid deep purple perfume bottle thumbnail for cart',
    },
  ];

  late List<CartItem> _cartItems;
  final TextEditingController _couponController = TextEditingController();
  bool _couponApplied = true;
  final String _appliedCoupon = 'KAL2026';
  final double _deliveryFee = 13.0;
  final double _discountAmount = 55.0;

  @override
  void initState() {
    super.initState();
    _cartItems = _cartItemMaps.map(CartItem.fromMap).toList();
    _couponController.text = _appliedCoupon;
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  double get _subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  double get _total =>
      _subtotal + _deliveryFee - (_couponApplied ? _discountAmount : 0);

  void _incrementQty(int index) {
    // TODO: Replace with Riverpod/Bloc for production
    setState(
      () => _cartItems[index] = _cartItems[index].copyWith(
        quantity: _cartItems[index].quantity + 1,
      ),
    );
  }

  void _decrementQty(int index) {
    // TODO: Replace with Riverpod/Bloc for production
    if (_cartItems[index].quantity > 1) {
      setState(
        () => _cartItems[index] = _cartItems[index].copyWith(
          quantity: _cartItems[index].quantity - 1,
        ),
      );
    }
  }

  void _removeItem(int index) {
    // TODO: Replace with Riverpod/Bloc for production
    final removedItem = _cartItems[index];
    setState(() => _cartItems.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${removedItem.name} removed from cart',
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppTheme.accentLight,
          onPressed: () {
            setState(() => _cartItems.insert(index, removedItem));
          },
        ),
      ),
    );
  }

  void _handleCheckout() {
    // TODO: Replace with Riverpod/Bloc for production
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CheckoutConfirmSheet(total: _total),
    );
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
          child: isTablet
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: _buildBody(),
                  ),
                )
              : _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          children: [
            // AppBar
            _buildCartAppBar(),

            // Content
            Expanded(
              child: _cartItems.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Your cart is empty',
                      subtitle:
                          'Add your favourite luxury fragrances\nand they\'ll appear here.',
                      ctaLabel: 'Discover Fragrances',
                      onCta: () => Navigator.pop(context),
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
                      children: [
                        // Cart items
                        ...List.generate(_cartItems.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CartItemWidget(
                              item: _cartItems[index],
                              onIncrement: () => _incrementQty(index),
                              onDecrement: () => _decrementQty(index),
                              onDelete: () => _removeItem(index),
                            ),
                          );
                        }),

                        const SizedBox(height: 8),

                        // Coupon row
                        CouponRowWidget(
                          controller: _couponController,
                          isApplied: _couponApplied,
                          onApply: () {
                            setState(
                              () => _couponApplied =
                                  _couponController.text.isNotEmpty,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Order summary
                        OrderSummaryWidget(
                          subtotal: _subtotal,
                          deliveryFee: _deliveryFee,
                          discount: _couponApplied ? _discountAmount : 0,
                          total: _total,
                        ),
                      ],
                    ),
            ),
          ],
        ),

        // Sticky checkout button
        if (_cartItems.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCheckoutButton(),
          ),
      ],
    );
  }

  Widget _buildCartAppBar() {
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
            'Cart',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
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

  Widget _buildCheckoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: AppTheme.espresso.withAlpha(20),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: GestureDetector(
            onTap: _handleCheckout,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(100),
                boxShadow: AppTheme.accentGlow,
              ),
              child: Center(
                child: Text(
                  'Checkout  •  \$${_total.toStringAsFixed(2)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.espresso,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Checkout Confirm Sheet ────────────────────────────────────

class _CheckoutConfirmSheet extends StatelessWidget {
  final double total;

  const _CheckoutConfirmSheet({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.mutedLight,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.accent.withAlpha(38),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 30,
              color: Color(0xFF8B6914),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Confirm Order',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.espresso,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total amount: \$${total.toStringAsFixed(2)}',
            style: GoogleFonts.dmSans(fontSize: 15, color: AppTheme.muted),
          ),
          const SizedBox(height: 8),
          Text(
            'Your luxury fragrances will be delivered\nwithin 3–5 business days.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.muted,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppTheme.primary, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Order placed successfully! ✨',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: AppTheme.accentGlow,
                    ),
                    child: Center(
                      child: Text(
                        'Place Order',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.espresso,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Data Model ────────────────────────────────────────────────

class CartItem {
  final String id;
  final String name;
  final String subtitle;
  final String size;
  final double price;
  final int quantity;
  final String imageUrl;
  final String semanticLabel;

  CartItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.size,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.semanticLabel,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    id: map['id'] as String,
    name: map['name'] as String,
    subtitle: map['subtitle'] as String,
    size: map['size'] as String,
    price: (map['price'] as num).toDouble(),
    quantity: map['quantity'] as int,
    imageUrl: map['imageUrl'] as String,
    semanticLabel: map['semanticLabel'] as String,
  );

  CartItem copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? size,
    double? price,
    int? quantity,
    String? imageUrl,
    String? semanticLabel,
  }) => CartItem(
    id: id ?? this.id,
    name: name ?? this.name,
    subtitle: subtitle ?? this.subtitle,
    size: size ?? this.size,
    price: price ?? this.price,
    quantity: quantity ?? this.quantity,
    imageUrl: imageUrl ?? this.imageUrl,
    semanticLabel: semanticLabel ?? this.semanticLabel,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'subtitle': subtitle,
    'size': size,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
    'semanticLabel': semanticLabel,
  };
}
