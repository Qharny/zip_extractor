import 'dart:io';
import './paths.dart';

Future<List<String>> getDestinations() async {
  final destinations = <String>[];

  print('\n📂 Setting up destination folders:');
  print('💡 Tip: You can add multiple destinations. Press Enter when done.');

  while (true) {
    if (destinations.isEmpty) {
      stdout.write('Enter destination folder path: ');
    } else {
      stdout.write(
        'Enter another destination path (or press Enter to continue): ',
      );
    }

    final userInput = stdin.readLineSync();

    if (userInput == null || userInput.trim().isEmpty) {
      if (destinations.isEmpty) {
        print('⚠️  Warning: No destinations added yet.');
        stdout.write(
          'Add at least one destination or press Enter again to exit: ',
        );
        final secondChance = stdin.readLineSync();
        if (secondChance == null || secondChance.trim().isEmpty) {
          break;
        } else {
          final cleaned = sanitizePath(secondChance);
          destinations.add(cleaned);
          print('✅ Destination added: $cleaned');
        }
      } else {
        break; // Exit the loop if the user presses Enter with destinations already added
      }
    } else {
      final cleaned = sanitizePath(userInput);
      destinations.add(cleaned);
      print('✅ Destination added: $cleaned');
    }
  }

  if (destinations.isNotEmpty) {
    print('\n📋 Selected destinations:');
    for (int i = 0; i < destinations.length; i++) {
      print('  ${i + 1}. ${destinations[i]}');
    }
    print('');
  }

  return destinations;
}
