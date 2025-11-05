import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return UserModel(
      id: user.uid,
      firstName: user.displayName?.split(' ').first ?? 'Пользователь',
      lastName: user.displayName?.split(' ').last ?? '',
      phoneNumber: user.phoneNumber ?? '',
      email: user.email ?? '',
      displayName: user.displayName,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      
      // Если пользователь есть в Firebase Auth, но нет в Firestore - создаем профиль
      final newUser = UserModel(
        id: user.uid,
        firstName: user.displayName?.split(' ').first ?? 'Пользователь',
        lastName: user.displayName?.split(' ').last ?? '',
        phoneNumber: user.phoneNumber ?? '',
        email: user.email ?? '',
        displayName: user.displayName,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        updatedAt: user.metadata.lastSignInTime ?? DateTime.now(),
      );
      
      // Сохраняем в Firestore
      await createUserProfile(
        userId: user.uid,
        firstName: user.displayName?.split(' ').first ?? 'Пользователь',
        lastName: user.displayName?.split(' ').last ?? '',
        phoneNumber: user.phoneNumber ?? '',
        email: user.email ?? '',
      );
      
      return newUser;
    } catch (e) {
      return null;
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
      // Создаем пользователя с email и паролем
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Создаем профиль пользователя в Firestore
      await createUserProfile(
        userId: userCredential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email,
      );
      
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final now = DateTime.now();
      final userData = {
        'id': userId,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'email': email,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'isVerified': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isDeleted': false,
      };

      await _firestore.collection('users').doc(userId).set(userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> testFirebaseConnection() async {
    try {
      await _auth.authStateChanges().first;
      return true;
    } catch (e) {
      return false;
    }
  }
} 