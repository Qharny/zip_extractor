import 'dart:io';
import 'package:archive/archive.dart';

void main() async {
  // Ask for source directory
  stdout.write('Enter source folder path for ZIP files: ');
  final sourcePath = stdin.readLineSync();
  
  if (sourcePath == null || sourcePath.trim().isEmpty) {
    print('No source path provided. Exiting.');
    return;
  }
  
  final sourceDir = Directory(sourcePath.trim());

  // Check if source exists
  if (!await sourceDir.exists()) {
    print('Source folder ${sourceDir.path} does not exist.');
    return;
  }

  // Get all destinations from the user
  final destinations = await getDestinations();
  
  if (destinations.isEmpty) {
    print('No destinations provided. Exiting.');
    return;
  }

  // Create all destination directories if they don't exist
  for (final destinationPath in destinations) {
    final destinationDir = Directory(destinationPath);
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }
  }

  // Get all .zip files in the source directory
  print('\nSearching for ZIP files in ${sourceDir.path}...');
  final zipFiles = sourceDir
      .listSync()
      .where((f) => f is File && f.path.toLowerCase().endsWith('.zip'));

  if (zipFiles.isEmpty) {
    print('No ZIP files found in ${sourceDir.path}.');
    return;
  }
  
  print('Found ${zipFiles.length} ZIP file(s).');
  zipFiles.forEach((file) {
    print('- ${File(file.path).uri.pathSegments.last}');
  });

  // Loop through each ZIP file
  for (var file in zipFiles) {
    final zipFile = File(file.path);
    final zipBytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final zipName = zipFile.uri.pathSegments.last.replaceAll('.zip', '');

    // Extract to each destination
    for (final destinationPath in destinations) {
      final destinationDir = Directory(destinationPath);
      final extractTo = Directory('${destinationDir.path}/$zipName');

      await extractTo.create(recursive: true);

      for (final file in archive) {
        final filename = file.name;
        final outPath = '${extractTo.path}/$filename';

        if (file.isFile) {
          final outFile = File(outPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(outPath).create(recursive: true);
        }
      }

      print('Extracted: ${zipFile.path} → ${extractTo.path}');
    }
  }

  final destinationsList = destinations.join('\n- ');
  print('✅ All ZIPs extracted to: \n- $destinationsList');
}

/// Gets multiple destination paths from the user
Future<List<String>> getDestinations() async {
  final destinations = <String>[];
  
  while (true) {
    if (destinations.isEmpty) {
      stdout.write('Enter destination folder path (or press Enter when done): ');
    } else {
      stdout.write('Enter another destination folder path (or press Enter when done): ');
    }
    
    final userInput = stdin.readLineSync();
    
    if (userInput == null || userInput.trim().isEmpty) {
      if (destinations.isEmpty) {
        print('Warning: No destinations added. Add at least one destination or press Enter again to exit.');
        final secondChance = stdin.readLineSync();
        if (secondChance == null || secondChance.trim().isEmpty) {
          break;
        } else {
          destinations.add(secondChance.trim());
        }
      } else {
        break; // Exit the loop if the user presses Enter with destinations already added
      }
    } else {
      destinations.add(userInput.trim());
      print('Destination added: ${userInput.trim()}');
    }
  }
  
  if (destinations.isNotEmpty) {
    print('\nSelected destinations:');
    for (int i = 0; i < destinations.length; i++) {
      print('${i + 1}. ${destinations[i]}');
    }
  }
  
  return destinations;
}