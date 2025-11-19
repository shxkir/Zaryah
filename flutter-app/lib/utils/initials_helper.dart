import 'package:characters/characters.dart';

String initialsFromName(
  String? rawName, {
  String fallback = 'U',
  int maxCharacters = 1,
}) {
  final trimmed = rawName?.trim() ?? '';
  if (trimmed.isEmpty) return fallback;

  final parts = trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
  final buffer = StringBuffer();

  for (final part in parts) {
    final chars = part.characters;
    if (chars.isEmpty) continue;
    buffer.write(chars.first.toUpperCase());
    if (buffer.length >= maxCharacters) break;
  }

  return buffer.isEmpty ? fallback : buffer.toString();
}
