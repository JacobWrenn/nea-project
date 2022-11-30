import 'package:app/helpers/textcolor.dart';
import 'package:flutter/material.dart';

Widget button(String text, Function fn,
    {Color color = const Color(0xFFbdbdbd)}) {
  return TextButton(
    child: Text(text),
    onPressed: fn,
    style: TextButton.styleFrom(
      backgroundColor: color,
      primary: textColor(color),
      padding: EdgeInsets.symmetric(vertical: 16),
    ),
  );
}
