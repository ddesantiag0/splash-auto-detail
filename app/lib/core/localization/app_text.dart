import 'package:flutter/material.dart';

import 'spanish.dart';

String tr(BuildContext context, String source) =>
    Localizations.localeOf(context).languageCode == 'es'
        ? (spanish[source] ?? source)
        : source;

/// Localizes UI copy only; customer-entered values are rendered with plain Text.
class AppText extends StatelessWidget {
  const AppText(
    this.source, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String source;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => Text(
        tr(context, source),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
}

Locale resolveAppLocale(List<Locale>? locales, Iterable<Locale> supported) {
  for (final locale in locales ?? <Locale>[]) {
    for (final candidate in supported) {
      if (candidate.languageCode == locale.languageCode) return candidate;
    }
  }
  return const Locale('en');
}
