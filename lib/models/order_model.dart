class OrderItem {
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['product_name'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "product_name": productName,
    "quantity": quantity,
    "unit_price": unitPrice,
  };
}

class OrderModel {
  final String id;
  final String userUid;
  final double totalAmount;
  final String status;
  final String paymentId;
  final DateTime createdAt;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.userUid,
    required this.totalAmount,
    required this.status,
    required this.paymentId,
    required this.createdAt,
    required this.items,
  });

  /// Getter for formatted date
  String get createdAtFormatted {
    return "${createdAt.day}/${createdAt.month}/${createdAt.year}";
  }

  /// Getter for total (for UI compatibility)
  double get total => totalAmount;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userUid: json['user_uid'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
      paymentId: json['payment_id'],
      createdAt: DateTime.parse(json['created_at']),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_uid": userUid,
    "total_amount": totalAmount,
    "status": status,
    "payment_id": paymentId,
    "created_at": createdAt.toIso8601String(),
    "items": items.map((e) => e.toJson()).toList(),
  };
}
