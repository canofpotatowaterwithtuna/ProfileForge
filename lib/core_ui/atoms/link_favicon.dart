import 'package:flutter/material.dart';

/// Displays the favicon (tab icon) of a URL, with fallback to a generic icon.
class LinkFavicon extends StatelessWidget {
  const LinkFavicon({
    required this.url,
    this.size = 20,
    this.fallbackColor,
    super.key,
  });

  final String url;
  final double size;
  final Color? fallbackColor;

  static String? _faviconUrl(String url, double size) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return null;
    return 'https://www.google.com/s2/favicons?domain=${uri.host}&sz=64';
  }

  Widget _fallbackIcon(Color color) =>
      Icon(Icons.link, size: size, color: color);

  @override
  Widget build(BuildContext context) {
    final color = fallbackColor ?? Theme.of(context).colorScheme.primary;
    final favUrl = _faviconUrl(url, size);
    if (favUrl == null) return _fallbackIcon(color);
    return Image.network(
      favUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      cacheWidth: 64,
      cacheHeight: 64,
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _fallbackIcon(color);
      },
      errorBuilder: (_, __, ___) => _fallbackIcon(color),
    );
  }
}
