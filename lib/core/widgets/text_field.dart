import 'package:flutter/material.dart';

class PawsTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final int? maxLength;
  final int maxLines;
  final FocusNode? focusNode;

  const PawsTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.maxLength,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  State<PawsTextField> createState() => _PawsTextFieldState();
}

class _PawsTextFieldState extends State<PawsTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: _obscure,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        counterText: '', // hides counter unless needed
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1.6),
        ),
      ),
    );
  }
}
