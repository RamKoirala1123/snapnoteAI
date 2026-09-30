import 'package:flutter/material.dart';

extension TypographyContextX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  // DISPLAY
  TextStyle get displayLarge => textTheme.displayLarge!;
  TextStyle get displayMedium => textTheme.displayMedium!;
  TextStyle get displaySmall => textTheme.displaySmall!;

  // HEADLINE
  TextStyle get headlineLarge => textTheme.headlineLarge!;
  TextStyle get headlineMedium => textTheme.headlineMedium!;
  TextStyle get headlineSmall => textTheme.headlineSmall!;

  // TITLE
  TextStyle get titleLarge => textTheme.titleLarge!;
  TextStyle get titleMedium => textTheme.titleMedium!;
  TextStyle get titleSmall => textTheme.titleSmall!;

  // BODY
  TextStyle get bodyLarge => textTheme.bodyLarge!;
  TextStyle get bodyMedium => textTheme.bodyMedium!;
  TextStyle get bodySmall => textTheme.bodySmall!;

  // LABEL
  TextStyle get labelLarge => textTheme.labelLarge!;
  TextStyle get labelMedium => textTheme.labelMedium!;
  TextStyle get labelSmall => textTheme.labelSmall!;
}

extension TextStyleColorX on TextStyle {
  TextStyle colored(Color color) => copyWith(color: color);
  TextStyle primary(BuildContext context) => copyWith(color: Theme.of(context).colorScheme.primary);
  TextStyle onPrimary(BuildContext context) => copyWith(color: Theme.of(context).colorScheme.onPrimary);
  TextStyle muted(BuildContext context) => copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
}
