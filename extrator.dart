import 'dart:io';
import 'package:archive/archive.dart';

void main() async {
  final sourceDir = Directory('C:/Zips'); // Change as needed
  final destinationDir = Directory('C:/Zips/Extracted');

  if (!await destinationDir.exists()) {
    await destinationDir.create(recursive: true);
  }

  final zipFiles = sourceDir
      .listSync()
      .where((f) => f is File && f.path.toLowerCase().endsWith('.zip'));

  for (var file in zipFiles) {
    final zipFile = File(file.path);
    final zipBytes = await zipFile.readAsBytes();

    final archive = ZipDecoder().decodeBytes(zipBytes);
    final zipName = zipFile.uri.pathSegments.last.replaceAll('.zip', '');
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

    print('Extracted: ${zipFile.path} -> ${extractTo.path}');
  }

  print('All ZIPs extracted!');
}
