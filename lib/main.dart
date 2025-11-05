import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/blocs/auth_cubit.dart';
import 'features/auth/blocs/auth_state.dart';
import 'features/auth/screens/auth_wrapper_screen.dart';
import 'features/auth/screens/main_app_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    // Продолжаем без Firebase
  }
  
  // Проверить подключение к бэкенду
  try {
    final isBackendAvailable = await ApiService.checkHealth();
    print('Backend available: $isBackendAvailable');
  } catch (e) {
    print('⚠️ Backend check failed: $e');
  }
  
  runApp(const SosediApp());
}

class SosediApp extends StatelessWidget {
  const SosediApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        title: 'Соседи',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru', 'RU'), // Russian
          Locale('en', 'US'), // English
        ],
        locale: const Locale('ru', 'RU'),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B6B),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const AuthWrapperScreen(),
      ),
    );
  }
}
