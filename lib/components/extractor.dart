import 'dart:io';
import 'package:archive/archive.dart';
import './formatter.dart';
import './destinations.dart';
import './paths.dart';

Future<void> runZipExtractor() async {
  print('\n🗜️  Starting ZIP Extraction Process...');
  print('${'=' * 40}');

  // Ask for source directory
  stdout.write('Enter source folder path for ZIP files: ');
  final sourcePath = stdin.readLineSync();

  if (sourcePath == null || sourcePath.trim().isEmpty) {
    print('❌ No source path provided. Exiting.');
    print('💡 Tip: Run with --help flag to see usage instructions.');
    return;
  }

  final sourceDir = Directory(sanitizePath(sourcePath));

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

  // Create all destination directories if they don\'t exist
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
  print('\n' + '=' * 60);
  print('🎉 EXTRACTION COMPLETE!');
  print('📊 Summary:');
  print('  • ZIP files processed: ${zipFiles.length}');
  print('  • Total extractions: $totalExtractions');
  print('  • Destinations used: ${destinations.length}');
  print('\n📂 All files extracted to:');
  for (int i = 0; i < destinations.length; i++) {
    print('  ${i + 1}. ${destinations[i]}');
  }
  print('=' * 60);
}
