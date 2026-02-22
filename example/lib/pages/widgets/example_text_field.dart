import 'package:flutter/material.dart';

class ExampleTextField extends StatelessWidget {
  const ExampleTextField({
    super.key,
    this.hintText = '',
    this.obscureText = false,
    this.onChanged,
    this.errorText,
    this.success = false,
    this.helperText,
  });

  final String hintText;
  final bool obscureText;
  final void Function(String)? onChanged;
  final String? errorText;
  final String? helperText;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.start,
      obscureText: obscureText,
      onChanged: onChanged,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: Theme.of(context).colorScheme.onBackground),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        labelText: hintText,
        errorText: errorText,
        helperText: helperText,
        hintStyle: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onBackground),
        filled: true,
        border: OutlineInputBorder(
          borderSide: success
              ? BorderSide(
                  color: Theme.of(context).primaryColor,
                )
              : BorderSide.none,
          borderRadius: BorderRadius.circular(32),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    );
  }
}
