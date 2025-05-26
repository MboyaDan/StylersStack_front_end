import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'favorite_item.freezed.dart';
part 'favorite_item.g.dart';

@freezed
@HiveType(typeId: 1)
class FavoriteItem with _$FavoriteItem {
  const factory FavoriteItem({
    @HiveField(0) required String productId,
    @HiveField(1) required String productName,
    @HiveField(2) required String imageUrl,
    @HiveField(3) required double price,
    @HiveField(4) required String userId,
  }) = _FavoriteItem;

  factory FavoriteItem.fromJson(Map<String, dynamic> json) =>
      _$FavoriteItemFromJson(json);
}
