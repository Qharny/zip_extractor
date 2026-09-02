import 'dart:io';

/// Prompts for a password without echoing it to the terminal, masking each
/// keystroke with `*`. Falls back to a plain (visible) [stdin.readLineSync]
/// prompt when stdin isn't an interactive terminal (e.g. piped input in
/// scripts/CI), since raw/echo mode isn't available there.
///
/// Returns null if the user enters an empty password.
String? readHiddenPassword(String prompt) {
  stdout.write(prompt);

  if (!stdin.hasTerminal) {
    final input = stdin.readLineSync();
    return (input == null || input.isEmpty) ? null : input;
  }

  final chars = <int>[];
  var rawModeEnabled = false;
  try {
    stdin.echoMode = false;
    stdin.lineMode = false;
    rawModeEnabled = true;

    while (true) {
      final byte = stdin.readByteSync();
      if (byte == -1 || byte == 10 || byte == 13) break; // EOF or Enter

      if (byte == 127 || byte == 8) {
        // Backspace/DEL
        if (chars.isNotEmpty) {
          chars.removeLast();
          stdout.write('\b \b');
        }
        continue;
      }

      chars.add(byte);
      stdout.write('*');
    }
  } catch (_) {
    // Terminal doesn't support raw mode; whatever was captured stands.
  } finally {
    if (rawModeEnabled) {
      try {
        stdin.echoMode = true;
        stdin.lineMode = true;
      } catch (_) {}
    }
    stdout.writeln();
  }

  if (chars.isEmpty) return null;
  final password = String.fromCharCodes(chars);
  chars.fillRange(0, chars.length, 0); // best-effort: scrub the buffer
  return password;
}
