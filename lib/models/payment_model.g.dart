// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentModelImpl _$$PaymentModelImplFromJson(Map<String, dynamic> json) =>
    _$PaymentModelImpl(
      paymentIntentId: json['paymentIntentId'] as String,
      orderId: json['orderId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      phoneNumber: json['phoneNumber'] as String?,
    );

Map<String, dynamic> _$$PaymentModelImplToJson(_$PaymentModelImpl instance) =>
    <String, dynamic>{
      'paymentIntentId': instance.paymentIntentId,
      'orderId': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'paymentMethod': instance.paymentMethod,
      'phoneNumber': instance.phoneNumber,
    };
