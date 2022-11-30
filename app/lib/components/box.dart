import 'package:flutter/material.dart';

Widget box(Widget child) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
    ),
    child: Padding(
      child: child,
      padding: EdgeInsets.all(16),
    ),
  );
}
