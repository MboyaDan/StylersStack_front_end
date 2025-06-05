import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/cart_item_card.dart';
import '../../utils/constants.dart';
class MyCartScreen extends StatelessWidget {
  const MyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty."))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: cartItems.map((item) => CartItemCard(cartItem: item)).toList(),
      ),
      bottomNavigationBar: cartItems.isNotEmpty ? _checkoutBottomSheet(context, cartProvider) : null,
    );
  }

  Widget _checkoutBottomSheet(BuildContext context, CartProvider provider) {
    final TextEditingController promoController = TextEditingController();

    return Container(
      //padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding:const EdgeInsets.all(AppSpacing.padding),
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: promoController,
            decoration: InputDecoration(
              hintText: "Enter Promo Code",
              suffixIcon: TextButton(
                onPressed: () {
                  provider.applyPromoCode(promoController.text);
                  FocusScope.of(context).unfocus();
                },
                child:
                const Text("Apply",
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total:  KES ${provider.totalCartPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  //backgroundColor: const Color(0xFFDCC6B0),
                  backgroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: ()  async => context.push('/checkout'),
                child: const Text("Checkout",
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
