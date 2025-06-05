import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String paymentIntentId,
    required String orderId,
    required double amount,
    required String currency,
    required String status,
    required String paymentMethod,
    required String? phoneNumber,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
}
