void showHelp() {
  print('''
🗜️  ZIP Extractor Tool - Help
${'=' * 50}

DESCRIPTION:
  A tool to extract multiple ZIP files from a source directory 
  to multiple destination directories.

USAGE:
  dart zip_extractor.dart [OPTIONS]

OPTIONS:
  --help, -h    Show this help message

HOW TO USE:
  1. Run the program: dart zip_extractor.dart
  2. Enter the source folder path containing ZIP files
  3. Enter one or more destination folder paths
  4. The tool will extract all ZIP files to all destinations

FEATURES:
  • Extracts all .zip files from source directory
  • Supports multiple destination directories
  • Creates destination directories if they don't exist
  • Preserves folder structure within ZIP files
  • Shows progress and file information
  • Error handling for corrupted ZIP files

EXAMPLES:
  Source: /home/user/downloads/zips/
  Destinations: 
    - /home/user/extracted/
    - /backup/extracted/

  Result: All ZIP files will be extracted to both destinations,
          each in their own named folder.

TIPS:
  • Use absolute paths for better reliability
  • Ensure you have write permissions to destination folders
  • Large ZIP files may take time to process
  • The tool will skip corrupted or invalid ZIP files

${'=' * 50}
''');
}
