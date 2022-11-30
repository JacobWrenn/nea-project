import 'package:flutter/material.dart';

Color textColor(Color color) {
  // Luminance is between 0 (darkest) and 1 (lightest). This determines what text color to use on a specific background.
  return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
