String formatBytes(int bytes) {
  if (bytes < 1024) return '[0m$bytes B';
  if (bytes < 1024 * 1024) return '[0m${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024)
    return '[0m${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '[0m${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
