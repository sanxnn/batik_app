import 'package:batik_app/core/network/api_client.dart';
import 'package:batik_app/views/reset_password_otp_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/verify_email_view.dart';
import 'views/forgot_password_view.dart';
import 'views/reset_password_view.dart';
import 'views/profile_view.dart';
import 'views/home_view.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await ApiClient.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batik Rubung Kuning',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      
      routes: {
        '/': (_) => const SplashView(),
        '/login': (_) => const LoginView(),
        '/register': (_) => const RegisterView(),
        '/forgot-password': (_) => const ForgotPasswordView(),
        '/reset-password': (_) => const ResetPasswordView(), // Baca args secara internal
        '/profile': (_) => const ProfileView(),
        '/home': (_) => const HomeView(),
      },

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/verify-email':
            final email = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => VerifyEmailView(email: email),
            );

          case '/reset-password-otp':
            final email = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => ResetPasswordOtpView(email: email),
            );

          default:
            return null;
        }
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan')),
          ),
        );
      },
    );
  }
}