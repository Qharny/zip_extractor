import 'dart:io';
import 'package:archive/archive.dart';

void main(List<String> args) async {
  // Check for help flag
  if (args.contains('--help') || args.contains('-h')) {
    showHelp();
    return;
  }

  printWelcome();
  
  // Ask for source directory
  stdout.write('Enter source folder path for ZIP files: ');
  final sourcePath = stdin.readLineSync();

  if (sourcePath == null || sourcePath.trim().isEmpty) {
    print('❌ No source path provided. Exiting.');
    print('💡 Tip: Run with --help flag to see usage instructions.');
    return;
  }

  final sourceDir = Directory(sourcePath.trim());

  // Check if source exists
  if (!await sourceDir.exists()) {
    print('❌ Source folder "${sourceDir.path}" does not exist.');
    print('💡 Tip: Make sure the path is correct and the folder exists.');
    return;
  }

  print('✅ Source folder found: ${sourceDir.path}');

  // Get all destinations from the user
  final destinations = await getDestinations();

  if (destinations.isEmpty) {
    print('❌ No destinations provided. Exiting.');
    return;
  }

  // Create all destination directories if they don't exist
  print('\n📁 Setting up destination directories...');
  for (final destinationPath in destinations) {
    final destinationDir = Directory(destinationPath);
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
      print('  ✅ Created: $destinationPath');
    } else {
      print('  ✅ Found: $destinationPath');
    }
  }

  // Get all .zip files in the source directory
  print('\n🔍 Searching for ZIP files in ${sourceDir.path}...');
  final zipFiles = sourceDir.listSync().where(
    (f) => f is File && f.path.toLowerCase().endsWith('.zip'),
  );

  if (zipFiles.isEmpty) {
    print('❌ No ZIP files found in ${sourceDir.path}.');
    print('💡 Tip: Make sure there are .zip files in the source directory.');
    return;
  }

  print('✅ Found ${zipFiles.length} ZIP file(s):');
  zipFiles.forEach((file) {
    final fileName = File(file.path).uri.pathSegments.last;
    final fileSize = File(file.path).lengthSync();
    print('  📦 $fileName (${formatBytes(fileSize)})');
  });

  print('\n🚀 Starting extraction process...');
  
  // Loop through each ZIP file
  int totalExtractions = 0;
  for (var file in zipFiles) {
    final zipFile = File(file.path);
    final zipName = zipFile.uri.pathSegments.last.replaceAll('.zip', '');
    
    print('\n📦 Processing: ${zipFile.uri.pathSegments.last}');
    
    try {
      final zipBytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipBytes);
      
      print('  📄 Archive contains ${archive.length} file(s)');

      // Extract to each destination
      for (final destinationPath in destinations) {
        final destinationDir = Directory(destinationPath);
        final extractTo = Directory('${destinationDir.path}/$zipName');

        await extractTo.create(recursive: true);

        int extractedFiles = 0;
        for (final file in archive) {
          final filename = file.name;
          final outPath = '${extractTo.path}/$filename';

          if (file.isFile) {
            final outFile = File(outPath);
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content as List<int>);
            extractedFiles++;
          } else {
            await Directory(outPath).create(recursive: true);
          }
        }

        print('  ✅ Extracted $extractedFiles file(s) to: ${extractTo.path}');
        totalExtractions++;
      }
    } catch (e) {
      print('  ❌ Error extracting ${zipFile.path}: $e');
      continue;
    }
  }

  // Final summary
  print('\n' + '='*60);
  print('🎉 EXTRACTION COMPLETE!');
  print('📊 Summary:');
  print('  • ZIP files processed: ${zipFiles.length}');
  print('  • Total extractions: $totalExtractions');
  print('  • Destinations used: ${destinations.length}');
  print('\n📂 All files extracted to:');
  for (int i = 0; i < destinations.length; i++) {
    print('  ${i + 1}. ${destinations[i]}');
  }
  print('='*60);
}

/// Shows help information
void showHelp() {
  print('''
🗜️  ZIP Extractor Tool - Help
${'='*50}

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

${'='*50}
''');
}

/// Prints welcome message
void printWelcome() {
  print('''
🗜️  Welcome to ZIP Extractor Tool!
${'='*40}

This tool will help you extract multiple ZIP files 
from a source directory to multiple destinations.

💡 Run with --help flag for detailed instructions.

${'='*40}
''');
}

/// Gets multiple destination paths from the user
Future<List<String>> getDestinations() async {
  final destinations = <String>[];

  print('\n📂 Setting up destination folders:');
  print('💡 Tip: You can add multiple destinations. Press Enter when done.');
  
  while (true) {
    if (destinations.isEmpty) {
      stdout.write('Enter destination folder path: ');
    } else {
      stdout.write('Enter another destination path (or press Enter to continue): ');
    }

    final userInput = stdin.readLineSync();

    if (userInput == null || userInput.trim().isEmpty) {
      if (destinations.isEmpty) {
        print('⚠️  Warning: No destinations added yet.');
        stdout.write('Add at least one destination or press Enter again to exit: ');
        final secondChance = stdin.readLineSync();
        if (secondChance == null || secondChance.trim().isEmpty) {
          break;
        } else {
          destinations.add(secondChance.trim());
          print('✅ Destination added: ${secondChance.trim()}');
        }
      } else {
        break; // Exit the loop if the user presses Enter with destinations already added
      }
    } else {
      destinations.add(userInput.trim());
      print('✅ Destination added: ${userInput.trim()}');
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

/// Formats bytes to human readable format
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}