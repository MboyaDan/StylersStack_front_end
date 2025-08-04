class OrderItem {
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
    "product_name": productName,
    "quantity": quantity,
    "unit_price": unitPrice,
  };
}

class OrderModel {
  final double totalAmount;
  final String paymentId;
  final List<OrderItem> items;

  OrderModel({
    required this.totalAmount,
    required this.paymentId,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    "total_amount": totalAmount,
    "payment_id": paymentId,
    "items": items.map((e) => e.toJson()).toList(),
  };
}
