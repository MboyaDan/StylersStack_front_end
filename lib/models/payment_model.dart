class PaymentModel {
  final String paymentIntentId;
  final String orderId;
  final double amount;
  final String currency;
  final String status; // e.g., 'pending', 'completed', 'failed'

  PaymentModel({
    required this.paymentIntentId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentIntentId: json['payment_intent_id'] ?? '',
      orderId: json['order_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'Ksh',
      status: json['status'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_intent_id': paymentIntentId,
      'order_id': orderId,
      'amount': amount,
      'currency': currency,
      'status': status,
    };
  }
}
