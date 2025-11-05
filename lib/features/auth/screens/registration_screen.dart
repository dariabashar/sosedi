import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/auth_state.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      context.read<AuthCubit>().register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Регистрация'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {
              setState(() {
                _isLoading = true;
              });
            },
            codeSent: (verificationId, phoneNumber) {},
            codeVerifying: () {},
            authenticated: (user) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Регистрация успешна!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Убираем Navigator.pop() - AuthWrapperScreen автоматически переключится
            },
            unauthenticated: () {
              setState(() {
                _isLoading = false;
              });
            },
            needProfile: (userId) {},
            error: (message) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Логотип
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.home_work,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Создайте аккаунт',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Присоединяйтесь к сообществу соседей',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Имя
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Введите ваше имя',
                    ),
                    textCapitalization: TextCapitalization.words,
                    maxLength: 50,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите имя';
                      }
                      if (value.trim().length < 2) {
                        return 'Имя должно содержать минимум 2 символа';
                      }
                      if (value.trim().length > 50) {
                        return 'Имя не должно превышать 50 символов';
                      }
                      // Проверяем, что имя содержит только буквы, пробелы и дефисы
                      if (!RegExp(r'^[а-яёА-ЯЁa-zA-Z\s\-]+$').hasMatch(value.trim())) {
                        return 'Имя может содержать только буквы, пробелы и дефисы';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Фамилия
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Фамилия',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'Введите вашу фамилию',
                    ),
                    textCapitalization: TextCapitalization.words,
                    maxLength: 50,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите фамилию';
                      }
                      if (value.trim().length < 2) {
                        return 'Фамилия должна содержать минимум 2 символа';
                      }
                      if (value.trim().length > 50) {
                        return 'Фамилия не должна превышать 50 символов';
                      }
                      // Проверяем, что фамилия содержит только буквы, пробелы и дефисы
                      if (!RegExp(r'^[а-яёА-ЯЁa-zA-Z\s\-]+$').hasMatch(value.trim())) {
                        return 'Фамилия может содержать только буквы, пробелы и дефисы';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Телефон
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Номер телефона',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      hintText: '+7 XXX XXX XX XX',
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 18, // Ограничиваем длину
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите номер телефона';
                      }
                      
                      // Убираем все символы кроме цифр для проверки
                      String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                      
                      // Проверяем, что номер начинается с 7 и содержит ровно 11 цифр
                      if (!digitsOnly.startsWith('7') || digitsOnly.length != 11) {
                        return 'Номер должен начинаться с 7 и содержать 11 цифр';
                      }
                      
                      // Проверяем формат с пробелами
                      if (!RegExp(r'^\+7\s\d{3}\s\d{3}\s\d{2}\s\d{2}$').hasMatch(value.trim())) {
                        return 'Формат: +7 XXX XXX XX XX';
                      }
                      
                      return null;
                    },
                    onChanged: (value) {
                      // Ограничиваем длину ввода
                      if (value.length > 18) {
                        _phoneController.value = _phoneController.value.copyWith(
                          text: value.substring(0, 18),
                          selection: TextSelection.collapsed(offset: 18),
                        );
                        return;
                      }
                      _formatPhoneNumber(value);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      hintText: 'example@email.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 254,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите email';
                      }
                      if (value.trim().length > 254) {
                        return 'Email не должен превышать 254 символа';
                      }
                      // Более строгая проверка email
                      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value.trim())) {
                        return 'Введите корректный email';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Пароль
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Минимум 8 символов',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    maxLength: 128,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите пароль';
                      }
                      if (value.length < 8) {
                        return 'Пароль должен содержать минимум 8 символов';
                      }
                      if (value.length > 128) {
                        return 'Пароль не должен превышать 128 символов';
                      }
                      // Проверяем, что пароль содержит хотя бы одну букву и одну цифру
                      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                        return 'Пароль должен содержать буквы и цифры';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Подтверждение пароля
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Подтвердите пароль',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Подтвердите пароль';
                      }
                      if (value != _passwordController.text) {
                        return 'Пароли не совпадают';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Кнопка регистрации
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Зарегистрироваться',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Ссылка на вход
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Уже есть аккаунт? '),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Войти',
                          style: TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _formatPhoneNumber(String value) {
    // Убираем все символы кроме цифр
    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Строго ограничиваем количество цифр до 11 (7 + 10 цифр номера)
    if (numbers.length > 11) {
      numbers = numbers.substring(0, 11);
    }
    
    // Если номер не начинается с 7, заменяем на 7
    if (numbers.isEmpty) {
      numbers = '7';
    } else if (!numbers.startsWith('7')) {
      numbers = '7' + numbers.substring(0, numbers.length > 10 ? 10 : numbers.length);
    }
    
    String formatted = '+7';
    String phoneDigits = numbers.substring(1);
    
    // Форматируем номер с пробелами, строго ограничивая каждую группу
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
    
    // Обновляем контроллер только если текст изменился
    if (_phoneController.text != formatted) {
      _phoneController.value = _phoneController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}
