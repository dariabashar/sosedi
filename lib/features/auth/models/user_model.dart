import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    String? displayName,
    String? address,
    double? latitude,
    double? longitude,
    String? avatarUrl,
    @Default(false) bool isVerified,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
} 