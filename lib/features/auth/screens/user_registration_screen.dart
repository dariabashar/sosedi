import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'main_app_screen.dart';

class UserRegistrationScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? userId;
  
  const UserRegistrationScreen({
    super.key,
    this.phoneNumber,
    this.userId,
  });

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _authRepository = AuthRepository();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final displayName = '$firstName $lastName';

      // Проверяем подключение к Firebase
      final isConnected = await _authRepository.testFirebaseConnection();
      if (!isConnected) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка подключения к серверу. Попробуйте позже.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Создаем профиль пользователя в Firebase
      await _authRepository.createUserProfile(
        userId: widget.userId ?? 'test_user',
        phoneNumber: widget.phoneNumber ?? '+7 999 999 99 99',
        displayName: displayName,
      );

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Добро пожаловать в Соседи!'),
          backgroundColor: Colors.green,
        ),
      );

      // Переходим в главное приложение
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainAppScreen()),
        (route) => false,
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      String errorMessage = 'Ошибка регистрации';
      
      // Firebase отключен, используем общую обработку ошибок
      errorMessage = 'Ошибка регистрации: $e';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName не может быть пустым';
    }
    
    final cyrillicRegex = RegExp(r'^[а-яё\s-]+$', caseSensitive: false);
    if (!cyrillicRegex.hasMatch(value.trim())) {
      return '$fieldName должно содержать только русские буквы';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName должно содержать минимум 2 символа';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Расскажите о себе',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                // Иконка
                Icon(
                  Icons.person_add_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                
                const SizedBox(height: 24),
                
                // Описание
                Text(
                  'Как к вам обращаться?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Введите ваше имя и фамилию на русском языке',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Поле имени
                TextFormField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Имя',
                    hintText: 'Введите ваше имя',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
                    ),
                  ),
                  validator: (value) => _validateName(value, 'Имя'),
                ),
                
                const SizedBox(height: 16),
                
                // Поле фамилии
                TextFormField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Фамилия',
                    hintText: 'Введите вашу фамилию',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
                    ),
                  ),
                  validator: (value) => _validateName(value, 'Фамилия'),
                ),
                
                const Spacer(),
                
                // Кнопка завершения регистрации
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
                      : const Text(
                          'Завершить регистрацию',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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