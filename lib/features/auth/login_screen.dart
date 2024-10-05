import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final bool isTablet = ScreenUtil().screenWidth > 600;

        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: isTablet
                    ? TabletLoginLayout(authService: authService)
                    : MobileLoginLayout(authService: authService),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Layout para móviles
class MobileLoginLayout extends StatelessWidget {
  final AuthService authService;

  const MobileLoginLayout({required this.authService, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const LoginLogo(),
          SizedBox(height: 30.h),
          const WelcomeText(),
          SizedBox(height: 40.h),
          LoginForm(authService: authService),
        ],
      ),
    );
  }
}

// Layout para tabletas
class TabletLoginLayout extends StatelessWidget {
  final AuthService authService;

  const TabletLoginLayout({required this.authService, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Center(child: LoginLogo(size: 320)),
        ),
        SizedBox(width: 50.w),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const WelcomeText(),
                SizedBox(height: 40.h),
                LoginForm(authService: authService),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Widget reutilizable del logo
class LoginLogo extends StatelessWidget {
  const LoginLogo({
    super.key,
    this.size = 150,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Icon(
        Icons.receipt_long_outlined,
        size: size,
        color: const Color(0xFF6C63FF),
      ),
    );
  }
}

// Widget de texto de bienvenida reutilizable
class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Bienvenido',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 10.h),
        Text(
          textAlign: TextAlign.center,
          'Por favor, inicia sesión para continuar, y acceder a tus comprobantes',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

// Widget para el formulario de inicio de sesión
class LoginForm extends StatelessWidget {
  final AuthService authService;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginForm({required this.authService, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de correo electrónico
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20.h),

        // Campo de contraseña
        PasswordInputField(
          controller: _passwordController,
        ),
        SizedBox(height: 30.h),

        // Botón de inicio de sesión
        LoginButton(
          authService: authService,
          emailController: _emailController,
          passwordController: _passwordController,
        ),

        SizedBox(height: 20.h),
        TextButton(
          onPressed: () {},
          child: Text(
            textAlign: TextAlign.center,
            '¿Olvidaste tu contraseña?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

// Widget reutilizable del campo de contraseña con visibilidad
class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordInputField({required this.controller, super.key});

  @override
  _PasswordInputFieldState createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _showPassword = false;

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: _togglePasswordVisibility,
          icon: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
      obscureText: !_showPassword,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
    );
  }
}

// Widget para el botón de inicio de sesión
class LoginButton extends StatelessWidget {
  final AuthService authService;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginButton({
    required this.authService,
    required this.emailController,
    required this.passwordController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await authService.signIn(
            emailController.text,
            passwordController.text,
          );
        } catch (e) {
          log(e.toString());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              content: Text(
                'Revise su correo y contraseña',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50.h),
      ),
      child: Text(
        'Iniciar sesión',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
