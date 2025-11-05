import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/auth_state.dart';
import '../repositories/auth_repository.dart';
import 'sms_verification_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+7 777 209 66 32');
  final _authRepository = AuthRepository();
  
  bool _agreedToTerms = false;
  bool _isLogin = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendSMS() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isLogin && !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Необходимо согласиться с условиями использования'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final phoneNumber = _phoneController.text.trim();
      
      await _authRepository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Автоматическая верификация (Android)
          try {
            await _authRepository.signInWithCredential(credential);
            _handleAuthSuccess();
          } catch (e) {
            _handleAuthError(e.toString());
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          
          String errorMessage = 'Ошибка верификации';
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Неверный номер телефона';
              break;
            case 'too-many-requests':
              errorMessage = 'Слишком много попыток. Попробуйте позже';
              break;
            case 'quota-exceeded':
              errorMessage = 'Превышен лимит SMS. Попробуйте завтра';
              break;
            case 'region-disabled':
              errorMessage = 'SMS недоступны в вашем регионе. Проверьте настройки Firebase';
              break;
            case 'operation-not-allowed':
              errorMessage = 'SMS верификация отключена. Проверьте настройки Firebase';
              break;
            case 'app-not-authorized':
              errorMessage = 'Приложение не авторизовано. Проверьте настройки Firebase';
              break;
            case 'invalid-app-credential':
              errorMessage = 'Неверные учетные данные приложения';
              break;
            case 'network-request-failed':
              errorMessage = 'Ошибка сети. Проверьте подключение';
              break;
            default:
              errorMessage = 'Ошибка: ${e.message} (код: ${e.code})';
          }
          
          print('Firebase Auth Error: ${e.code} - ${e.message}');
          _handleAuthError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
          });
          
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SmsVerificationScreen(
                verificationId: verificationId,
                phoneNumber: phoneNumber,
                resendToken: resendToken,
                isLogin: _isLogin,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Таймаут автоматического получения кода
        },
      );
    } catch (e) {
      _handleAuthError(e.toString());
    }
  }

  void _handleAuthSuccess() {
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Успешная авторизация!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleAuthError(String error) {
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ошибка: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _formatPhoneNumber(String value) {
    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numbers.isEmpty || !numbers.startsWith('7')) {
      numbers = '7';
    }
    
    String formatted = '+7';
    String phoneDigits = numbers.substring(1);
    
    if (phoneDigits.length > 0) {
      formatted += ' ';
      formatted += phoneDigits.substring(0, phoneDigits.length > 3 ? 3 : phoneDigits.length);
    }
    if (phoneDigits.length > 3) {
      formatted += ' ';
      formatted += phoneDigits.substring(3, phoneDigits.length > 6 ? 6 : phoneDigits.length);
    }
    if (phoneDigits.length > 6) {
      formatted += ' ';
      formatted += phoneDigits.substring(6, phoneDigits.length > 8 ? 8 : phoneDigits.length);
    }
    if (phoneDigits.length > 8) {
      formatted += ' ';
      formatted += phoneDigits.substring(8, phoneDigits.length > 10 ? 10 : phoneDigits.length);
    }
    
    if (phoneDigits.length > 10) {
      return;
    }
    
    _phoneController.value = _phoneController.value.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo and title
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.home_work,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Соседи',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin 
                          ? 'Войдите с помощью номера телефона'
                          : 'Создайте аккаунт для общения с соседями',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF718096),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Phone field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Номер телефона',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _sendSMS(),
                      onChanged: _formatPhoneNumber,
                      decoration: InputDecoration(
                        hintText: '+7 999 123 45 67',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7FAFC),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите номер телефона';
                        }
                        
                        final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                        if (digits.length < 10 || digits.length > 11) {
                          return 'Введите корректный номер телефона';
                        }
                        
                        return null;
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF0369A1),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'На указанный номер будет отправлен SMS с кодом подтверждения',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Terms checkbox (только для регистрации)
                if (!_isLogin)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                        activeColor: const Color(0xFFFF6B6B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Я согласен с условиями использования и политикой конфиденциальности',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ),
                    ],
                  ),
                
                if (!_isLogin) const SizedBox(height: 24),
                
                const SizedBox(height: 32),
                
                // Send SMS button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendSMS,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isLogin ? 'Войти' : 'Получить код',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Toggle between login/register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? 'Нет аккаунта? ' : 'Уже есть аккаунт? ',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          if (_isLogin) {
                            _agreedToTerms = true;
                          } else {
                            _agreedToTerms = false;
                          }
                        });
                      },
                      child: Text(
                        _isLogin ? 'Зарегистрироваться' : 'Войти',
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 