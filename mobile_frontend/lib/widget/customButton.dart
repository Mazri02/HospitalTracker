import 'package:flutter/material.dart';

class NextButton extends StatefulWidget {
  const NextButton({
    super.key,
    this.child,
    required this.valueColor,
    required this.nameButton,
    required this.routeName,
  });

  final Widget? child;
  final String routeName;
  final int valueColor;
  final String nameButton;

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(Size(300, 50)),
        padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 17)),
        backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF20237D)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Color(widget.valueColor)),
          ),
        ),
      ),
      //onPressed: login,
      onPressed: () {
        setState(() {});
        Navigator.pushNamed(context, widget.routeName);
      },
      child: Text(
        widget.nameButton,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SubmitButton extends StatefulWidget {
  const SubmitButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.color,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final String text;
  final Color color;

  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(300, 50)),
          padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(vertical: 17)),
          backgroundColor: WidgetStateProperty.all<Color>(widget.color),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: widget.color),
            ),
          ),
        ),
        onPressed: widget.onPressed,
        child: Text(
          widget.text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
