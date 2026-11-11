import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentLauncher {
  // Build with --dart-define=MIDTRANS_ENV=production for live Midtrans tokens.
  static const environment = String.fromEnvironment(
    'MIDTRANS_ENV',
    defaultValue: 'sandbox',
  );

  static Uri snapUri(String token) {
    final host = environment == 'production'
        ? 'app.midtrans.com'
        : 'app.sandbox.midtrans.com';
    return Uri.https(host, '/snap/v2/vtweb/${Uri.encodeComponent(token)}');
  }

  static Future<bool> open(String token) async {
    final uri = snapUri(token);
    return launchUrl(
      uri,
      mode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }
}
