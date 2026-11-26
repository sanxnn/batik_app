import 'package:batik_app/widgets/auth/auth_button.dart';
import 'package:batik_app/widgets/auth/auth_layout.dart';
import 'package:batik_app/widgets/auth/auth_text_field.dart';
import 'package:batik_app/widgets/auth/birth_date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'account form remains scrollable with large text and keyboard inset',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final form = GlobalKey<FormState>();
      final email = TextEditingController();
      addTearDown(email.dispose);
      bool? valid;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
              viewInsets: const EdgeInsets.only(bottom: 260),
            ),
            child: child!,
          ),
          home: AuthLayout(
            title: 'Buat akun',
            subtitle: 'Lengkapi data untuk melacak pesanan.',
            child: Form(
              key: form,
              child: Column(
                children: [
                  AuthTextField(
                    controller: email,
                    label: 'Email',
                    hint: 'nama@email.com',
                  ),
                  BirthDateField(value: null, onChanged: (_) {}),
                  AuthButton(
                    text: 'Simpan perubahan',
                    onPressed: () {
                      valid = form.currentState!.validate();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.byType(AuthButton));
      await tester.tap(find.byType(AuthButton));
      await tester.pumpAndSettle();
      expect(valid, isFalse);
      expect(find.text('Tanggal lahir wajib diisi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
