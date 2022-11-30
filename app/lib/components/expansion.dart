import 'package:flutter/material.dart';

Widget expansion(Widget child) {
  return Row(
    children: [
      Expanded(
        child: child,
      ),
    ],
  );
}
