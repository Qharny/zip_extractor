import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import './formatter.dart';
import './destinations.dart';
import './paths.dart';
import './zip_password.dart';
import './password_prompt.dart';

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
  int skippedForPassword = 0;
  // Remembered so the user isn't re-prompted for every archive in a batch
  // that shares one password. Cleared once the batch finishes below.
  String? lastPassword;

  for (var file in zipFiles) {
    final zipFile = File(file.path);
    final zipName = zipFile.uri.pathSegments.last.replaceAll('.zip', '');
    final displayName = zipFile.uri.pathSegments.last;

    print('\n📦 Processing: $displayName');

    try {
      final zipBytes = await zipFile.readAsBytes();

      Archive archive;
      if (isZipEncrypted(zipBytes)) {
        print('  🔒 This archive is password-protected.');
        final result = await _decryptWithPrompt(
          zipBytes,
          displayName,
          lastPassword,
        );
        if (result.archive == null) {
          print('  ⚠️  Skipping $displayName — no valid password provided.');
          skippedForPassword++;
          continue;
        }
        archive = result.archive!;
        lastPassword = result.password;
      } else {
        archive = ZipDecoder().decodeBytes(zipBytes);
      }

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

  // Best-effort: drop the reference so the password is eligible for GC once
  // this batch is done. Dart strings are immutable, so this can't guarantee
  // the bytes are wiped from memory the way a zeroed byte buffer could.
  lastPassword = null;

  // Final summary
  print('\n' + '=' * 60);
  print('🎉 EXTRACTION COMPLETE!');
  print('📊 Summary:');
  print('  • ZIP files processed: ${zipFiles.length}');
  print('  • Total extractions: $totalExtractions');
  if (skippedForPassword > 0) {
    print('  • Skipped (no valid password): $skippedForPassword');
  }
  print('  • Destinations used: ${destinations.length}');
  print('\n📂 All files extracted to:');
  for (int i = 0; i < destinations.length; i++) {
    print('  ${i + 1}. ${destinations[i]}');
  }
  print('=' * 60);
}

/// Resolves the password needed to decode an encrypted zip, prompting the
/// user (with hidden input) and verifying each candidate against the
/// archive's encrypted entries before ever writing a file to disk.
///
/// If [rememberedPassword] is given (from a previously-decrypted archive in
/// the same batch), the user is offered a chance to reuse it first. Gives up
/// after 3 incorrect attempts.
Future<({Archive? archive, String? password})> _decryptWithPrompt(
  Uint8List zipBytes,
  String displayName,
  String? rememberedPassword,
) async {
  const maxAttempts = 3;

  Archive? tryPassword(String password) {
    final decoder = ZipDecoder();
    final archive = decoder.decodeBytes(zipBytes, password: password);
    final ok = passwordAppearsCorrect(
      zipBytes,
      decoder.directory,
      archive,
      password,
    );
    return ok ? archive : null;
  }

  if (rememberedPassword != null) {
    stdout.write('  🔑 Use the previous password for "$displayName"? (y/n): ');
    final response = stdin.readLineSync()?.trim().toLowerCase();
    if (response == 'y' || response == 'yes') {
      final archive = tryPassword(rememberedPassword);
      if (archive != null) {
        print('  ✅ Password accepted.');
        return (archive: archive, password: rememberedPassword);
      }
      print('  ❌ That password didn\'t work for this archive.');
    }
  }

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    final password = readHiddenPassword(
      '  🔒 Enter password for "$displayName": ',
    );
    if (password == null) {
      print('  ⚠️  No password entered.');
      continue;
    }

    final archive = tryPassword(password);
    if (archive != null) {
      print('  ✅ Password accepted.');
      return (archive: archive, password: password);
    }

    final attemptsLeft = maxAttempts - attempt;
    print(
      attemptsLeft > 0
          ? '  ❌ Incorrect password. $attemptsLeft attempt(s) left.'
          : '  ❌ Incorrect password.',
    );
  }

  return (archive: null, password: null);
}
