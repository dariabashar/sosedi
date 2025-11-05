import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/auth_state.dart';
import 'main_app_screen.dart';
import 'login_screen.dart';

class AuthWrapperScreen extends StatelessWidget {
  const AuthWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return state.when(
          initial: () => const LoginScreen(),
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          codeSent: (verificationId, phoneNumber) => const LoginScreen(),
          codeVerifying: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          authenticated: (user) => const MainAppScreen(),
          unauthenticated: () => const LoginScreen(),
          needProfile: (userId) => const MainAppScreen(),
          error: (message) => Scaffold(
            body: Center(
              child: Text('Ошибка: $message'),
            ),
          ),
        );
      },
    );
  }
} 