// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentModelImpl _$$PaymentModelImplFromJson(Map<String, dynamic> json) =>
    _$PaymentModelImpl(
      paymentIntentId: json['payment_intent_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      phoneNumber: json['phone_number'] as String?,
    );

Map<String, dynamic> _$$PaymentModelImplToJson(_$PaymentModelImpl instance) =>
    <String, dynamic>{
      'payment_intent_id': instance.paymentIntentId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'payment_method': instance.paymentMethod,
      'phone_number': instance.phoneNumber,
    };
