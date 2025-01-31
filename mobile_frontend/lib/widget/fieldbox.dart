import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FieldBox extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;

  const FieldBox({
    Key? key,
    required this.label,
    this.controller,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
  }) : super(key: key);

  @override
  State<FieldBox> createState() => _FieldBoxState();
}

class _FieldBoxState extends State<FieldBox> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        onChanged: widget.onChanged,
        obscureText: widget.obscureText ? _obscureText : false,
        textCapitalization: widget.textCapitalization,
        keyboardType: widget.keyboardType,
        autocorrect: false,
        enableSuggestions: false,
        inputFormatters: [
          if (widget.keyboardType == TextInputType.emailAddress)
            FilteringTextInputFormatter.deny(RegExp(r'[A-Z]')),
        ],
        decoration: InputDecoration(
          labelText: widget.label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
