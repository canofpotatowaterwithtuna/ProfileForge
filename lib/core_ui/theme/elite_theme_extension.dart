import 'dart:ui';

import 'package:flutter/material.dart';

/// "Elite" styling extension for consistent radii, spacing, and accents.
@immutable
class EliteThemeExtension extends ThemeExtension<EliteThemeExtension> {
  const EliteThemeExtension({
    this.cardRadius = 20,
    this.buttonRadius = 14,
    this.inputRadius = 14,
    this.chipRadius = 10,
    this.accentGradient,
  });

  final double cardRadius;
  final double buttonRadius;
  final double inputRadius;
  final double chipRadius;
  final LinearGradient? accentGradient;

  @override
  EliteThemeExtension copyWith({
    double? cardRadius,
    double? buttonRadius,
    double? inputRadius,
    double? chipRadius,
    LinearGradient? accentGradient,
  }) {
    return EliteThemeExtension(
      cardRadius: cardRadius ?? this.cardRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      inputRadius: inputRadius ?? this.inputRadius,
      chipRadius: chipRadius ?? this.chipRadius,
      accentGradient: accentGradient ?? this.accentGradient,
    );
  }

  @override
  EliteThemeExtension lerp(
    ThemeExtension<EliteThemeExtension>? other,
    double t,
  ) {
    if (other is! EliteThemeExtension) return this;
    return EliteThemeExtension(
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      buttonRadius: lerpDouble(buttonRadius, other.buttonRadius, t)!,
      inputRadius: lerpDouble(inputRadius, other.inputRadius, t)!,
      chipRadius: lerpDouble(chipRadius, other.chipRadius, t)!,
      accentGradient: t < 0.5 ? accentGradient : other.accentGradient,
    );
  }

  static const EliteThemeExtension elite = EliteThemeExtension(
    cardRadius: 20,
    buttonRadius: 14,
    inputRadius: 14,
    chipRadius: 10,
  );
}
