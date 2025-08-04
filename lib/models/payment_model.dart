import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    @JsonKey(name: 'payment_intent_id') String? paymentIntentId,
    required double amount,
    required String currency,
    required String status,
    @JsonKey(name: 'payment_method') required String paymentMethod,
    @JsonKey(name: 'phone_number') String? phoneNumber,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
}




