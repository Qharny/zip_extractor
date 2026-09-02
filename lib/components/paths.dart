import 'dart:io';

/// Cleans up a path pasted or typed by the user: trims whitespace, strips
/// matching surrounding quotes (common when copy-pasting a path from a
/// file manager), and expands a leading `~` to the home directory.
String sanitizePath(String raw) {
  var path = raw.trim();

  if (path.length >= 2) {
    final first = path[0];
    final last = path[path.length - 1];
    if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
      path = path.substring(1, path.length - 1).trim();
    }
  }

  if (path.startsWith('~')) {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home != null) {
      path = home + path.substring(1);
    }
  }

  return path;
}
