import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/models/cart_item.dart';
import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/utils/constants.dart';

class CartItemCard extends StatefulWidget {
  final CartItemModel cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  Future<bool?> _showDeleteConfirmationDialog(BuildContext dialogContext) async {
    return showDialog<bool>(
      context: dialogContext,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        elevation: 10,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.red),
            SizedBox(width: 8),
            Text('Remove Item', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to remove this item from your cart?',
          style: TextStyle(fontSize: 15),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child:  Text('Cancel'
                ,style: TextStyle(color: AppColors.text(context),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.delete_outline, size: 18,
              color: Colors.white,
            ),
            label: const Text('Remove'
              ,style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    final messenger = ScaffoldMessenger.of(context); // Captured before await

    return Dismissible(
      key: Key(widget.cartItem.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.padding),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        final confirm = await _showDeleteConfirmationDialog(context);

        if (!mounted) return false;

        if (confirm == true) {
          await cartProvider.removeFromCart(widget.cartItem.productId);
          await HapticFeedback.mediumImpact();

          messenger.showSnackBar(
            SnackBar(
              content: const Text('Item removed from cart'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }

        return confirm;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.cardMargin),
        padding: const EdgeInsets.all(AppSpacing.padding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.cartItem.productImageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  width: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 📦 Product Info + Controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cartItem.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "KES ${widget.cartItem.totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ➖ Quantity Controls ➕
                  Row(
                    children: [
                      _quantityButton(
                        icon: Icons.remove,
                        onTap: widget.cartItem.quantity > 1
                            ? () {
                          cartProvider.updateCartItem(
                            widget.cartItem.productId,
                            widget.cartItem.quantity - 1,
                          );
                          HapticFeedback.selectionClick();
                        }
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.cartItem.quantity.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      _quantityButton(
                        icon: Icons.add,
                        onTap: () {
                          cartProvider.updateCartItem(
                            widget.cartItem.productId,
                            widget.cartItem.quantity + 1,
                          );
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),

            // ❌ Remove icon (manual)
            IconButton(
              onPressed: () async {
                final confirm = await _showDeleteConfirmationDialog(context);

                if (!mounted) return;

                if (confirm == true) {
                  await cartProvider.removeFromCart(widget.cartItem.productId);
                  await HapticFeedback.mediumImpact();

                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Item removed from cart'),
                      backgroundColor: AppColors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.delete_outline, color: AppColors.red),
              tooltip: 'Remove item',
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.accent(context).withAlpha(25)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? AppColors.primary(context) : Colors.grey,
        ),
      ),
    );
  }
}
