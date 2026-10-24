import 'package:batik_app/controllers/product_controller.dart';
import 'package:batik_app/core/network/api_client.dart';
import 'package:batik_app/views/main_view.dart';
import 'package:batik_app/views/auth/reset_password_otp_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'views/splash_view.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/verify_email_view.dart';
import 'views/auth/forgot_password_view.dart';
import 'views/auth/reset_password_view.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await ApiClient.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
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
        '/reset-password': (_) => const ResetPasswordView(),
        '/home': (_) => const MainView(),
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
