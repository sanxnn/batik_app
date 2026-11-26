import 'package:flutter/material.dart';

class BirthDateField extends StatelessWidget {
  const BirthDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => FormField<DateTime>(
    initialValue: value,
    validator: (date) => date == null ? 'Tanggal lahir wajib diisi' : null,
    builder: (field) {
      final date = field.value;
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: !enabled
            ? null
            : () async {
                final now = DateTime.now();
                final first = DateTime(1900);
                final last = DateTime(now.year - 13, now.month, now.day);
                final initial =
                    date ?? DateTime(now.year - 17, now.month, now.day);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initial.isAfter(last)
                      ? last
                      : (initial.isBefore(first) ? first : initial),
                  firstDate: first,
                  lastDate: last,
                  helpText: 'Pilih tanggal lahir',
                  cancelText: 'Batal',
                  confirmText: 'Pilih',
                );
                if (!field.mounted || picked == null) return;
                field.didChange(picked);
                onChanged(picked);
              },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Tanggal lahir',
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            enabled: enabled,
            errorText: field.errorText,
          ),
          child: Text(
            date == null
                ? 'Pilih tanggal'
                : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
          ),
        ),
      );
    },
  );
}
