import 'dart:io';

Future<String> showMainMenu() async {
  print('\n📋 What would you like to do?');
  print('${'=' * 40}');
  print('1. 🗜️  Extract ZIP files');
  print('2. ❓ Show help');
  print('3. ℹ️  About this tool');
  print('4. 🚪 Exit');
  print('${'=' * 40}');

  while (true) {
    stdout.write('Enter your choice (1-4): ');
    final input = stdin.readLineSync();

    if (input != null && ['1', '2', '3', '4'].contains(input.trim())) {
      return input.trim();
    }

    print('❌ Invalid choice. Please enter 1, 2, 3, or 4.');
  }
}

void printWelcome() {
  print('''
🗜️  Welcome to ZIP Extractor Tool!
${'=' * 40}

This tool will help you extract multiple ZIP files 
from a source directory to multiple destinations.

💡 Run with --help flag for detailed instructions.

${'=' * 40}
''');
}
