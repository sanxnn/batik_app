import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class VerifyEmailView extends StatefulWidget {
  final String email;
  const VerifyEmailView({super.key, required this.email});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_otpCtrl.text.length != 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('OTP harus 6 digit')));
      return;
    }

    final controller = context.read<AuthController>();
    final success = await controller.verifyEmail(widget.email, _otpCtrl.text);

    if (!mounted) return;

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Verifikasi gagal'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    final controller = context.read<AuthController>();
    final success = await controller.resendOtp(widget.email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'OTP baru telah dikirim'
              : controller.errorMessage ?? 'Gagal mengirim OTP',
        ),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Email')),
      body: Consumer<AuthController>(
        builder: (context, controller, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.mail_outline, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  'Kode OTP telah dikirim ke:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '000000',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.isLoading ? null : _handleVerify,
                    child: controller.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Verifikasi'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: controller.isLoading ? null : _handleResend,
                  child: const Text('Kirim Ulang OTP'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
