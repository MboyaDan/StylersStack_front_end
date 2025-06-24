import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'favorite_item.freezed.dart';
part 'favorite_item.g.dart';

@freezed
@HiveType(typeId: 1)
class FavoriteItem with _$FavoriteItem {
  const factory FavoriteItem({
    @HiveField(0)
    @JsonKey(name: 'product_id')
    required String productId,

    @HiveField(1)
    @JsonKey(name: 'product_name')
    required String productName,

    @HiveField(2)
    @JsonKey(name: 'image_url')
    required String imageUrl,

    @HiveField(3)
    required double price,

    @HiveField(4)
    @JsonKey(name: 'user_uid') // Match what FastAPI expects
    required String userId,
  }) = _FavoriteItem;

  factory FavoriteItem.fromJson(Map<String, dynamic> json) =>
      _$FavoriteItemFromJson(json);
}
