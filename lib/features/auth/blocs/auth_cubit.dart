import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const AuthState.initial()) {
    // Слушаем изменения состояния авторизации Firebase
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (User? user) {
        if (user != null) {
          _loadUserProfile();
        } else {
          emit(const AuthState.unauthenticated());
        }
      },
    );
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _authRepository.getCurrentUserProfile();
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        // Если пользователь есть в Firebase Auth, но нет в Firestore, 
        // нужно создать профиль
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          emit(AuthState.needProfile(firebaseUser.uid));
        } else {
          emit(const AuthState.unauthenticated());
        }
      }
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    try {
      emit(const AuthState.loading());
      
      await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
      );
      
      // Проверяем, что пользователь создался
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Принудительно загружаем профиль
        await _loadUserProfile();
      }
      
    } catch (e) {
      emit(AuthState.error('Ошибка регистрации: $e'));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      emit(const AuthState.loading());
      
      await _authRepository.login(
        email: email,
        password: password,
      );
      
      // После успешного входа Firebase автоматически обновит состояние
    } catch (e) {
      emit(AuthState.error('Ошибка входа: $e'));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      // Firebase автоматически обновит состояние
    } catch (e) {
      emit(AuthState.error('Ошибка выхода: $e'));
    }
  }

  Future<void> createProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      emit(const AuthState.loading());
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(AuthState.error('Пользователь не авторизован'));
        return;
      }
      
      await _authRepository.createUserProfile(
        userId: user.uid,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );
      
      // Перезагружаем профиль пользователя
      await _loadUserProfile();
    } catch (e) {
      emit(AuthState.error('Ошибка создания профиля: $e'));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
} 