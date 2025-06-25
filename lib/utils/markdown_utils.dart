/// lib/utils/markdown_utils.dart
///
/// Removes basic Markdown syntax (bold, headings, list bullets) from [md] text.
String stripMd(String md) {
  return md
      // bold: replace **…** with captured content
      .replaceAllMapped(
        RegExp(r'\*\*(.*?)\*\*'),
        (match) => match.group(1) ?? '',
      )
      // headings: remove leading # characters and following whitespace
      .replaceAll(RegExp(r'#+\s*'), '')
      // bullets: remove lines starting with *, -, or +
      .replaceAll(RegExp(r'^\s*[\*\-\+]\s*', multiLine: true), '')
      .trim();
}
