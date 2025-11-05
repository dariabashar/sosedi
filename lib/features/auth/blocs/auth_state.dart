import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(UserModel user) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.needProfile(String userId) = AuthNeedProfile;
  const factory AuthState.codeSent({
    required String verificationId,
    required String phoneNumber,
  }) = AuthCodeSent;
  const factory AuthState.codeVerifying() = AuthCodeVerifying;
  const factory AuthState.error(String message) = AuthError;
} 