import 'package:flutter/material.dart';

/// Label stays visible while typing, matching the account forms in the design.
class AccountField extends StatefulWidget {
  const AccountField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.secret = false,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool secret;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final Iterable<String>? autofillHints;

  @override
  State<AccountField> createState() => _AccountFieldState();
}

class _AccountFieldState extends State<AccountField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            obscureText: widget.secret && _hidden,
            autocorrect: !widget.secret,
            enableSuggestions: !widget.secret,
            autofillHints: widget.autofillHints,
            validator: widget.validator,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: widget.hint,
              suffixIcon: widget.secret
                  ? IconButton(
                      tooltip: _hidden ? 'Tampilkan password' : 'Sembunyikan password',
                      onPressed: () => setState(() => _hidden = !_hidden),
                      icon: Icon(
                        _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 21,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

String? requiredAccountValue(String? value) =>
    value == null || value.trim().isEmpty ? 'Kolom ini wajib diisi.' : null;

String? accountEmailValidator(String? value) {
  if (requiredAccountValue(value) != null) return 'Email wajib diisi.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
    return 'Masukkan alamat email yang valid.';
  }
  return null;
}

String? accountPasswordValidator(String? value) =>
    value == null || value.length < 8 ? 'Password minimal 8 karakter.' : null;
