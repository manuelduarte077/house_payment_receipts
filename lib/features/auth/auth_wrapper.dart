import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.user == null) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}
