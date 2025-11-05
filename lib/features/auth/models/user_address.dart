import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_address.freezed.dart';
part 'user_address.g.dart';

@freezed
class UserAddress with _$UserAddress {
  const factory UserAddress({
    required String id,
    required String userId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String placeId,
    String? type, // 'home', 'work', 'other'
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserAddress;

  factory UserAddress.fromJson(Map<String, dynamic> json) =>
      _$UserAddressFromJson(json);
} 