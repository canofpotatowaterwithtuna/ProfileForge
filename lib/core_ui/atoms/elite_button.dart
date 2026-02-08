import 'package:flutter/material.dart';

import '../theme/elite_theme_extension.dart';

/// Primary CTA button with optional elite styling.
class EliteFilledButton extends StatelessWidget {
  const EliteFilledButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final elite = Theme.of(context).extension<EliteThemeExtension>();
    final style = FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(elite?.buttonRadius ?? 14),
      ),
    );
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: style,
      child: loading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: style.foregroundColor?.resolve({}),
              ),
            )
          : (icon != null
                ? (label.isEmpty
                      ? icon
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            icon!,
                            const SizedBox(width: 8),
                            Text(label),
                          ],
                        ))
                : Text(label)),
    );
  }
}

/// Secondary / outline style.
class EliteOutlinedButton extends StatelessWidget {
  const EliteOutlinedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final elite = Theme.of(context).extension<EliteThemeExtension>();
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(elite?.buttonRadius ?? 14),
        ),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [icon!, const SizedBox(width: 8), Text(label)],
            )
          : Text(label),
    );
  }
}
